import { LightningElement, api, wire, track } from 'lwc';
import getTPRRecommendationInitialInfos from '@salesforce/apex/PermanacyPlanAdoptionController.getTPRRecommendationInitialInfos';
import updateAdoptionPlanning from '@salesforce/apex/PermanacyPlanAdoptionController.updateAdoptionPlanning';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class PermanencyPlanTPRRecommendation extends UtilityBaseElement {

    @api permanencyRecId;
    @track tprRec = {};
    @track pickVal = [];
    loading = false;
    wireData;
    initData = {};

    @wire(getTPRRecommendationInitialInfos, { permanencyPlanId: '$permanencyRecId' }) 
    initInfos(result) {

        this.wireData = result;
        this.loading = true;

        if(result.data) {

            this.initData = JSON.parse(result.data);
            this.loading = false;
            this.pickVal = this.initData.reasonForRecommendationPicklist;
            this.tprRec = this.checkNamespaceApplicable(this.initData.permanencyPlanRec,false);
            if(this.initData.courtHearingRec.length) {

                this.tprRec.Court_hearing_occurs__c = true;
                this.tprRec.Court_order_of_TPR_for_parents__c = true;
                this.tprRec.Petition_for_TPR_sent_to_court__c = true;
                this.tprRec.Primary_Permanacy_Plan_is_adoption__c = true;

            } else {

                this.tprRec.Court_hearing_occurs__c = false;
                this.tprRec.Court_order_of_TPR_for_parents__c = false;
                this.tprRec.Petition_for_TPR_sent_to_court__c = false;
                this.tprRec.Primary_Permanacy_Plan_is_adoption__c = false;
            }
            

        } else if (result.error) {

            this.loading = false;
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
        }
    }
   

    handleChange(event) {
        
        let fieldType = event.target.type;
        if (fieldType != 'checkbox') {
            this.tprRec[event.target.name] = event.target.value;

        } else {
            this.tprRec[event.target.name] = event.target.checked;
        }
    }

    handleSave() {

        if(this.tprRec.Court_hearing_occurs__c != true || this.tprRec.Court_order_of_TPR_for_parents__c != true || this.tprRec.Petition_for_TPR_sent_to_court__c != true || this.tprRec.Primary_Permanacy_Plan_is_adoption__c != true ) {

            this.title = "Error!";
            this.type = "error";
            this.message = 'Record does not meet the required criteria';
            this.fireToastMsg();
        }

        else if(!this.onValidate()) {
            
            this.loading = true;
            this.tprRec.Adoption_Planning__c = '3';
            updateAdoptionPlanning({adoptionPlanningJSON : JSON.stringify(this.checkNamespaceApplicable(this.tprRec,true))})
            .then(result => {

                this.loading = false;
                const evt = new ShowToastEvent({
                    title : 'Success',
                    message : 'TPR Recommendation record updated',
                    variant : 'success',
                    mode : 'dismissable'
    
                });
                this.dispatchEvent(evt);
                const stageEvent = new CustomEvent('stage');
                this.dispatchEvent(stageEvent);
                return refreshApex(this.wireData);
                

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

            const evt = new ShowToastEvent({
                title : 'Error',
                message : 'Required fields are missing',
                variant : 'error',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt);
        }
        
    }

    onValidate(){

        const allValid = [
            ...this.template.querySelectorAll("lightning-input"),...this.template.querySelectorAll("lightning-combobox"),...this.template.querySelectorAll("lightning-textarea")
            ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
            return !allValid;

    }
}