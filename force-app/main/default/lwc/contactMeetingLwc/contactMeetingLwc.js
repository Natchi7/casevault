import { LightningElement, track, api } from 'lwc';
import getInit from '@salesforce/apex/ContactMeetingController.getMeetingInfo';
import getparticipantInit from '@salesforce/apex/ContactMeetingController.getParticipantsInit';
import saveMeeting from '@salesforce/apex/ContactMeetingController.saveMeeting';
import getMeetingParticipantsInit from '@salesforce/apex/ContactMeetingController.getMeetingParticipantsInit';
import createContentVersion from '@salesforce/apex/ContactMeetingController.createContentVersion';
import getRelatedFilesByRecordId from '@salesforce/apex/CourtOrderController.getRelatedFilesByRecordId';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import UtilityBaseElement from 'c/utilityBaseLwc';

const actions =[
    {label: 'View', name: 'view'},
    {label: 'Edit', name: 'edit'}
   ];

const columns= [

    { label: 'Type of meeting', fieldName: 'Type_of_the_Meeting__c',type:'text',wrapText:'true'},
    { label: 'Date of meeting', fieldName: 'Date_of_Meeting__c',type:'date',typeAttributes:{month:"numeric",year:"numeric",day:"numeric",timeZone:"UTC"}},
    { label: 'Child name', fieldName: 'childNames',type:'text',wrapText:'true'},
    { label: 'Meeting outcome/Decision', fieldName: 'Meeting_Decision__c',type:'text',wrapText:'true'},
    { type: 'action', typeAttributes: { rowActions: actions} }
];

