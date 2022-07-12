import { LightningElement, track, api } from 'lwc';
import getBreakthelinkRec from '@salesforce/apex/PermanacyPlanAdoptionController.getBreakthelinkRecord';
import updateBreaktheLinkRec from '@salesforce/apex/PermanacyPlanAdoptionController.updateBreaktheLinkRec';
import onSubmitForApproval from '@salesforce/apex/PermanacyPlanAdoptionController.onSubmitForApproval';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import { loadScript } from 'lightning/platformResourceLoader';
import UtilityBaseElement from 'c/utilityBaseLwc';

const actions = [
    { label: 'View', name: 'preview', iconName:'utility:preview'},
    
];
const columns = [
    { label: 'ADOPTION PLAN BEGIN DATE', fieldName: 'adoptionPlanBeginDate', type: 'string'},
    { label: 'LEGALLY FREE', fieldName: 'childislegallyfree', type: 'boolean'},
    { label: 'ADOPTIVE PLACEMENT', fieldName: 'approvedpreadoptive', type: 'boolean'},
    { label: 'ADOPTIVE FINALIZATION', fieldName: 'adoptionfinalized', type: 'boolean'},
    { label: 'CASE CREATION DATE', fieldName: 'casecreationdate', type: 'string'},
    { type: 'action', typeAttributes: { rowActions: actions} }
    
];

export default class PermanencyPlanBreaktheLink extends UtilityBaseElement {

    @api permanencyRecId;
    @track showBreaklinkModal = false;
    @track readOnly = true;
    disablebutton = false;
    @track breaktheLinkRec = {};
    loading = false;
    adoptionPlanBeginDate;
    disclosureApprovalStatus;
    @track tprList = [];
    tprDateofParent1;
    tprDateofParent2;
    @track placement= {};
    showTable = false;
    @track courtRec = {};
    providerName;
    placementStructure;
    beginDate;
    endDate;
    approvalStatus;
    showApprovalScreen = false;
    supervisorId;
    enableSubmit = true;
    @track breakList = [];
    columns = columns;

    connectedCallback() {
        this.loading = true;
        this.breaktheLinkRec.Id = this.permanencyRecId;
        this.doInitInfo();
    }

