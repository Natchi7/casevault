import { LightningElement, track, api } from 'lwc';
//import getInitiInformation from '@salesforce/apex/TitleIvEController.getInitialInfo';
import upsertOthercriteria from '@salesforce/apex/TitleIvEController.upserttitleIVE';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class TitleIvEOtherCetria extends UtilityBaseElement {

    @track childReceiveSSIPickList;
    @track financialInformationPickList;
    @track otherCriteriaRec = {};
    @api titleIvERec;
    @track loading = false;
    get PickList() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    get AgencyPickList() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No(Request Information from the case worker and place documentation in IV-E record/case)', value: 'No(Request Information from the case worker and place documentation in IV-E record/case)' },
            { label: 'Not Verified', value: 'Not Verified' }
        ];
    }

    connectedCallback() {
        this.otherCriteriaRec.Id = this.titleIvERec.Id;
    }

    handleChange(event) {
        this.otherCriteriaRec[event.target.name] = event.target.value;

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

    handleSave(event) {

        if (!this.onValidate()) {

            upsertOthercriteria({ titleIVEDataJSON: JSON.stringify(this.checkNamespaceApplicable(this.otherCriteriaRec,true)) }).then(result => {
                this.message = "Other Criteria Record Insert Successfuly";
                this.title = "Success";
                this.type = "success";
                this.fireToastMsg();

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
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
        } else {
            this.title = "Error!";
            this.type = "error";
            this.message = "Complete the required field(s)";
            this.fireToastMsg();
        }
    }
}