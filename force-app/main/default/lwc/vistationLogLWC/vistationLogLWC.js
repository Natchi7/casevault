import { LightningElement, track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitiInfo from '@salesforce/apex/VisitationLogController.getInitialInformation';
import addnewVisitLog from '@salesforce/apex/VisitationLogController.createVisitationLogRecord';
import deleteVisitationRec from '@salesforce/apex/VisitationLogController.deleteVisitationRec';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}]
const columns = [
    { label: 'Client Name', fieldName: 'client', type:'String' , wrapText : true},
    { label: 'Date of Visit', fieldName: 'Visit_Date__c', type:'date', typeAttributes : { day:'numeric',month:'numeric',year:'numeric',timeZone:'UTC'}},
    { label: 'Court Ordered', fieldName: 'Court_Ordered__c', type:'String',  wrapText : true },
    { label: 'Status', fieldName: 'Status__c',type:'String', wrapText : true },
    //{ label: 'Participants', fieldName: 'Persons_Involved__c',type:'String' },
    { label: 'Comments', fieldName: 'Comments__c',type:'String',  wrapText : true },
    {label:'Location', fieldName:'Location__c', type:'String',  wrapText : true},
    {label:'Conditions', fieldName:'Conditions__c',type:'String',  wrapText : true},
    { type: 'action', typeAttributes: { rowActions: actions} }
];
export default class VistationLogLWC extends UtilityBaseElement {
    @track showAddnew = false;
    @track columns=columns;
    @track VistationLog = {};
    @api recordId;
    @api objectApiName;
    @track clientPickOptions = [];
    @track personPickOptions = [];
    @track statusPickOptions = [];
    @track collateralVisitParticipantsOption = [];
    @track visitionLogList = [];
    @track personInvolvedValues = [];
    @track collateralValues = [];
    @track clientName='';
    @track @track conditionPicklist = [];
    get visitationLogTitle() {
        if(this.visitionLogList) {
            return 'Visitation Log ('+this.visitionLogList.length+')';
        } else{
            return 'Visitation Log';
        }
    }
    connectedCallback() {
        this.doInit();
    }

    doInit(){
        
        getInitiInfo({servicecaseId:this.recordId})
        .then(result => {
            let res = JSON.parse(result);
            this.statusPickOptions = res.statusPicklist;
            this.clientPickOptions = res.clientPicklist;
            this.personPickOptions = res.personInvolvedPicklist;
            this.conditionPicklist = res.conditionPicklist.slice(1);
            this.collateralVisitParticipantsOptions = res.collateralVisitParticipantsPicklist;
            this.visitionLogList = this.checkNamespaceApplicable(res.visitationLogList,false);
            
            if(this.visitionLogList.length) {

                for(let i=0;i<this.visitionLogList.length;i++) {
                    let row = this.visitionLogList[i];
                    row.client = row.Client__r.Name;
                  
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

    showNew(event){
        this.VistationLog = {};
        if(this.objectApiName == 'Case') {
            this.VistationLog.Intake__c = this.recordId;
        } else {
            this.VistationLog[this.objectApiName] = this.recordId;
        } 
      
        this.personInvolvedValues = [];
        this.collateralValues = [];
        this.showAddnew = true;    
    }
    closeModal(event) {
        this.showAddnew= false;
    }
    handleChange(event) {
        let fieldName = event.target.name;
        let value = event.target.value;
        let type = event.target.type;
        let checked = event.target.checked;
        if(type != 'checkbox'  ) {
            if(fieldName =='Persons_Involved__c' ){
                let personInvoleMuti = value.join(';');
                this.VistationLog[fieldName] = personInvoleMuti;
            } else if(fieldName =='Collateral_Visit_Participants__c') {
                let collateralMulti = value.join(';');
                this.VistationLog[fieldName] = collateralMulti;
            }
            else{
                this.VistationLog[fieldName] = value;
            }
        } else {
                this.VistationLog[fieldName] = checked;
        }
    }
    addVistionlog(event) {
        if(!this.onValidate()) {
            addnewVisitLog({visitionLogJOSN:JSON.stringify(this.checkNamespaceApplicable(this.VistationLog,true))
            }).then(result =>{
                this.doInit();
                this.showAddnew= false;
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
        } else {
            this.title="Error!";     
            this.type="error";
            this.message='Complete the required field(s).';
            this.fireToastMsg();
        }
        
    }
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit': 
                this.handleEdit(row);
                break;
            case 'delete': 
                this.handleDelete(row);
                break;
        };
    }
    handleEdit(row){

        this.loading = true;
        let id = row.Id;
        this.VistationLog = {};
        for(let i=0; i<this.visitionLogList.length; i++) {

            if(this.visitionLogList[i].Id == id) {
                this.VistationLog = this.visitionLogList[i];
                this.clientName = this.VistationLog.Client__r.Name;
                if(this.VistationLog.Persons_Involved__c != null) {
                    this.personInvolvedValues = this.VistationLog.Persons_Involved__c.split(';');
                } else if(this.VistationLog.Persons_Involved__c == null) {
                    this.personInvolvedValues = [];
                }
                if(this.VistationLog.Collateral_Visit_Participants__c != null) {
                    this.collateralValues = this.VistationLog.Collateral_Visit_Participants__c.split(';');
                } else if(this.VistationLog.Collateral_Visit_Participants__c == null) {
                    this.collateralValues = [];
                }
                this.showAddnew = true;
            }
        }
    }
    handleDelete(row) {
        const { id } = row;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
            this.visitionLogList = this.visitionLogList
                .slice(0, index)
                .concat(this.visitionLogList.slice(index + 1));
        }
                   
        deleteVisitationRec({delVisitationLogJSON:JSON.stringify(this.checkNamespaceApplicable(row,true))})
        .then(res=>{

            this.title ="Success!";
            this.type = "SUCCESS";
            this.message="Visitation Log Record deleted successfully.";
            this.fireToastMsg();
            this.doInit();
            
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

    findRowIndexById(id) {
        let ret = -1;
        this.visitionLogList.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

}