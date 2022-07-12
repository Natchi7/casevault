import { LightningElement, api, track } from 'lwc';
import getNotesInitialInformation from '@salesforce/apex/ContactNotesController.getNotesInitialInformation';
import createNotesRec from '@salesforce/apex/ContactNotesController.createNotesRecord';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import createContentVersion from '@salesforce/apex/ContactNotesController.createContentVersion';
import getRelatedFilesByRecordId from '@salesforce/apex/CourtOrderController.getRelatedFilesByRecordId';
import { NavigationMixin } from 'lightning/navigation';
import deleteNotesRecord from'@salesforce/apex/ContactNotesController.deleteNotesRecord'
import getNotesHistories from '@salesforce/apex/ContactNotesController.getNotesHistories';
import createQualityCareRecord from '@salesforce/apex/ContactNotesController.createQualityCareRecord';
import getQualityOfCareRecord from '@salesforce/apex/ContactNotesController.getQualityOfCareRecord';
import TIME_ZONE from '@salesforce/i18n/timeZone';


const actions = [
    { label: 'Preview', name: 'preview' },
    { label: 'Edit', name: 'edit' },
    { label : 'Delete', name :'delete'},
    { label : 'Quality of Care', name :'qualityOfCare'},
    { label : 'Notes', name : 'notes'},
    { label : 'History', name : 'history'}
];

const notesColumn = [ { label : 'Contact Date', fieldName: 'Contact_Date__c', type: 'date', typeAttributes : {day:"numeric",month:"numeric",year:"numeric",timeZone:"UTC"}},
                      { label : 'Date of Entry', fieldName : 'CreatedDate', type: 'date', typeAttributes : {day:"numeric",month:"numeric",year:"numeric",timeZone:"UTC"}},
                      { label : 'Entered By', fieldName : 'OwnerName', type : 'text', wrapText : true},
                      //{ label : 'Date of Entry & Entered By', fieldName : 'dateOfEntryEnteredBy', type:'text', wrapText : true},
                      { label : 'Contact Purpose' , fieldName : 'Contact_Purpose__c', type:'text', wrapText : true},
                      { label : 'Contact Details', fieldName : 'contactDetails', type: 'text', wrapText : true},
                      { label : 'Person Contacted', fieldName : 'Involved_Persons__c', type:'text', wrapText : true},
                      {
                        type: 'action',
                        typeAttributes: { rowActions: actions },
                    }];
const documentColumn = [{ label:'Document Name', fieldName : 'label'},
                        { label:'Action', type:'button',
                            typeAttributes : { label : 'Preview',variant: 'brand' , name:'preview'}
                        }];

export default class ContactNotesTab extends NavigationMixin(UtilityBaseElement) {
    @api recordId;
    @api objectApiName;
    @track showHistoryTable = false;
    @track contactPurposePick = [];
    @track contactTypePick = [];
    @track contactLocationPick = [];
    @track contactPersonsPick = [];
    @track notes ='' ;
    @track contactInitiatedPick = [];
    @track contactAttemptedPick = [];
    @track documentList = [];
    @track notesRec ={};
    @track notesList = [];
    @track showNotesModal = false;
    @track personInvolvedValues = [];
    @track contactPurposeValues =[];
    @track readOnly = false;
    documentColumn=documentColumn;
    @track loading = false;
    @track source = '';
    @track showTable = false;
    @track contentDocumentIdList =[];
    @track handleEnableSave = false;
    @track notesHistoryList = [];
    @track showNotesCommentModal = false;
    @track notesCommentVal = '';
    @track qualityRec = {};
    @track showQuliatyModal = false;
    @track personRoleList = [];
    @track fileData = {};
    get notesTitle() {
        if(this.notesList) {
            return 'Notes ('+this.notesList.length+')';
        } else{
            return 'Notes';
        }
    }
    notesColumn = notesColumn;
    timeZone = TIME_ZONE;

    connectedCallback(){
        this.doInit();
    }

    doInit() {
        this.getNotesInital();
        loadScript(this, momentForTime)
        if(this.objectApiName == 'Case') {
            this.notesRec.Intake__c = this.recordId;
            this.source = 'Intake';
        } else if(this.objectApiName == 'Service_Case__c') {
            this.notesRec[this.objectApiName] = this.recordId;
            this.source = 'Service Case';
        } else if(this.objectApiName == 'Investigation__c') {
            this.notesRec[this.objectApiName] = this.recordId;
            this.source = 'Investigation';
        }
    }

