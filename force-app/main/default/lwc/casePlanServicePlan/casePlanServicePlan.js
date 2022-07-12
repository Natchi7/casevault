import { LightningElement, api, track } from 'lwc';
import getServicePlanRec from '@salesforce/apex/CasePlanController.getServicePlanRecord';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CasePlanServicePlan extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @track showServicePlanVersion = false;
    @track servicePlanRecordList =[];
    @track servicePlanVersionRecordList =[];
    @track showServicePlan = false; 

    connectedCallback() {

        getServicePlanRec({casePlanId : this.recordId})
        .then(result =>{
            let res = JSON.parse(result);
            this.servicePlanRecordList = this.checkNamespaceApplicable(res.servicePlanRecord, false);
            this.servicePlanVersionRecordList = this.checkNamespaceApplicable(res.servicePlanVersionRecord, false);
             if(this.servicePlanRecordList.length) {
                 this.showServicePlan = true;
             }
                for(let i =0;i<this.servicePlanVersionRecordList.length; i++){
                    
                let foundelement = this.servicePlanRecordList.find(ele => ele.Service_Plan__c == this.servicePlanVersionRecordList[i].Service_Plan__c);
                                    if (foundelement) {
                                        if(foundelement.servicePlanVersionRecordList == null) {
                                            foundelement.servicePlanVersionRecordList = [];
                                        } 
                                        if (foundelement.servicePlanVersionRecordList != null) {
                                            foundelement.showServicePlanVersion = true;
                                            foundelement.servicePlanVersionRecordList.push(this.servicePlanVersionRecordList[i]);
                                        }
                                    }
            }

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