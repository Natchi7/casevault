import { LightningElement, wire, track, api } from 'lwc';
import getInitiInfo from '@salesforce/apex/CourtController.getInitialInfos';
import getChildDetails from '@salesforce/apex/CourtController.getCourtChildDetails';
import savePetitionRec from '@salesforce/apex/CourtController.upsertPetition';
import deleteSiblingRec from '@salesforce/apex/CourtController.deleteSiblingRec';
import deleteSubpoenaedRec from '@salesforce/apex/CourtController.deleteSubpoenaed';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import { loadScript } from 'lightning/platformResourceLoader';
import REFRESH_CHANNEL from '@salesforce/messageChannel/courtHearingRefreshChannel__c';
import { createMessageContext, MessageContext, publish} from 'lightning/messageService';

import UtilityBaseElement from 'c/utilityBaseLwc';
export default class PetitionRecordPageLwc extends UtilityBaseElement {

    @wire(MessageContext)context;
    @api recordId;
    @api objectApiName;
    @track petitionTableTitle = '';
    @track showPetitionModal = false;
    @track isSpinner = false;
    @track isShowOnly = false;
    @track petitionForChildPicklist = [];
    @track typeOfPetitionPicklist = [];
    @track otherChildPicklist = [];
    @track childAttorneyPicklist = [];
    @track petitionList = [];
    @track petitionRec = {};

    //
    @track newReviewPick = [];
    @track emerengcyPick = [];
    @track childCurrentPlacementpick = [];
    @track parentNamePick = [];
    @track previousJuvenileCourtPick = [];
    @track parentsCircumstancePick = [];
    @track specialneedsofRespondentPick = [];
    @track whatServicesWereOfferedPick = [];
    @track wereReasonableEffortsNotMadePick = [];
    @track familyInvolvementMeetingPick = [];
    @track siblingRec = {};
    @track showSiblingModal = false;
    @track showCINACMP = false;
    @track petId = '';
    @api siblingId = '';
    @api siblingsList = [];
    @track subpoenedRec = {};
    @track showSubpoenaedModal = false;
    @track showSiblingAddButton = false;
    @track showSiblingUpdateButton = false;
    @track showSubAddButton = false;
    @track showSubUpdateButton = false;
    @track subpoenaedList = [];

    connectedCallback() {

        loadScript(this, momentForTime)
        this.doInitInfo();
    }

    doInitInfo() {

        this.isSpinner = true;
        getInitiInfo({ recordId: this.recordId })
            .then(result => {

                let res = JSON.parse(result);
                this.newReviewPick = res.newReviewPickList;
                this.emerengcyPick = res.emergencyPickList;
                this.childCurrentPlacementpick = res.childCurrentPlacementPicklist;
                this.parentNamePick = res.parentNamePicklist
                this.previousJuvenileCourtPick = res.previousJuvenileCourtPicklist;
                this.parentsCircumstancePick = res.parentsCircumstancePicklist;
                this.specialneedsofRespondentPick = res.specialneedsofRespondentPicklist;
                this.whatServicesWereOfferedPick = res.whatServicesWereOfferedPicklist;
                this.wereReasonableEffortsNotMadePick = res.wereReasonableEffortsNotMadePicklist;
                this.familyInvolvementMeetingPick = res.familyInvolvementMeetingPickList;
                this.petitionForChildPicklist = res.petitionForChildPicklist;
                this.typeOfPetitionPicklist = res.typeOfPetitionPicklist;
                this.petitionList = this.checkNamespaceApplicable(res.serviceCourtList, false);
                let petitionColumChangeList = this.petitionList;
                for (var i = 0; i < petitionColumChangeList.length; i++) {

                    var row = petitionColumChangeList[i];

                    /*if (row.Child_Attorney__r) {
                        row.childAttorneyName = row.Child_Attorney__r.Name;
                    }*/
                    if (row.Child_s_Attorney__c) {
                        row.childAttorneyName = row.Child_s_Attorney__r.Collateral_Full_Name__c;
                    }

                }
                this.petitionList = petitionColumChangeList;
                this.petitionTableTitle = 'Courts (' + this.petitionList.length + ')';
                this.otherChildPicklist = res.otherClientsNamedOnPetitionPicklist;
                this.childAttorneyPicklist = res.childAttorneyPicklist;
                this.isSpinner = false;
            }).catch(error => {

                this.isSpinner = false;
                let errorMsg;
                this.title = "Error!";
                this.type = "error";
                if (error) {
                    let errors = this.reduceErrors(error);
                    errorMsg = errors.join('; ');
                } else {
                    errorMsg = 'Unknown Error';
                }
                this.message = errorMsg;
                this.fireToastMsg();
            })
    }

