import { LightningElement, api, track } from 'lwc';
import getServiceInfo from '@salesforce/apex/ServiceCaseController.getServicecaseRecord';
import getChildRemoval from '@salesforce/apex/ServiceCaseController.getChildRemovalRecord';
import getPlacement from '@salesforce/apex/ServiceCaseController.getPlacementRecord';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class DisplayNumberOfDaysOpenService extends UtilityBaseElement {
    
    @api recordId;
    @api objectApiName;
    servicecaseIns={};
    serviceCaseApprover={};
    intakeRecord={};
    reviewer;
    worker;
    hoh;
    numberOfDays;
    startDate;
    openedDate='';
    familyWorker='';
    administrativeWorker='';
    childWorker='';
    Status;
    @track isClosed = true;
    closeDate;

    connectedCallback() {

       this.doInit();

    }

    doInit() {

        if(this.objectApiName == 'Service_Case__c') {
            this.doInitInfo(this.recordId);
        
        } else if(this.objectApiName == 'Placement__c'){
            getPlacement({placementId : this.recordId})
            .then(result=>{
                this.doInitInfo(result);
            })
            .catch(error => {

                        let errorMsg;
                        this.title = "Error!";
                        this.type = "error";
                        if (error) {
                            let errors = this.reduceErrors(error);
                            errorMsg = errors.join('; ');
                        } else {
                            errorMsg = 'Unknown Error';
                        }
                        this.isLoading = false;
                        this.message = errorMsg;
                        this.fireToastMsg();
                    })
        } else {
            getChildRemoval({childRemovalId : this.recordId})
            .then(result=>{
                this.doInitInfo(result);
            })
            .catch(error => {

                        let errorMsg;
                        this.title = "Error!";
                        this.type = "error";
                        if (error) {
                            let errors = this.reduceErrors(error);
                            errorMsg = errors.join('; ');
                        } else {
                            errorMsg = 'Unknown Error';
                        }
                        this.isLoading = false;
                        this.message = errorMsg;
                        this.fireToastMsg();
                    })
        }

    }

    doInitInfo(id) {

        getServiceInfo({ServicecaseId: id})
        .then(result =>{
            let res = JSON.parse(result);
            this.servicecaseIns = this.checkNamespaceApplicable(res.serviceCaseRecord, false);
            this.startDate = res.startDate;
            this.familyWorker = res.familyWorker;
            this.administrativeWorker = res.administrativeWorker;
            this.childWorker = res.childWorker;
            //this.openedDate = openDate.getMonth()+'/'+openDate.getDate()+'/'+openDate.getFullYear();
            this.openedDate = this.startDate.substring(0,10);
            //this.servicecaseIns.Close_Date__c = window.moment.tz(this.servicecaseIns.Close_Date__c).format('MM/DD/YYYY');
            this.closeDate = res.closeDate;

            if(this.servicecaseIns.Intake__c) {
                this.intakeRecord = this.servicecaseIns.Intake__r;
            }
            this.reviewer = this.servicecaseIns.Owner.Name;
            /*if(this.servicecaseIns.Intake__r.Supervisor_Approver__r.Name) {
                this.reviewer=this.servicecaseIns.Intake__r.Supervisor_Approver__r.Name;
            }*/
            if(this.servicecaseIns.Head_of_Household__c && this.servicecaseIns.Head_of_Household__r.Name) {
                this.hoh=this.servicecaseIns.Head_of_Household__r.Name;
            }
                this.numberOfDays= this.servicecaseIns.Number_of_days__c;
                this.Status = res.status;
            if(res.status == 'Close') {
                this.isClosed = true;
            } else {
                this.isClosed = false;
            }

        })
        .catch(error => {

            let errorMsg;
            this.title = "Error!";
            this.type = "error";
            if (error) {
                let errors = this.reduceErrors(error);
                errorMsg = errors.join('; ');
            } else {
                errorMsg = 'Unknown Error';
            }
            this.isLoading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }
}