const documentColumn = [{ label:'Document Name', fieldName : 'label'}, { label:'Action', type:'button',typeAttributes : { label : 'Preview',variant: 'brand' , name:'preview'}}];
export default class ContactMeetingLwc extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @api objectApiName;
    columns = columns;
    documentColumn = documentColumn;
    showMeetingModal = false;
    @track meetingList = [];
    @track meetingRec = {};
    @track nameOfThePerson = [];
    @track childFamilyMembers = [];
    @track meetingType = [];
    @track meetingStatus = [];
    @track participantsOptions = [];
    @track typeOptions = [];
    @track participantList = [];
    @track followupMeetingValues =[];
    @track meetingDecisionValue = [];
    @track participantTypeOptions = [];
    @track acceptanceAgreementOptions = [];
    @track documentList = [];
    @track selectedchildFamilyMembers = [];
    @track selectedValuechildFamilyMembers = [];
    changedselectedchildFamilyMembers = false;
    @track selectedtypeOptions = [];
    @track selectedValuetypeOptions = [];
    changedselectedtypeOptions = false;
    @track selectedparticipantsOptions = [];
    @track selectedValueparticipantsOptions = [];
    changedselectedparticipantsOptions = false;
    loading = false;
    readOnly = false;
    showType = false;
    showdate = false;
    @track fileData = {};
    @track contentDocumentIdList = [];
    showFiles = false;
    signatureId = '';
    @track signatureObj = {};
    @track signatureList = [];
    showSignModal = false;
    @track childContact =[];
    @track deleteMeetingPartcipantsId = [];
    deleteId = '';
    deleteContact = '';
    get meetingTitle() {
        if(this.meetingList) {
            return 'Meeting ('+this.meetingList.length+')';
        } else{
            return 'Meeting';
        }
    }


    connectedCallback() {

        loadScript(this, momentForTime)
        this.doInit();        
    }

    doInit() {

        this.loading = true;
        getInit({recordId : this.recordId})
        .then(result => {
            let res = JSON.parse(result);
            this.nameOfThePerson = res.nameOfThePerson.splice(1);
            this.meetingType = res.meetingType;
            this.meetingStatus = res.meetingStatus.splice(1);
            this.typeOptions = res.typeOptions;
            this.followupMeetingValues = res.followupMeetingValues.splice(1);
            this.meetingDecisionValue = res.meetingDecisionValue.splice(1);
            this.childFamilyMembers = res.childFamilyMembers;
            this.participantsOptions = res.childFamilyMembers;
            this.participantTypeOptions = res.participantTypeOptions;
            this.acceptanceAgreementOptions = res.acceptanceAgreementOptions.splice(1);
            this.meetingList = this.checkNamespaceApplicable(res.meetings, false);
            this.childContact = res.childContact;
            if(this.meetingList.length > 0) {
                for(let i =0; i< this.meetingList.length;i++) {
                    var childNames = '';
                    var childList = this.meetingList[i].Select_Child_Family_Member__c.split(';');
                    /*if(this.meetingList[i].Date_of_Meeting__c) {
                        this.meetingList[i].meetingDate = moment(this.meetingList[i].Date_of_Meeting__c).format('MM/DD/YYYY');
                    }*/
                    for(let j = 0; j < this.childContact.length;j++) {
                        if(childList.includes(this.childContact[j].Id)){
                            childNames = childNames + this.childContact[j].Name + ';';
                        }
                    }
                    if(childNames.length > 0) {
                        this.meetingList[i].childNames = childNames.substring(0, childNames.length - 1);  
                    }
                }
            }
            this.loading = false;
        }).catch(error => {
            this.errorMessage(error);
        })
    }

    
    getFiles() {

        this.loading = true;
        getRelatedFilesByRecordId({recordId : this.meetingRec.Id})
        .then( result => {
            if(result != null) {
                this.documentList = Object.keys(result).map(item => ({
                    "label":result[item],
                    "value": item
                    
                }))
            }
           
            if(this.documentList.length) {
                this.showFiles = true;
            }
            this.loading = false;
            
        }).catch(error => {
            this.errorMessage(error);
        })
    }


    openMeetingModal() {

        this.meetingRec = {};
        this.selectedchildFamilyMembers = [];
        this.selectedValuechildFamilyMembers = [];
        this.selectedtypeOptions = [];
        this.selectedValuetypeOptions = [];
        this.selectedparticipantsOptions = [];
        this.selectedValueparticipantsOptions = [];
        this.participantList = [];
        this.changedselectedchildFamilyMembers = false;
        this.changedselectedtypeOptions = false; 
        this.changedselectedparticipantsOptions = false;
        this.readOnly = false;
        this.showType = false;
        this.showdate = false;
        this.showMeetingModal = true;
        this.fileData = {};
        this.documentList = [];
        this.deleteMeetingPartcipantsId = [];
    }
    closeMeetingModal() {
        this.showMeetingModal = false;
    }

    handleRowAction(event) {
        this.meetingRec = event.detail.row;
        this.selectedchildFamilyMembers = [];
        this.selectedValuechildFamilyMembers = [];
        this.selectedtypeOptions = [];
        this.selectedValuetypeOptions = [];
        this.selectedparticipantsOptions = [];
        this.selectedValueparticipantsOptions = [];
        this.changedselectedchildFamilyMembers = false;
        this.changedselectedtypeOptions = false; 
        this.changedselectedparticipantsOptions = false;
        this.showType = false;
        this.showdate = false;
        this.fileData = {};
        this.documentList = [];
        this.signatureList = [];
        this.deleteMeetingPartcipantsId = [];
        if(this.meetingRec.Select_Child_Family_Member__c != null) {
            this.selectedValuechildFamilyMembers = this.meetingRec.Select_Child_Family_Member__c.split(';');
        }
        if(this.meetingRec.Type__c != null) {
            this.selectedValuetypeOptions = this.meetingRec.Type__c.split(';');
        }
        if(this.meetingRec.Participants__c != null) {
            this.selectedValueparticipantsOptions = this.meetingRec.Participants__c.split(';');
        }
        if(this.meetingRec.Type_of_the_Meeting__c == 'FIM') {
            this.showType = true;
        }
        if(this.meetingRec.Follow_up_Meeting__c == 'Yes') {
            this.showdate = true;
        }
        
        this.loading = true;
        getMeetingParticipantsInit({meetingId : this.meetingRec.Id}) 
        .then(result => {
            let res =JSON.parse(result);
            this.participantList = this.checkNamespaceApplicable(res.meetingParticipantsList,false);
            for(let i = 0; i< this.participantList.length; i++) {
                if(this.participantList[i].Electronic_Signature__c != null) {
                    let removeImageTag = this.participantList[i].Electronic_Signature__c.replaceAll("&amp;","&");
                    this.participantList[i].sourceUrlParent1 = removeImageTag.substring(10,removeImageTag.length-8);
                    
                 } 
            }
            this.loading = false;
        }) .catch(error => {
            this.errorMessage(error);
        })
        this.getFiles(); 
        if(event.detail.action.name == 'edit') {
            this.readOnly = false;
            this.showMeetingModal = true;
        } else if(event.detail.action.name == 'view') {
            this.readOnly = true;
            this.showMeetingModal = true;
        }
    }

    handleSave() {
        this.meetingRec[this.objectApiName] = this.recordId;
        this.meetingRec.Select_Child_Family_Member__c = this.changedselectedchildFamilyMembers == true ? this.selectedchildFamilyMembers.join(';') : this.selectedValuechildFamilyMembers.join(';');
        this.meetingRec.Type__c = this.changedselectedtypeOptions == true ? this.selectedtypeOptions.join(';') : this.selectedValuetypeOptions.join(';');
        this.meetingRec.Participants__c = this.changedselectedparticipantsOptions == true ? this.selectedparticipantsOptions.join(';') : this.selectedValueparticipantsOptions.join(';');
        if(!this.onValidate()) {
            this.loading = true;
            saveMeeting({meetingJSON : JSON.stringify(this.checkNamespaceApplicable(this.meetingRec,true)), meetingParticipantsJSON: JSON.stringify(this.checkNamespaceApplicable(this.participantList,true)), contentDocumentIds : this.contentDocumentIdList, signatureJSON : JSON.stringify(this.signatureList), deleteMeetingPartcipantsId : this.deleteMeetingPartcipantsId})
            .then(result => {
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record saved successfully';
                this.fireToastMsg();
                this.loading = false;
                this.contentDocumentIdList = [];
                this.doInit();
                this.showMeetingModal = false;
            }) .catch(error => {
                this.errorMessage(error);
            })
        } else {

            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        
        }
        
    }

    handleChange(event) {
        if(event.target.name != 'Select_Child_Family_Member__c' || event.target.name != 'Type__c' || event.target.name != 'Participants__c') {
            this.meetingRec[event.target.name] = event.target.value;
        }
        if(event.target.name == 'Type_of_the_Meeting__c') {
            if(event.target.value == 'FIM') {
                this.showType = true;
            } else {
                this.selectedtypeOptions = [];
                this.showType = false;
            }
        }
        if(event.target.name == 'Select_Child_Family_Member__c') {
            this.selectedchildFamilyMembers = event.target.value;
            this.changedselectedchildFamilyMembers = true;
        }
        if(event.target.name == 'Type__c') {
            this.selectedtypeOptions = event.target.value;
            this.changedselectedtypeOptions = true; 
        }
        if(event.target.name == 'Follow_up_Meeting__c') {
            if(event.target.value == 'Yes') {
                this.showdate = true;
            } else {
                this.meetingRec.Follow_up_meeting_Start_date__c = null;
                this.showdate = false;
            }
        }
        if(event.target.name == 'Participants__c') {
            this.changedselectedparticipantsOptions = true;
            var targetValue = event.target.value;
            if(targetValue.length > this.selectedValueparticipantsOptions.length) {

                this.selectedparticipantsOptions = event.target.value;
                this.selectedValueparticipantsOptions = event.target.value;
                this.loading = true;
                getparticipantInit({contactId : this.selectedparticipantsOptions[this.selectedparticipantsOptions.length -1]})
                .then(result => {
                    let res =JSON.parse(result);
                    this.participantList.push(this.checkNamespaceApplicable(res.meetingParticipants,false));
                    this.loading = false;
                }).catch(error => {
                    this.errorMessage(error);
                }) 
            } else {
                for(let i = 0; i< this.selectedValueparticipantsOptions.length; i++) {
                
                    if(targetValue.includes(this.selectedValueparticipantsOptions[i]) == false){
                        for(let j = 0; j<this.participantList.length ; j++) {
                            if(this.participantList[j].Participants__c == this.selectedValueparticipantsOptions[i]) {
                                this.deleteId = this.participantList[j].Id;
                                this.deleteContact = this.selectedValueparticipantsOptions[i].Participants__c;        
                                this.spliceRow();
                            }
                        }
                    }
                }
                this.selectedparticipantsOptions = event.target.value;
                this.selectedValueparticipantsOptions = event.target.value;
            }
            
        }
    }

    handleParticipantChange(event) {
        
        var rowId = event.target.dataset.id;
        for(let i = 0; i<this.participantList.length;i++) {
            if(this.participantList[i].Id == rowId) {
                //var row = this.participantList[i];
                if(event.target.type != 'checkbox') {
                    this.participantList[i][event.target.name] = event.target.value;
                } else {
                    this.participantList[i][event.target.name] = event.target.checked;
                }
            }
        }
    }

    handleDelete(event) {

        this.deleteId = event.target.dataset.id;
        this.deleteContact = event.target.dataset.contact;        
        this.spliceRow();
    }

    spliceRow() {

        var findrow = {};
        findrow = this.participantList.find(element => element.Id == this.deleteId);
        if(findrow != null) {
            var rows = [...this.participantList];
            rows.splice(this.participantList.indexOf(findrow), 1);
            this.participantList = rows; 
            for(let i =0; i< this.selectedValueparticipantsOptions.length;i++) {
                if(this.selectedValueparticipantsOptions[i] == this.deleteContact) {
                    let picklistrows = [...this.selectedValueparticipantsOptions];
                    picklistrows.splice(this.selectedValueparticipantsOptions.indexOf(this.deleteContact), 1);
                    this.selectedValueparticipantsOptions = picklistrows;  
                    this.selectedparticipantsOptions = this.selectedValueparticipantsOptions;
                }
            }
        }
        
        for(let i =0; i< this.signatureList.length;i++) {
            if(this.signatureList[i].Id == this.deleteId) {
                let deletedRow = [...this.signatureList];
                deletedRow.splice(i,1);
                this.signatureList = deletedRow;
            }
        }
        this.deleteMeetingPartcipantsId.push(this.deleteId);    
    }

    openfileUpload(event) {

        const file = event.target.files[0]
        var reader = new FileReader();
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
            }
            this.loading = true;
            createContentVersion({base64:this.fileData.base64 , filename:this.fileData.filename})
            .then(result => {
                this.contentDocumentIdList.push(result);
                this.title = "Success!";
                this.type = "success";
                this.message = 'File uploaded Successfully';
                this.fireToastMsg();
                this.loading = false;
            }) .catch(error => {
                this.errorMessage(error);
            })
        }
        
        reader.readAsDataURL(file); 

    }

    handleFileRowAction(event) {

        let filerow = event.detail.row;
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: filerow.value
            }
        })
    }

    handleSignModal(event) {

        this.signatureId = event.target.dataset.id;
        this.showSignModal = true;
    }

    closeSignModal() {

        this.showSignModal = false;
    }

    handleSignature(event) {

        var pushObj = false;
        for(let i =0; i< this.signatureList.length;i++) {
            if(this.signatureList[i].Id == this.signatureId) {
                this.signatureList[i].electronicSignature = event.detail;
                pushObj = true;
            }
        }
        if(pushObj == false) {
            this.signatureObj = {};
            this.signatureObj.Id = this.signatureId;
            this.signatureObj.electronicSignature = event.detail;
            this.signatureList.push(this.signatureObj);
        }
        
    }

    errorMessage(error) {

            this.loading = false;
            let errorMsg;
            this.title ="Error!";
            this.type ="error";
            if(error) {
                let errors = this.reduceErrors(error);
                errorMsg = errors.join('; ');
            } else {
                errorMsg = 'Unknown Error';
            }
            this.message = errorMsg;
            this.fireToastMsg();
    }

    onValidate() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"), ...this.template.querySelectorAll("lightning-combobox"), ...this.template.querySelectorAll("lightning-textarea"), ...this.template.querySelectorAll("lightning-radio-group"), ...this.template.querySelectorAll("lightning-dual-listbox")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return !allValid;
    }
}