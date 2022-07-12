import { LightningElement, track, api} from 'lwc';
import updateRateRec from '@salesforce/apex/PermanacyPlanAdoptionController.upsertRateRecord';
import getIntialInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getRateRecordInfo';
import getRateRecord from '@salesforce/apex/PermanacyPlanAdoptionController.getRateRecord';
import getSubmitForApproval from '@salesforce/apex/PermanacyPlanAdoptionController.subsidySubmitForApproval';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import { loadScript } from 'lightning/platformResourceLoader';

import UtilityBaseElement from 'c/utilityBaseLwc';

const actions = [
    { label: 'Preview', name: 'preview'},
    { label: 'Edit', name: 'edit'}
    
];

const columns = [
    { label: 'TRANSACTION DATE', fieldName: 'Transaction_Date__c', type: 'string'},
    { label: 'PROVIDER ID', fieldName: 'providerId', type: 'string'},
    { label: 'RATE BEGIN DATE', fieldName: 'Rate_Begin_Date__c', type: 'string'},
    { label: 'RATE END DATE', fieldName: 'Rate_End_Date__c', type: 'string'},
    { label: 'MONTHLY PAYMENT AMOUNT', fieldName: 'Monthly_Payment_Amount__c', type: 'string'},
    { label: 'APPROVAL DATE', fieldName: 'SSA_Approval_Date__c', type: 'string'},
    { label: 'STATUS', fieldName: 'Rate_Approval_Status__c', type: 'string'},
    { type: 'action', typeAttributes: { rowActions: actions} }
    
];


export default class PermanencyPlanSubsidyRates extends UtilityBaseElement {

    @track showRateModal = false;
    @track readOnly = false;
    @api permanencyRecId;
    rateRecord = {};
    @track rateRecordList = [];
    primaryBasisPickValue;
    @track loading =false;
    @track showAddButton = true;
    @track showSubmitforApprovalModal =false;
    @track selectedUserId;
    @track adoptiveParent1;
    @track adoptiveParent2;
    @track agreementStartDate;
    @track providerId;
    @track enableSubmit = true;
    @track enableSendforApproval = false;
    conditionCheck = true;
    columns = columns;
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    
    connectedCallback() {
        
        loadScript(this, momentForTime)
        this.loading = true;
        this.doInitInfo();
        this.rateRecord.Permanency_Plan__c = this.permanencyRecId;
    }