    doInitInfo() {

        loadScript(this, momentForTime)
        getBreakthelinkRec({ permanencyPlanId : this.permanencyRecId})
        .then( result => {

            this.breaktheLinkRec.Child_is_Legally_free__c = false;
            this.breaktheLinkRec.Child_was_in_an_Approved_Pre_Adoptive__c = false;
            this.breaktheLinkRec.Adoption_has_been_finalized__c = false;
            this.showTable = false;
            let res = JSON.parse(result);
            if(res.breaktheLinkRecord != null) {
            
                    this.breaktheLinkRec = this.checkNamespaceApplicable(res.breaktheLinkRecord , false);
                    this.adoptionPlanBeginDate = this.breaktheLinkRec.Adoption_Plan_Begin_Date__c;
                    this.disclosureApprovalStatus = this.breaktheLinkRec.Disclosure_Approval_Status__c;
                    if(this.breaktheLinkRec.Date_Agreement_signed__c) {
                        this.showTable = true;
                        
                    } 
                    
                    
            }
            if(res.tpRList) {

                this.breaktheLinkRec.Child_is_Legally_free__c = true;
                this.tprList = this.checkNamespaceApplicable(res.tpRList, false);
                if(this.tprList.length == 1) {
                    this.tprDateofParent1 = this.tprList[0].TPR_Decision_Date__c;
                } else if(this.tprList.length == 2) {
                    this.tprDateofParent1 = this.tprList[0].TPR_Decision_Date__c;
                    this.tprDateofParent2 = this.tprList[1].TPR_Decision_Date__c;
                }
            }
            if(res.placementRec) {
                
                this.placement = this.checkNamespaceApplicable(res.placementRec, false);
                this.providerName = this.placement[0].Provider__r.Name;
                this.placementStructure = this.placement[0].Placement_Structure__c;
                this.beginDate = this.placement[0].Begin_Date__c;
                this.endDate = this.placement[0].End_Date__c;
                this.approvalStatus = this.placement[0].Placement_Approval_Status__c;
                if(this.endDate != null) {
                    this.breaktheLinkRec.Child_was_in_an_Approved_Pre_Adoptive__c = true;
                } else {
                    this.breaktheLinkRec.Child_was_in_an_Approved_Pre_Adoptive__c = false;
                }
            }
            if(res.courtHearingRec) {

                let rec = this.checkNamespaceApplicable(res.courtHearingRec, false);
                this.courtRec = rec[0];
                if(this.courtRec.Court__r.Court_Order_Date__c) {
                    this.breaktheLinkRec.Adoption_has_been_finalized__c = true;
                }
            }

            if(res.subSidyRecList) {

                this.breaktheLinkRec.Subsidy_Rate_Approval_Status__c = 'Approved';
            }

            this.breakList = [{
                'Id' : this.breaktheLinkRec.Id,
                'adoptionPlanBeginDate' : this.breaktheLinkRec.Adoption_Plan_Begin_Date__c,
                'childislegallyfree' : this.breaktheLinkRec.Child_is_Legally_free__c,
                'approvedpreadoptive' : this.breaktheLinkRec.Child_was_in_an_Approved_Pre_Adoptive__c,
                'adoptionfinalized' : this.breaktheLinkRec.Adoption_has_been_finalized__c,
                'casecreationdate' : this.breaktheLinkRec.Case_Creation_Date__c
            }];
            for (let i=0;i<this.breakList.length;i++) {
                 if (this.breakList[i].adoptionPlanBeginDate) {
                    this.breakList[i].adoptionPlanBeginDate = moment(this.breakList[i].adoptionPlanBeginDate).format('MM/DD/YYYY');
                 }
                 if (this.breakList[i].casecreationdate) {
                    this.breakList[i].casecreationdate = moment(this.breakList[i].casecreationdate).format('MM/DD/YYYY');
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

    handleAddBreaklink() {
       
        this.readOnly = false;
        this.disablebutton = false;
        this.showBreaklinkModal = true;

    }

    closeBreaklinkModal() {

        this.showBreaklinkModal = false;

    }

    handleChange(event){
        
        let fieldType = event.target.type;
        let name = event.target.name;
        let value = event.target.value;
        if (fieldType != 'checkbox') {
            this.breaktheLinkRec[name] = value;
        } else {
            this.breaktheLinkRec[name] = event.target.checked;
        }
    }

    handleSave() {

        if(this.breaktheLinkRec.Child_is_Legally_free__c != true || this.breaktheLinkRec.Child_was_in_an_Approved_Pre_Adoptive__c  != true || this.breaktheLinkRec.Adoption_has_been_finalized__c != true ) {

            this.title = "Error!";
            this.type = "error";
            this.message = 'Record does not meet the required criteria';
            this.fireToastMsg();
        }


        else if(!this.onValidate()) {

                updateBreaktheLinkRec({breakthelinkRecord : JSON.stringify(this.checkNamespaceApplicable(this.breaktheLinkRec, true))})
                .then(res=> {
                    this.showBreaklinkModal = false;
                    this.title ="Success!";
                    this.type ="success";
                    this.message = "Break the Link Record Update Successfully";
                    this.fireToastMsg();
                    this.loading = true;
                    this.doInitInfo();
                }).catch(error => {

                this.loading=false;
                this.showBreaklinkModal = false;
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
            this.title ="Error!";
            this.type ="error";
            this.message = "Complete Required Fields";
            this.fireToastMsg();

        }
    }

    handleViewModal() {
        
        this.readOnly = true;
        this.showBreaklinkModal = true;
        this.disablebutton = true;
            
    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId?false:true;
    }

    submitforApproval() {

        if(this.breaktheLinkRec.Break_Line_Approval_Status__c == 'Approved') {

            this.title ="Error!";
            this.type ="error";
            this.message = "Break the link Record Already Approved";
            this.fireToastMsg();
        } else if(this.breaktheLinkRec.Break_Line_Approval_Status__c == 'Submitted') {

            this.title ="Error!";
            this.type ="error";
            this.message = "Break the link Record Submitted for Approval";
            this.fireToastMsg();
        } else {

            this.handleSave();
            setTimeout(() => {
                this.submit();
            }, 2000);
            
        }
        
    }

    submit() {

        if( this.showBreaklinkModal == false) {
            this.showApprovalScreen = true;
        }
               
    }

    hideApprovalScreen() {

        this.showApprovalScreen = false;
    }


    submitApproval() {

        onSubmitForApproval({permanencyRecId:this.permanencyRecId,selectedSupervisorUserId:this.supervisorId})
        .then(result => {
            this.title ="Success!";
            this.type ="success";
            this.message = "Break the link Record Submitted for Approval";
            this.fireToastMsg();
            this.showApprovalScreen = false;
            this.loading = true;
            this.doInitInfo();
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

    handleRowAction(event) {

        const action = event.detail.action;
        switch (action.name) {
            case 'preview': 
                this.handleViewModal();
                break;
        }
    }
}