    getNotesInital() {
        getNotesInitialInformation({recordId :this.recordId})
        .then(res=>{
            let result = JSON.parse(res);
            this.contactPurposePick = result.contactPurposePicklist;
            this.contactTypePick = result.contactTypePicklist;
            this.contactLocationPick = result.contactLoactionPicklist;
            this.contactPersonsPick = result.involvedPersonPicklist;
            this.contactInitiatedPick  = result.contactInitiatedPicklist;
            this.contactAttemptedPick = result.contactAttemptedPicklist; 
            if(result.contactList) {
                this.personRoleList = result.contactList;
            }
            if(result.notesList.length > 0){
                this.notesList = this.checkNamespaceApplicable(result.notesList,false);
                for(let i=0; i<this.notesList.length; i++) {
                    
                   
                    if(this.notesList[i].Owner.Name) {
                        this.notesList[i].OwnerName = this.notesList[i].Owner.Name;
                    }

                    

                    this.notesList[i].contactDetails = 'Type of Contact :';
                    if(this.notesList[i].Contact_Type__c) {
                        this.notesList[i].contactDetails =  this.notesList[i].contactDetails  +this.notesList[i].Contact_Type__c + '\n';
                    } else if (!this.notesList[i].Contact_Type__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + '\n';
                    }
                    this.notesList[i].contactDetails = this.notesList[i].contactDetails  + 'Contact Location :';
                    if(this.notesList[i].Contact_Location__c) {
                        this.notesList[i].contactDetails =  this.notesList[i].contactDetails  +this.notesList[i].Contact_Location__c + '\n';
                    } else if (!this.notesList[i].Contact_Location__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + '\n';
                    }
                    this.notesList[i].contactDetails = this.notesList[i].contactDetails  + 'Contact :';
                    if(this.notesList[i].Contact_was_Attempted_Completed__c) {
                        this.notesList[i].contactDetails =  this.notesList[i].contactDetails  +this.notesList[i].Contact_was_Attempted_Completed__c + '\n';
                    } else if (!this.notesList[i].Contact_was_Attempted_Completed__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + '\n';
                    }


                    
                }
                this.showTable =true;
            } else{
                this.showTable =false;
            }

        })
    }

    handleQualityChange(event) {
        let fieldname = event.target.name;
        let value = event.target.value;
        let type= event.target.type;
        if(type != 'checkbox'){
            this.qualityRec[fieldname] = value;
        }
    }

    handleChange(event) {
        let fieldname = event.target.name;
        let value = event.target.value;
        let type= event.target.type;
        if(type != 'checkbox'){
            
            if(fieldname =='Contact_Purpose__c'){
                let contactPurpose = value.join(';');;
                this.notesRec[fieldname] = contactPurpose;
            }else if(fieldname =='Involved_Persons__c'){
                let persons = value.join(';');;
                this.notesRec[fieldname] = persons;
            } else{
                this.notesRec[fieldname] = value;
            }
        } else{
            this.notesRec[fieldname] = event.target.checked;
        }
    }

    hadleQualitySave(event){
        createQualityCareRecord({qualityJOSN: JSON.stringify(this.checkNamespaceApplicable(this.qualityRec,true))})
        .then(result =>{
            this.getNotesInital();
            this.title = 'Success!';
            this.type = 'success';
            this.message = 'Record created successfully';
            this.fireToastMsg();
            this.showQuliatyModal=false;
            this.loading=false;
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
        })
    
    }

    handleSave(event) {
       
        if(!this.onValidate() && this.notesRec.Notes__c != null) {
            this.loading=true;
            this.notesRec.Source__c = this.source;
            let setpersonrole = [];
            if(this.notesRec.Involved_Persons__c) {
                let persons = this.notesRec.Involved_Persons__c.split(';');
                for(let i = 0; i < this.personRoleList.length; i++) {
                    if(persons.find(element => element == this.personRoleList[i].Name)){
                        setpersonrole.push(this.personRoleList[i].Intake_Person_Role__c);
                    }
                }
            }
            if(setpersonrole.length > 0) {
                this.notesRec.Person_Role__c = setpersonrole.join(';');
            } else {
                this.notesRec.Person_Role__c = '';
            }
            createNotesRec({notesJOSN:JSON.stringify(this.checkNamespaceApplicable(this.notesRec,true)), contentDocumentIds : this.contentDocumentIdList})
            .then(res => {
                this.getNotesInital();
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record created successfully';
                this.fireToastMsg();
                this.showNotesModal=false;
                this.loading=false;
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
            })
        } else {
            this.title="Error!";     
            this.type="error";
            this.message='Complete the required field(s).';
            this.fireToastMsg();
        }
    }    

    addNewNotes(event) {
        this.notesRec = {};
        this.readOnly=false;
        this.contentDocumentIdList = [];
        if(this.objectApiName == 'Case') {
            this.notesRec.Intake__c = this.recordId;
        } else {
            this.notesRec[this.objectApiName] = this.recordId;
        }
       
        this.personInvolvedValues = [];
        this.contactPurposeValues = [];
        this.documentList = [];
        this.fileData = {};

        this.showNotesModal = true;
    }

