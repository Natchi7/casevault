import { LightningElement, api, track } from 'lwc';
import getYouthTransitionPlanRec from '@salesforce/apex/CasePlanController.getYouthTransitionPlanRecords';
import UtilityBaseElement from 'c/utilityBaseLwc';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';

export default class CasePlanYouthTransitionPlan extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @track youthTransitionPlanList = [];
    @track loading = false;
    @track showTable = false;
    connectedCallback() {
    
        this.loading = true;
        loadScript(this, momentForTime)
        getYouthTransitionPlanRec({casePlanId : this.recordId})
        .then(result =>{

            let res = JSON.parse(result);
            this.youthTransitionPlanList = this.checkNamespaceApplicable(res.youthTransitionPlanList, false);
            if(this.youthTransitionPlanList.length) {
                this.showTable = true;
            } 
            for(let i =0;i<this.youthTransitionPlanList.length;i++) {
                this.youthTransitionPlanList[i].CreatedDate = moment(this.youthTransitionPlanList[i].CreatedDate).format('MM/DD/YYYY');
            }
            this.loading = false;
        })
        .catch(error => {
    
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

    navigateClick(event) {

        let id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                actionName: 'view'
            }
        });
    }

}