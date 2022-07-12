import { LightningElement, track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitInfo from '@salesforce/apex/ServicePlanController.getIntiVisitationInfo';
import createVisitationPlanRec from '@salesforce/apex/ServicePlanController.createVisitationPlanRecord';
import deleteRecord from '@salesforce/apex/ServicePlanController.deleteVisitationPlanRec';
import updateRecord from '@salesforce/apex/ServicePlanController.createVisitationPlanRecord';


const actions =[{label: 'View', name: 'view'},
                {label: 'Edit', name: 'edit'},
                {label: 'Delete', name: 'delete'},];

const columns= [{ label: 'CLIENT NAME', fieldName: 'clientName', type: 'string', wrapText: true},
    { label: 'ESTABLISHED DATE', fieldName: 'Established_Date__c', type: 'date', wrapText: true,typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric",timeZone:"UTC"
    }},
    { label: 'END DATE', fieldName: 'End_Date__c', type: 'date', wrapText: true,typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric",timeZone:"UTC"
    }},
    { type: 'action', typeAttributes: { rowActions: actions} }
];
export default class VisitationPlansLwc extends UtilityBaseElement {

    @api recordId;
    @track clientPickList = [];
    @track personInvolvedPicklist = [];
    @track conditionsPicklist = [];
    @track frequencyPicklist = [];
    @track visitorTransportationPicklist = [];
    @track childTransportationPicklist = [];
    @track visitDurationPicklist = [];
    @track openAddVisitationPlan = false;
    @track visitationRecord = {};
    @track visitationRecordList =[];
    @track readyOnly = false;
    @track showSave = true;
    @track showUpdate = false;
    columns = columns;
    clientName;
    @track selected = [];
    @track getSelected = [];
    connectedCallback() {

        this.doInitInfo();
    }

    doInitInfo() {

        getInitInfo({servicePlanId : this.recordId})
        .then(result => {
            let res = JSON.parse(result);
            this.clientPickList = res.clientPicklist;
            this.personInvolvedPicklist = res.personInvolvedPicklist;
            this.conditionsPicklist = res.conditionsPicklist;
            this.frequencyPicklist = res.frequencyPicklist;
            this.visitorTransportationPicklist = res.visitorTransportationPicklist;
            this.childTransportationPicklist = res.childTransportationPicklist;
            this.visitDurationPicklist = res.visitDurationPicklist;
            this.visitationRecordList = this.checkNamespaceApplicable(res.visitationPlanList, false);
            this.visitationRecord.Service_Plan__c = this.recordId;
            for(let i =0; i<this.visitationRecordList.length;i++){
                if(this.visitationRecordList[i].Client__c != null) {
                    this.visitationRecordList[i].clientName = this.visitationRecordList[i].Client__r.Name;
                }
            }
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
    handleAddVisitationPlan() {

        this.visitationRecord = {};
        this.getSelected = [];
        this.readyOnly = false;
        this.showSave = true;
        this.showUpdate = false;
        this.openAddVisitationPlan = true;
    }
    handleChange(event) {

        let fieldType = event.target.type;
        let name = event.target.name;
        let value = event.target.value;
        if (fieldType != 'checkbox' && name != 'Person_involved__c') {
            this.visitationRecord[name] = value;

        } else if(name == 'Person_involved__c') {
            this.selected = value;
        } else if(name != 'Person_involved__c'){

            this.visitationRecord[name] = event.target.checked;
        }

    }
    handleSave(){

        if(!this.onValidate()) {
        this.visitationRecord.Service_Plan__c = this.recordId;
        this.visitationRecord.Person_involved__c = this.selected.join(';');
        createVisitationPlanRec({visitionPlanJSON : JSON.stringify(this.checkNamespaceApplicable(this.visitationRecord,true))})
        .then(result =>{
            this.doInitInfo();
            this.openAddVisitationPlan = false;
             this.title = 'Success!';
             this.type = 'success';
             this.message = 'Record created successfully';
             this.fireToastMsg();
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
    }
    handleCancel() {
        this.openAddVisitationPlan = false;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'view': 

                if(row.Person_involved__c != null) {
                    this.getSelected =row.Person_involved__c.split(';');
                }else {
                    this.getSelected = [];
                }
                this.handleView(row);
                break;
            case 'edit': 

                if(row.Person_involved__c != null) {
                    this.getSelected =row.Person_involved__c.split(';');
                } else {
                    this.getSelected = [];
                }
                this.handleEdit(row);
                break;

            case 'delete': 

                this.handledelete(row);
                break;
        }
    }
    handleView(row) {

        this.showSave = false;
        this.showUpdate = false;
        this.visitationRecord = row;
        this.readyOnly = true;
        this.openAddVisitationPlan = true;
    }

    handleEdit(row) {
        this.showSave = false;
        this.showUpdate = true;
        this.visitationRecord = row;
        this.readyOnly = false;
        this.openAddVisitationPlan = true;
    }

    handledelete(row) {

        deleteRecord({visitionPlanRec : JSON.stringify(this.checkNamespaceApplicable(row,true))})
        .then(result =>{
            this.openAddVisitationPlan = false;
             this.title = 'Success!';
             this.type = 'success';
             this.message = 'Record Deleted successfully';
             this.fireToastMsg();
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

    
}