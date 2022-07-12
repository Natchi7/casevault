import { LightningElement, track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import actionsInit from '@salesforce/apex/ServicePlanController.getActionsInitialInfo';
import saveGoalAction from '@salesforce/apex/ServicePlanController.upsertGoalActions';


const actions = [
    { label: 'Edit', name: 'edit'}
    
];

const columns = [
    { label: 'ACTION NAME', fieldName: 'Name', type: 'text', wrapText:'true'},
    { label: 'PERSON BENEFITING', fieldName: 'Person_Benefitizing__c',type: 'text', wrapText:'true'},
    { label: 'PERSON RESPONSIBLE', fieldName: 'Person_Responsible__c', type: 'text', wrapText:'true' },
    { label: 'START DATE', fieldName: 'Start_Date__c', type: 'date', typeAttributes:{month:"numeric",year:"numeric",day:"numeric",timeZone:"UTC"}},
    { label: 'END DATE', fieldName: 'End_Date__c', type: 'date',typeAttributes:{month:"numeric",year:"numeric",day:"numeric",timeZone:"UTC"} },
    { label: 'ACTION STATUS', fieldName: 'Status__c', type: 'text', wrapText:'true' },
    { label: 'COMMENTS', fieldName: 'Comments__c', type: 'text', wrapText:'true'},
    { type: 'action', typeAttributes: { rowActions: actions} }
    
];

export default class GoalActionLWC extends UtilityBaseElement {

    @api recordId;
    @track actionList = [];
    columns = columns;
    @track actionRec = {};
    @track statusPicklistValue = [];
    @track personBenefitingPicklistValue = [];
    @track personResponsiblePicklistValue = [];
    showAddRecord = false;
    loading = false;
    @track selected = [];
    @track getSelected = [];

    connectedCallback() {

        this.doInit();
    }

    doInit() {

        this.loading = true;
        actionsInit({ recordId:this.recordId})
        .then(result => {

            let res = JSON.parse(result);
            this.statusPicklistValue = res.statusPicklist;
            this.personBenefitingPicklistValue = res.personBenefitingPicklist;
            this.personResponsiblePicklistValue = res.personResponsiblePicklist;
            this.actionList = this.checkNamespaceApplicable(res.goalActionRecords,false);
            this.showAddRecord = false;
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
        })
    }

    handleChange(event) {

        var targetname = event.target.name;
        var targetvalue = event.target.value;
        if(targetname != 'Person_Benefitizing__c') {

            this.actionRec[targetname] = targetvalue;
        } 
        else if(targetname == 'Person_Benefitizing__c') {

            this.selected = targetvalue;
            
        }
        
    }

    handleCancel() {

        this.showAddRecord = false;
    }

    handleAdd() {
        
        this.actionRec = {};
        this.getSelected = [];
        this.showAddRecord = true;
    }

    onValidate(){
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"),...this.template.querySelectorAll("lightning-combobox"),...this.template.querySelectorAll("lightning-textarea"),...this.template.querySelectorAll("lightning-dual-listbox")
            ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
            return !allValid;
    }

    handleSave() {

        if(!this.onValidate()) {
            this.actionRec.Goal_Objective__c = this.recordId;
            if(this.selected.length > 0) {
                this.actionRec.Person_Benefitizing__c = this.selected.join(';');
            }
            this.loading = true;
            saveGoalAction({goalActionJSON : JSON.stringify(this.checkNamespaceApplicable(this.actionRec,true))})
            .then(result => {

                this.loading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record created successfully';
                this.fireToastMsg();
                this.doInit();
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
            })
           
        }else {

            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        
        }
    }

    handleRowAction(event) {

        var name = event.detail.action.name;
        var selectedrow = event.detail.row;
        if(name == 'edit') {
            this.actionRec = selectedrow;
            if(selectedrow.Person_Benefitizing__c) {
                this.getSelected =selectedrow.Person_Benefitizing__c.split(';');
            }
            this.showAddRecord = true;
        }

    }
    
}