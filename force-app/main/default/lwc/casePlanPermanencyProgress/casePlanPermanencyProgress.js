import { LightningElement, api, track } from 'lwc';
import getPermanencyProgressRec from '@salesforce/apex/CasePlanController.getPermanencyProgressRecord';
import updatePermanencyProgressRec from '@salesforce/apex/CasePlanController.updatePermanencyProgressRecord';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import { loadScript } from 'lightning/platformResourceLoader';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class CasePlanPermanencyProgress extends UtilityBaseElement {

    @api recordId;
    @track permanencyProgressRecord = {};
    @track permanencyPlanRecord = {};
    @track AssessmentRecords =[];
    @track childRemovalRec ={};
    @track incomeRecord ={};
    @track assetRecord ={};
    @track initialExamRecords ={};
    @track finalExamRecords ={};
    @track followupExamRecords ={};
    @track assessmentCompletedDates =[];
	@track educationRecords =[];
    @track faceToFaceRecords =[];
    @track medicationRecords =[];
    @track locationAddress;
    @track showPermanencyProgress = false;
    @track isLoading = false;
    showAssessmentTable = false;
    showInitialExamTable = false;
    showFinalExamTable = false;
    showFollowupExamTable = false;
    showEducationTable = false;
    Child_Support_Referral_Date ='';

    get PickList() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
  connectedCallback() {

        loadScript(this, momentForTime)
        this.isLoading = true;
        getPermanencyProgressRec({casePlanVersionId : this.recordId})
        .then(result =>{
            
            let res = JSON.parse(result);
            this.permanencyProgressRecord = this.checkNamespaceApplicable(res.PermanencyProgressRecord, false);
            this.permanencyPlanRecord = this.checkNamespaceApplicable(res.PermanencyPlanRecord, false);
            this.AssessmentRecords = this.checkNamespaceApplicable(res.assessmentRecordList, false);
            this.childRemovalRec = this.checkNamespaceApplicable(res.childRemovalRecord, false);
            this.incomeRecord = this.checkNamespaceApplicable(res.incomeRecord, false);
            this.assetRecord = this.checkNamespaceApplicable(res.assetRecord, false);
            this.initialExamRecords = this.checkNamespaceApplicable(res.initialExamList, false);
            this.finalExamRecords = this.checkNamespaceApplicable(res.finalExamList, false);
            this.followupExamRecords = this.checkNamespaceApplicable(res.followupExamList, false);
			this.educationRecords = this.checkNamespaceApplicable(res.educationRecords, false);
            this.faceToFaceRecords = this.checkNamespaceApplicable(res.faceToFaceVisitsList, false);
            this.medicationRecords = this.checkNamespaceApplicable(res.medicationRecords, false);
            this.assessmentCompletedDates = res.assessmentRecordCompletedDate;
            this.Child_Support_Referral_Date = this.permanencyProgressRecord.Child_Support_Referral_Date__c;
            if(this.AssessmentRecords.length) {
                this.showAssessmentTable = true;
            }
            if(this.initialExamRecords.length) {
                this.showInitialExamTable = true;
            }
            if(this.finalExamRecords.length) {
                this.showFinalExamTable = true;
            }
            if(this.followupExamRecords.length) {
                this.showFollowupExamTable = true;
            }
            if(this.educationRecords.length) {
                this.showEducationTable = true;
            }
            if(this.incomeRecord.length) {
                this.showIncomeTable = true;
            }
            if(this.assetRecord.length) {
                this.showAssetTable = true;
            }
            if (this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress != null) {
                let address = '';
                address=(this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.street ? address+this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.street : address);
                address=(this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.city ? address+','+this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.city : address);
                address=(this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.state ? address+','+this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.state : address);
                address=(this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.country ? address+','+this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.country : address);
                address=(this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.postalCode ? address+','+this.permanencyProgressRecord.Placement__r.Provider__r.BillingAddress.postalCode : address);
                this.locationAddress = address;
            } else {
                let address = '';

            }
            for(let r=0; r<this.AssessmentRecords.length; r++) {

                let foundelement = this.assessmentCompletedDates.find(ele => ele.TargetObjectId == this.AssessmentRecords[r].Id);
                if (foundelement) {
                    this.AssessmentRecords[r].completedDate = moment(foundelement.CompletedDate).format('MM/DD/YYYY hh:mm A');
                }
            }
            this.showPermanencyProgress = true;

            
            if (this.permanencyProgressRecord.Placement__r.Placement_Structure__c.includes("Treatment Fostercare Care")) {
                this.permanencyProgressRecord.TreatmentFostercare = "Yes";
            } else {
                this.permanencyProgressRecord.TreatmentFostercare = "No";
            }

            if(this.permanencyPlanRecord.If_the_Permanency_plan_is_to_return_home__c) {
                this.permanencyPlanRecord.If_the_Permanency_plan_is_to_return_home__c = "Yes";
            } else {
                this.permanencyPlanRecord.If_the_Permanency_plan_is_to_return_home__c = "No";
            }

            for(let i=0;i<this.AssessmentRecords.length;i++) {

                if (this.AssessmentRecords[i].Assessment_Type__c == 'SAFE-C'){

                    if(this.AssessmentRecords[i].SAFEC_Child_is_conditionally_Safe__c) {

                        this.AssessmentRecords[i].Outcome = "Child is Safe (Influences 1-18 Marked No)";

                    }else if(this.AssessmentRecords[i].SAFEC_Child_is_Conditionally_Safe_17_16__c) {

                        this.AssessmentRecords[i].Outcome = "Child is Conditionally Safe (Any Influences 17-18 is Checked Yes All Actions in A Required Case     Staffing Have Been Implemented)";

                    }else if(this.AssessmentRecords[i].SAFEC_Child_is_Safe_Influences_1_18__c) {

                        this.AssessmentRecords[i].Outcome = "Child is conditionally Safe (Any Influences 1-16 is Checked And There is A completed Safety Plan That is Signed by All Parties)";

                    }else if(this.AssessmentRecords[i].SAFEC_Child_is_UnSafe__c) {

                        this.AssessmentRecords[i].Outcome = "Child is UnSafe";

                    }
                } else if(this.AssessmentRecords[i].Assessment_Type__c == 'SAFE-C-OHP') {

                        if(this.AssessmentRecords[i].OHP_Child_is_Unsafe_Any_Influence_1_12__c) {
    
                            this.AssessmentRecords[i].Outcome = "Child is Unsafe (Any Influence 1-12 Was checked 'NO')";
    
                        }else if(this.AssessmentRecords[i].OHP_Child_is_Safe_Influences_1_12_Marked__c) {
    
                            this.AssessmentRecords[i].Outcome = "Child is Safe (Influences 1-12 Marked 'YES')";
                        }

                } else if(this.AssessmentRecords[i].Assessment_Type__c == 'Family risk Reassessment') {

                        this.AssessmentRecords[i].Outcome = this.AssessmentRecords[i].RISK_LEVEL__c;

                } else if(this.AssessmentRecords[i].Assessment_Type__c == 'Family Initial Risk Assessment') {

                        this.AssessmentRecords[i].Outcome = this.AssessmentRecords[i].FINAL_RISK_LEVEL__c
                }
            }
            this.isLoading = false;
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

    handleChange(event) {

        let fieldType = event.target.type;
        let value = event.target.value;

        if (fieldType != 'checkbox') {
            
            this.permanencyProgressRecord[event.target.name] = event.target.value;
        } else {

            this.permanencyProgressRecord[event.target.name] = event.target.checked;
        }
    }

    handleSave() {

        updatePermanencyProgressRec({permanencyProgressDataJSON : JSON.stringify(this.checkNamespaceApplicable(this.permanencyProgressRecord, true))})
        .then(res =>{

            this.title = "Success!";
            this.type = "success";
            this.message = "Record Updated Successfully!";
            this.fireToastMsg();

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