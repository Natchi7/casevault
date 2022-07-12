import { LightningElement, api, track } from 'lwc';
import getSocialHistoryRec from '@salesforce/apex/CasePlanController.getSocialHistoryRecord';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
export default class CasePlanSocialHistoryLwc extends UtilityBaseElement {

    @api recordId;
    @track socialHistoryRecord ={};
    @track loading = false;

    connectedCallback() {

        loadScript(this, momentForTime)
        this.doInit();
    }

    doInit() {

        this.loading = true;
        getSocialHistoryRec({casePlanVersionId : this.recordId})
        .then(result =>{
            let res = JSON.parse(result);
            this.socialHistoryRecord = res;
            if(this.socialHistoryRecord.riskReassessmentCompletionDate !=null) {
                this.socialHistoryRecord.riskReassessmentCompletionDate = moment(this.socialHistoryRecord.riskReassessmentCompletionDate).format('MM/DD/YYYY hh:mm A');
            } else {
                this.socialHistoryRecord.riskReassessmentCompletionDate = '';
            }
            if(this.socialHistoryRecord.safecCompletionDate !=null) {
                this.socialHistoryRecord.safecCompletionDate = moment(this.socialHistoryRecord.safecCompletionDate).format('MM/DD/YYYY hh:mm A');
            } else {
                this.socialHistoryRecord.safecCompletionDate ='';
            }
            this.loading = false;
        }).catch(error => {

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
        });
        

    }
}