    doInitInfo() {

        getIntialInfo({PermanacyPlanId : this.permanencyRecId})
        .then(result =>{

            let res = JSON.parse(result);
            this.primaryBasisPickValue = res.primaryBasisPicklist;
            if((res.rateRecord).length != 0) {

                this.rateRecordList = this.checkNamespaceApplicable(res.rateRecord, false);
                for(let i=0; i<this.rateRecordList.length;i++) {
                    this.rateRecordList[i].Rate_Begin_Date__c = moment(this.rateRecordList[i].Rate_Begin_Date__c).format('MM/DD/YYYY');
                    this.rateRecordList[i].Rate_End_Date__c = moment(this.rateRecordList[i].Rate_End_Date__c).format('MM/DD/YYYY');

                    if(this.rateRecordList[i].Transaction_Date__c) {
                        this.rateRecordList[i].Transaction_Date__c = moment(this.rateRecordList[i].Transaction_Date__c).format('MM/DD/YYYY');
                    }
                    if(this.rateRecordList[i].SSA_Approval_Date__c) {
                        this.rateRecordList[i].SSA_Approval_Date__c = moment(this.rateRecordList[i].SSA_Approval_Date__c).format('MM/DD/YYYY');
                    }
                }
                this.showAddButton = false;
            }
            if(res.permanencyPlanRec) {

                let rec = this.checkNamespaceApplicable(res.permanencyPlanRec, false);
                this.adoptiveParent1 = rec.Adoptive_Parent_1__c; 
                this.adoptiveParent2 = rec.Adoptive_Parent_2__c;
                this.providerId = rec.Subsidy_Provider_Id__c;
                this.agreementStartDate = rec.Subsidy_Agreement_Start_Date__c;

            }
            if(this.rateRecordList.length > 0) {
                for(let i = 0; i < this.rateRecordList.length; i++) {
                    this.rateRecordList[i].providerId = this.providerId;
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

    handleRateModal() {

        this.enableSendforApproval = true;
       if (this.rateRecordList.length) {

            for(let i=0; i<=this.rateRecordList.length; i++) {

                if((this.rateRecordList[i].Permanency_Plan__r.Subsidy_Approval_Status__c) != 'Approved') {

                    this.title="Warning!";
                    this.type = "error";
                    this.message ="Subsidy Agreement Record Must Be Approved";
                    this.fireToastMsg();
                } else {

                    this.rateRecord = {};
                    this.readOnly = false;
                    this.showRateModal = true;
                }
            }
       } else {

        this.rateRecord = {};
        this.readOnly = false;
        this.showRateModal = true;
      }      
   }

    closeRateModal() {

        this.showRateModal = false;
    }

    handleChange(event) {

        let fieldType = event.target.type;
        let name = event.target.name;
        let value = event.target.value;
        if (fieldType != 'checkbox') {

            this.rateRecord[name] = value;
        } else {

            this.rateRecord[name] = event.target.checked;
        }
    }

    handleSave() {

        if(!this.onValidate()) {

            const oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds Agreement_Start_Date__c
            const firstDate = new Date(this.rateRecord.Rate_Begin_Date__c);
            const secondDate = new Date(this.rateRecord.Rate_End_Date__c);
            const diffDays = Math.round(Math.abs((firstDate - secondDate) / oneDay));
            if(this.rateRecord.Rate_Begin_Date__c >=  this.agreementStartDate) { 
                if (diffDays >= 365) {
                    this.conditionCheck = true;
                } else {
                    this.conditionCheck = false;
                    this.title = 'Warning!';
                    this.type = 'warning';
                    this.message = ' Rate end date and begin date difference should be 365 days.';
                    this.fireToastMsg();
                }
            } else {

                this.conditionCheck = false;
                this.title = 'Warning!';
                this.type = 'warning';
                this.message = 'Rate begin Date should not be less than agreement start date';
                this.fireToastMsg();

            }
            if(this.conditionCheck == true) {
                this.rateRecord.Permanency_Plan__c = this.permanencyRecId;
                updateRateRec({raterecord : JSON.stringify(this.checkNamespaceApplicable(this.rateRecord, true))})
                .then( result =>{

                    this.title = "Success!";
                    this.type = "success";
                    this.message = "Record Update Successfully"; 
                    this.fireToastMsg();
                    this.showRateModal = false;
                    this.loading = true;
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
            }
            
        } else {

            this.title ="Error!";
            this.type="error"
            this.message="Please complete the requried field(s)"
            this.fireToastMsg();
        }
    }

    handleViewModal(row) {

        this.loading = true;
        let Id = row.Id;
        getRateRecord({rateRecordId : Id })
        .then( res => {

            this.rateRecord = this.checkNamespaceApplicable(JSON.parse(res), false);
            this.adoptiveParent1 = this.rateRecord.Permanency_Plan__r.Adoptive_Parent_1__c; 
            this.adoptiveParent2 = this.rateRecord.Permanency_Plan__r.Adoptive_Parent_2__c;
            this.providerId = this.rateRecord.Permanency_Plan__r.Subsidy_Provider_Id__c
            this.readOnly = true;
            this.loading = false;
            this.showRateModal = true;
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

    handleEditModal(row) {

        this.enableSendforApproval = false;
        this.loading = true;
        let Id =row.Id;
        getRateRecord({rateRecordId : Id })
        .then( res => {

            this.rateRecord = this.checkNamespaceApplicable(JSON.parse(res), false);
            this.adoptiveParent1 = this.rateRecord.Permanency_Plan__r.Adoptive_Parent_1__c; 
            this.adoptiveParent2 = this.rateRecord.Permanency_Plan__r.Adoptive_Parent_2__c;
            this.providerId = this.rateRecord.Permanency_Plan__r.Subsidy_Provider_Id__c
            this.loading = false;
            this.readOnly = false;
            this.showRateModal = true;
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

    handleSubmitForApproval(event) {

        if ((this.rateRecord.Rate_Approval_Status__c != 'Submitted') && (this.rateRecord.Rate_Approval_Status__c != 'Approved')) {

            this.showSubmitforApprovalModal = true;
            this.showRateModal = false;
        } else if ((this.rateRecord.Rate_Approval_Status__c == 'Submitted') ||(this.rateRecord.Rate_Approval_Status__c == 'Approved')) {

            this.showSubmitforApprovalModal = false;    
            this.ttitle='Error!';
            this.type = "error";
            this.message ="Subsidy Agreement Record Already Submitted "
            this.fireToastMsg();
        }
    }

    closeSubmiteModal(event) {

        this.showSubmitforApprovalModal = false;
    }

    handleSelectRec(event) {

        this.selectedUserId = event.detail.recordId;
        this.enableSubmit = this.selectedUserId?false:true;
    }

    submitApproval(event) {

        getSubmitForApproval({subsidyRateRecId: this.rateRecord.Id, selectedSupervisorUserId:this.selectedUserId})
        .then(result=>{

            this.showSubmitforApprovalModal = false;
            this.title = "Success!";
            this.type = "success";
            this.message = "Subsidy Agreement Record Submitted for Approval Successfully";
            this.fireToastMsg();
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
            this.loading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'preview': 
                this.handleViewModal(row);
                break;
            case 'edit': 
                this.handleEditModal(row);
                break;
        }
    }
}