import { LightningElement, track, api} from 'lwc';
import getDisclosureRecord from '@salesforce/apex/PermanacyPlanAdoptionController.getDisclosureChecklistRecord';
import updateDisclosureRecord from '@salesforce/apex/PermanacyPlanAdoptionController.updateAdoptionPlanning';
import onSubmitForApproval from '@salesforce/apex/PermanacyPlanAdoptionController.onSubmitForApproval';

import UtilityBaseElement from 'c/utilityBaseLwc';
export default class PermanencyPlanDisclosureCheckList extends UtilityBaseElement {

    @api permanencyRecId;
    @track readOnly = false;
    @track disclosureChecklistRec = {};
    @track loading = false;
    showApprovalScreen = false;
    supervisorId;
    enableSubmit = true;
    enableApprovalButton = true;

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    connectedCallback() {
        this.loading = true;
        this.disclosureChecklistRec.Id = this.permanencyRecId;
        this.doInitInfo();
    }

    doInitInfo() {
        
        getDisclosureRecord({permanencyRecordId : this.permanencyRecId}) 
        .then(result =>{
            let res = JSON.parse(result); 
            if(res.disclosureChecklistRecord) {
                this.disclosureChecklistRec = this.checkNamespaceApplicable(res.disclosureChecklistRecord, false);
                if(this.disclosureChecklistRec.Applicable_Child_Approval_Status__c == 'Approved' && this.disclosureChecklistRec.Disclosure_Approval_Status__c == null && this.disclosureChecklistRec.Disclosure_Creation_Date__c != null) {
                    this.enableApprovalButton = false;
                }else {
                    this.enableApprovalButton = true;
                }
                
            }
            this.loading = false;
        }).catch(error => {

            this.loading=false;
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
        });
        
  
    }

    handleChange(event){
        
        let fieldType = event.target.type;
        let name = event.target.name;
        let value = event.target.value;
        if (fieldType != 'checkbox') {
            this.disclosureChecklistRec[name] = value;
        } else {
            this.disclosureChecklistRec[name] = event.target.checked;
        }
    }

    handleSave() {

        if (!this.onValidate()) {

         updateDisclosureRecord({adoptionPlanningJSON : JSON.stringify(this.checkNamespaceApplicable(this.disclosureChecklistRec, true))})
        .then(res =>{
            this.title ="Success!";
            this.type ="success";
            this.message = "DisclosureChecklistRecord Update Successfully";
            this.fireToastMsg();
            this.loading = true;
            this.enableApprovalButton = false;
            this.doInitInfo();
        }).catch(error => {

            this.loading=false;
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
        });

       } else {
           this.title= "Warning!";
           this.type = "warning";
           this.message = "Please Complete Required Fields";
           this.fireToastMsg();
       }
    }

    submitforApproval() {

        this.handleSave();
        this.showApprovalScreen = true;
    }

    hideApprovalScreen() {

        this.showApprovalScreen = false;
    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId?false:true;
    }

    submitApproval() {

        onSubmitForApproval({permanencyRecId:this.permanencyRecId,selectedSupervisorUserId:this.supervisorId})
        .then(result => {
            this.title ="Success!";
            this.type ="success";
            this.message = "DisclosureChecklist Record Submitted for Approval";
            this.fireToastMsg();
            this.showApprovalScreen = false;
        }).catch(error => {

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
        })

    }
}