    handlePetRecordAction(event) {

        this.petitionRec = event.detail.petitionRec;

        getChildDetails({ petitionId: event.detail.petitionRec.Id })
            .then(result => {
                let res = JSON.parse(result);
                this.siblingsList = this.checkNamespaceApplicable(res.siblingsList, false);
                this.subpoenaedList = this.checkNamespaceApplicable(res.subpoenaedList, false);
                this.showPetitionModal = event.detail.showPetitionModal;
                this.showCINACMP = event.detail.showCINAPetDetail;
                this.isShowOnly = event.detail.isReadOnly;

            }).catch(error => {

                this.showPetitionModal = false;
                this.isSpinner = false;
                let errorMsg;
                this.title = "Error!";
                this.type = "error";
                if (error) {
                    let errors = this.reduceErrors(error);
                    errorMsg = errors.join('; ');
                } else {
                    errorMsg = 'Unknown Error';
                }
                this.message = errorMsg;
                this.fireToastMsg();
            })
    }

    handleChange(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let Value = event.target.value;
        let fieldType = event.target.type;

        if (fieldType != 'checkbox') {
            if (fieldName == 'Child_s_Current_placement_if_not_foster__c' || fieldName == 'D_Special_needs_of_Respondent__c' ||
                fieldName == 'PARENT_S_CIRCUMSTANCE__c' || fieldName == 'C_What_Services_were_offered_prior__c') {
                let multiValues = Value.join(';');
                this.petitionRec[fieldName] = multiValues;
            } else if (fieldName == 'Type_of_Petition__c') {
                this.petitionRec[fieldName] = Value;
                if (Value == 'CINA') {
                    this.showCINACMP = true;
                } else {
                    this.showCINACMP = false;
                }
            } else {
                this.petitionRec[fieldName] = Value;
            }
        } else {
            this.petitionRec[fieldName] = checkedfields;
        }
    }

    addSibling(event) {

        this.showSiblingModal = true;
        this.showSiblingAddButton = true;
        this.showSiblingUpdateButton = false;
        this.siblingRec = {};
    }

    cancelSiblingModal(event) {

        this.showSiblingModal = false;
        this.showSiblingAddButton = false;
        this.showSiblingUpdateButton = false;
        this.siblingRec = {};
    }

    handleChangeSibling(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let Value = event.target.value;
        let fieldType = event.target.type;
        if (fieldType != 'checkbox') {
            this.siblingRec[fieldName] = Value;
        } else {
            this.siblingRec[fieldName] = checkedfields;
        }

    }

    handleUpdateSibling(event) {



        this.siblingsList = [...this.siblingsList];
        this.showSiblingModal = false;
    }

    handleAddSibling(event) {

        /*const childdetail = new CustomEvent('childrecord', {
            detail: {
                sibling: this.siblingRec
            }
        });
        this.dispatchEvent(childdetail);*/
        if (Object.keys(this.siblingRec).length) {
            this.siblingRec.Court__c = this.petitionRec.Id;
            this.siblingsList.push(this.siblingRec);
        }
        this.showSiblingModal = false;
        //} else {
        //    this.siblingsList.push(this.siblingRec);
        //}

    }

    addHandleSubpoenaed(event) {

        if (Object.keys(this.subpoenedRec).length) {
            this.subpoenedRec.Court__c = this.petitionRec.Id;
            this.subpoenaedList.push(this.subpoenedRec);
        }
        this.showSubpoenaedModal = false;
    }

    updateHandleSubpoenaed(event) {

        this.subpoenaedList = [...this.subpoenaedList];
        this.showSubpoenaedModal = false;

    }

    handleChangeSubpoened(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let value = event.target.value;
        let fieldType = event.target.type;
        if (fieldType != 'checkbox') {
            this.subpoenedRec[fieldName] = value;
        } else {
            this.subpoenedRec[fieldName] = checkedfields;
        }
    }

    addSubpoenaed(event) {

        this.showSubpoenaedModal = true;
        this.subpoenedRec = {};
        this.showSubAddButton = true;
        this.showSubUpdateButton = false;

    }

    cancelSubpoenaedModal(event) {

        this.showSubpoenaedModal = false;
        this.subpoenedRec = {};
        this.showSubAddButton = false;
        this.showSubUpdateButton = false;
    }

