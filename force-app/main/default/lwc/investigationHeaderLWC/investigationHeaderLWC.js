import { LightningElement, api, track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInvestigationRecord from '@salesforce/apex/InvestigationController.getInvestigationRecord'
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class InvestigationHeaderLWC extends UtilityBaseElement{

    @api recordId;
    @api objectApiName;
    @track investRec ={};
    @track intakeNo = '';
    @track startDate;
    @track restrict = '';
    @track hoh = '';
    @track intakeReferral = '';
    @track worker ='';
    @track casevaultId ='';
    @track reviewer = '';
    @track CaseNumber='';
    status;
    @track showModal = false;
    responseTimer;
    @track showResponseTimerWarning=false;
    @track isClosed = true;
    timeZone = TIME_ZONE;
    

    connectedCallback(){
        
        loadScript(this, momentForTime)
        getInvestigationRecord({investigationId: this.recordId, objectApiName: this.objectApiName})
        .then(result=>{
            let res = JSON.parse(result);
            this.investRec = this.checkNamespaceApplicable(res.investigationRecord,false);
            if(this.investRec.Response_Timer__c) {
                this.responseTimer = this.investRec.Response_Timer__c;
            } else {
                var today = new Date();
                today.setMonth( today.getMonth() + 1);
                /*var date = today.getFullYear()+'/'+(today.getMonth()+1)+'/'+today.getDate();
                var time = today.getHours() + ":" + today.getMinutes();*/
                //this.responseTimer=date+' '+time;
                this.responseTimer = today;
                    }
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.CaseNumber){
                this.intakeNo = this.investRec.Intake__r.CaseNumber;
            }
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.Status) {
                this.status = this.investRec.Intake__r.Status;
            }
            if(this.status =='Closed') {
                this.isClosed = true;
            } else {
                this.isClosed = false;
            }
            if(res.startDate){
                this.startDate = res.startDate;
            }
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.Supervisor_Approver__c){
                this.reviewer = this.investRec.Intake__r.Supervisor_Approver__r.Name;
            }
            
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.Restrict_UnRestrict__c){
                this.restrict = this.investRec.Intake__r.Restrict_UnRestrict__c;
            }
            if(this.investRec.Head_of_Household__c && this.investRec.Head_of_Household__r.Name){
                this.hoh = this.investRec.Head_of_Household__r.Name;
            }
            
            if(this.investRec.Head_of_Household__c && this.investRec.Head_of_Household__r.Casevault_PID__c){
                this.casevaultId = this.investRec.Head_of_Household__r.Casevault_PID__c;
            }
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.Origin){
                this.intakeReferral = this.investRec.Intake__r.Origin;
            }
            if(this.investRec.Number_of_days_created_date__c != 0) {
                this.showResponseTimerWarning = false;
            } else {
                this.showResponseTimerWarning = true;
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

    openModal() {

        this.showModal = true;
    }

    closeModal() {

        this.showModal = false;
    }
}