    closeNotesModal(event) {
        this.showNotesModal = false;
        this.loading= false;
    }

    handleViewModal(row) {

        this.notesRec = row;
        this.readOnly=true;
        this.showNotesModal = true;
        this.personInvolvedValues = this.notesRec.Involved_Persons__c.split(';');
        this.contactPurposeValues = this.notesRec.Contact_Purpose__c.split(';');
        this.notes = this.notesRec.Notes__c.replace(/<[^>]+>/g, '');
        this.getFiles();

    }

    handleEditModal(row) {
        this.notesRec =row;
        this.readOnly = false;
        this.showNotesModal = true;
        this.personInvolvedValues = this.notesRec.Involved_Persons__c.split(';');
        this.contactPurposeValues = this.notesRec.Contact_Purpose__c.split(';');
        this.getFiles();
    }

    handleDeleteRec(row) {

        //let index = event.target.name.Id;
        let notesRec = row;
        //this.notesList.splice(index,1);
        deleteNotesRecord({notesJOSN:JSON.stringify(this.checkNamespaceApplicable(notesRec,true))})
        .then(res => {
            this.getNotesInital();
            this.title = 'Success!';
            this.type = 'success';
            this.message = 'Record Deleted successfully';
            this.fireToastMsg();
            this.loading=false;
            this.doInit();
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
        })

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

    getFiles() {

        this.loading = true;
        getRelatedFilesByRecordId({recordId : this.notesRec.Id})
        .then( result => {
            if(result != null) {
                this.documentList = Object.keys(result).map(item => ({
                    "label":result[item],
                    "value": item
                    
                }))
            }
           
            if(this.documentList.length) {
                this.showFiles = true;
            }
            this.loading = false;
            
        }).catch(error => {
            this.errorMessage(error);
        })
    }

    openfileUpload(event) {

        const file = event.target.files[0]
        var reader = new FileReader();
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
            }
            this.loading = true;
            createContentVersion({base64:this.fileData.base64 , filename:this.fileData.filename})
            .then(result => {
                this.contentDocumentIdList.push(result);
                this.title = "Success!";
                this.type = "success";
                this.message = 'File uploaded Successfully';
                this.fireToastMsg();
                this.loading = false;
            }) .catch(error => {
                this.errorMessage(error);
            })
        }
        
        reader.readAsDataURL(file); 

    }
    handleFileRowAction(event) {

        let filerow = event.detail.row;
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: filerow.value
            }
        })
    }

    showHistory(row){
        let choosenNotesRecId = row.Id;
        getNotesHistories({notesRecId : choosenNotesRecId })
        .then(result=>{
            let res = JSON.parse(result);
            this.notesHistoryList = this.checkNamespaceApplicable(res.notesHistoryList, false);
            if(this.notesHistoryList.length > 0) {
                for(let i=0; i<this.notesHistoryList.length; i++) {
                    this.notesHistoryList[i].Modified_Date__c = moment(this.notesHistoryList[i].Modified_Date__c).format('MM/DD/YYYY hh:mm A');
                    //this.notesHistoryList[i].Notes_Comments__c = this.notesHistoryList[i].Notes_Comments__c.replace(/<[^>]+>/g, '');
                }
                this.showHistoryTable = true;
            } else{
                this.showHistoryTable =false;
            }
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
        })
    }
     closeHistoryModal(event){
        this.showHistoryTable =false;
     }

     showNotes(row) {
         this.notesCommentVal = row.Notes__c;
         this.showNotesCommentModal = true;
     }
     closeNotesCommentModal(event){
         this.showNotesCommentModal = false
     }
     handleQualityModal(row){
         this.showQuliatyModal= true;
         let notesId = row.Id;
         this.qualityRec.Notes__c = notesId;
         getQualityOfCareRecord({notesRecId: notesId})
         .then(result=>{
            let res = JSON.parse(result);
            this.qualityRec = this.checkNamespaceApplicable(res.qualityOfCareRec, false);
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
        })
        

     }
     closeQualityModal(event){
        this.showQuliatyModal= false;

     }

     handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'preview':
                this.handleViewModal(row);
                break;
            case 'edit':
                this.handleEditModal(row);
                break;
            case 'delete':
                this.handleDeleteRec(row);
                break;
            case 'qualityOfCare':
                this.handleQualityModal(row);
                break;
            case 'notes':
                this.showNotes(row);
                break;
            case 'history':
                this.showHistory(row);
                break;
            default:
        }
    }
}