    handleIconAction(event) {

        //let siblingRec = event.target.dataset.siblingrec; 
        //let subpoenaedRec = event.target.dataset.subrec;
        let actionName = event.target.name;
        let index = event.target.dataset.index;
        switch (actionName) {

            case 'siblingEdit':
                this.showSiblingModal = true;
                this.showSiblingAddButton = false;
                this.showSiblingUpdateButton = true;
                let foundSiblingEditRec = this.siblingsList[index];
                this.siblingRec = foundSiblingEditRec;
                break;

            case 'siblingDelete':
                let foundSiblingDelRec = this.siblingsList[index];
                if (foundSiblingDelRec) {
                    if (foundSiblingDelRec.Id) {
                        deleteSiblingRec({ siblingRec: JSON.stringify(this.checkNamespaceApplicable(foundSiblingDelRec, true)) })
                            .then(result => {
                                let res = result;
                                let rows = this.siblingsList;
                                //const rowIndex = rows.indexOf(foundSiblingDelRec);
                                rows.splice(index, 1);
                                this.siblingsList = rows;
                                //const event = this.onToastEvent('success', 'Success!', 'Sibling record deleted successfully.');
                                //this.dispatchEvent(event);
                                //this.doInitInfo();
                            }).catch(error => {

                                let errorMsg;
                                this.title = "Error!";
                                this.type = "error";
                                if (error) {
                                    let errors = this.reduceErrors(error);
                                    errorMsg = errors.join('; ');
                                } else {
                                    errorMsg = 'Unknown Error';
                                }
                                this.message = errorMsg;
                                this.fireToastMsg();
                            })
                    } else {
                        let rows = this.siblingsList;
                        //const rowIndex = rows.indexOf(foundSiblingDelRec);
                        rows.splice(index, 1);
                        this.siblingsList = rows;
                    }
                }
                break;

            case 'subpoenaedEdit':
                this.showSubpoenaedModal = true;
                this.showSubAddButton = false;
                this.showSubUpdateButton = true;
                let foundSubEditRec = this.subpoenaedList[index];
                this.subpoenedRec = foundSubEditRec;
                break;

            case 'subpoenaedDelete':
                let foundSubDelRec = this.subpoenaedList[index];
                if (foundSubDelRec) {
                    if (foundSubDelRec.Id) {
                        deleteSubpoenaedRec({ subpoenaedRec: JSON.stringify(this.checkNamespaceApplicable(foundSubDelRec, true)) })
                            .then(result => {
                                let res = result;
                                let rows = this.subpoenaedList;
                                //const rowIndex = rows.indexOf(foundSubDelRec);
                                rows.splice(index, 1);
                                this.subpoenaedList = rows;
                                //const event = this.onToastEvent('success', 'Success!', 'Sibling record deleted successfully.');
                                //this.dispatchEvent(event);
                                //this.doInitInfo();
                            }).catch(error => {

                                let errorMsg;
                                this.title = "Error!";
                                this.type = "error";
                                if (error) {
                                    let errors = this.reduceErrors(error);
                                    errorMsg = errors.join('; ');
                                } else {
                                    errorMsg = 'Unknown Error';
                                }
                                this.message = errorMsg;
                                this.fireToastMsg();
                            })
                    } else {
                        let rows = this.subpoenaedList;
                        //const rowIndex = rows.indexOf(foundSubDelRec);
                        rows.splice(index, 1);
                        this.subpoenaedList = rows;
                    }
                }
                break;
        }
    }

    handleNew(event) {

        this.petitionRec[this.objectApiName] = this.recordId;
        this.showPetitionModal = true;

    }

    closeModal() {

        this.showPetitionModal = false;
        this.isShowOnly = false;
        this.showCINACMP = false;
        this.petitionRec = {};
    }

    handleSave(evt) {

        if (!this.onValidate()) {
            this.onSavePetition();
        } else {
            this.title = "Error!";
            this.type = "error";
            this.message = "Please complete the required field(s).";
            this.fireToastMsg();
        }
    }

    isChecksEmpty(obj) {

        for (var prop in obj) {
            if (obj.hasOwnProperty(prop))
                return false;
        }

        return true;

    }

    onSavePetition() {

        savePetitionRec({ petitionJSONStr: JSON.stringify(this.checkNamespaceApplicable(this.petitionRec, true)), siblingsJSONStr: JSON.stringify(this.checkNamespaceApplicable(this.siblingsList, true)), subpoenedJSONStr: JSON.stringify(this.checkNamespaceApplicable(this.subpoenaedList, true)) })
            .then(result => {
                let res = result;
                this.petitionId = res;
                this.title = "Success!";
                this.type = "success";
                this.message = "Petition record created successfully";
                this.fireToastMsg();
                const payload = {
                    recordName : '',
                };
                publish(this.context,REFRESH_CHANNEL,payload);
                //if(!isEmpty(this.siblings)) {
                let res1 = this.isChecksEmpty(this.siblings);
                let res2 = this.isChecksEmpty(this.subpoenaedRec);
                this.closeModal();
                this.doInitInfo();
            }).catch(error => {

                let errorMsg;
                this.title = "Error!";
                this.type = "error";
                if (error) {
                    let errors = this.reduceErrors(error);
                    errorMsg = errors.join('; ');
                } else {
                    errorMsg = 'Unknown Error';
                }
                this.message = errorMsg;
                this.fireToastMsg();
            })

    }

    handleDeleteAction(event) {
        this.petitionTableTitle = event.detail;
    }

    onValidate() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"), ...this.template.querySelectorAll("lightning-combobox"), ...this.template.querySelectorAll("lightning-textarea")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return !allValid;
    }

    onToastEvent(type, toastTitle, msg) {
        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }
}