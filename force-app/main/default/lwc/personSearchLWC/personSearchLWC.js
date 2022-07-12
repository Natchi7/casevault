import { LightningElement, track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getContactDetail from '@salesforce/apex/PersonSearchController.getContacts';
import getPersonsIntakeInvSC from '@salesforce/apex/PersonSearchController.personsIntakeInvSC';
import { NavigationMixin } from 'lightning/navigation';

const personColumn = [
    { label: 'Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label: 'SSN', fieldName: 'SSN__c', type: 'text', wrapText: true },
    { label: 'DOB', fieldName: 'Date_of_Birth__c', type: 'date',typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric",timeZone:"UTC"
    } },
    { label: 'Gender', fieldName: 'Gender__c', type: 'text', wrapText: true },
    { label: 'Casevault PID', fieldName: 'Casevault_PID__c', type: 'text',wrapText: true},
    { label: 'Role', fieldName: 'Intake_Person_Role__c', type: 'text', wrapText : true},
    { label: 'DL NO', fieldName: 'State_Id_Drivers_License__c', type: 'text', wrapText : true}

];

const cpsIntakecolumn = [
    { label: 'Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label: 'CPS Response Type', fieldName: 'CPS_Response_Type__c', type: 'text', wrapText: true}        
];

const intakeColumn = [
    { label: 'Intake', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'CaseNumber' 
        } }},
    { label: 'Purpose', fieldName: 'Origin', type: 'text', wrapText: true},
    { label: 'Jurisdiction', fieldName: 'Jurisdiction__c', type: 'text', wrapText: true}
];

const serviceCasecolumn = [
    { label: 'Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label: 'Number of days', fieldName: 'Number_of_days__c', type: 'text'},
    { label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true}  
];

export default class PersonSearchLWC extends NavigationMixin(UtilityBaseElement) {

    isLoading = false;
    @track searchInput = {};
    @track contactList =[];
    @track cpsIntakeList = [];
    @track intakeList = [];
    @track servicecaseList = [];
    
    personColumn = personColumn;
    cpsIntakecolumn = cpsIntakecolumn;
    intakeColumn = intakeColumn;
    serviceCasecolumn = serviceCasecolumn;

    showContactTable = false;
    showIntake = false;
    showCPSIntake = false;
    showServiceCase = false;

    @track visibleDataContact = [];
    @track visibleDataCPSIntake = [];
    @track visibleDataIntake = [];
    @track visibleDataServiceCase = [];
    @track setSelectedRows = [];
    numberOfPersonRecord;
    
    handleChange(event) { 

        this.searchInput[event.target.name] = event.target.value;
    }

    handleSearch() {

        this.isLoading= true;
        this.setSelectedRows = [];
        this.handleRefresh();
        this.showContactTable = false;
        getContactDetail({searchJSON:JSON.stringify(this.searchInput)})   
            .then(result => {
                this.isLoading= false;
                if (result) {    

                    this.contactList = this.checkNamespaceApplicable(JSON.parse(result),false); 
                    this.numberOfPersonRecord = 'Persons ('+this.contactList.length+')';

                    if (this.contactList.length <= 0) {

                            this.title = "Info!";
                            this.type ="info";
                            this.message = "No records found";
                            this.fireToastMsg();
                    } else {
                        this.showContactTable = true;
                    }
                }
            }).catch(error => {

                this.isLoading = false;
                this.handleError();
            })
    }

    handleClearSearch() {

        this.searchInput = {};
    }

    handleRowAction(event) {

        var recordToNavigate = event.detail.row.Id;
        this.navigateClick(recordToNavigate);
    }

    handleRowSelection(event) {
        
        var selectedRows = event.detail.selectedRows;
        var selectedPerson = selectedRows[0];

        if(selectedPerson) {

            this.handleRefresh();
            this.isLoading = true;
            getPersonsIntakeInvSC({ selectedPersonJSON : JSON.stringify(this.checkNamespaceApplicable(selectedPerson, true))})
            .then(result => {
                let response = JSON.parse(result);
                if(response.intake) {

                    let intakes = [];
                    intakes.push(response.intake);
                    this.intakeList = intakes;
                    this.showIntake = true;
                }
                if(response.investigation) {

                    let investigations = [];
                    investigations.push(response.investigation);
                    this.cpsIntakeList = investigations;
                    this.showCPSIntake = true;
                }
                if(response.serviceCase) {

                    let serviceCases = [];
                    serviceCases.push(response.serviceCase);
                    this.servicecaseList = serviceCases;
                    this.showServiceCase = true;
                } 
                this.isLoading = false;     
            }).catch(error => {

                this.isLoading = false;  
                this.handleError(error);
            })
        }
    }

    handleRefresh() {

        this.contactList = [];
        this.intakeList = [];
        this.cpsIntakeList = [];
        this.servicecaseList = [];
        this.showIntake = false;
        this.showCPSIntake = false;
        this.showServiceCase = false;
    }

    navigateClick(recordId) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    handleError(error) {

        let errorMsg;
        this.title = "Error!";
        this.type = "error";
        if (error) {
            let errors = this.reduceErrors(error);
            errorMsg = errors.join('; ');
        } else {
            errorMsg = 'Unknown Error';
        }
        this.message = errorMsg;
        this.fireToastMsg();
    }

    paginationHandlerContact(event) {

        this.visibleDataContact = [...event.detail.records];     
    }

    paginationHandlerCPSIntake(event) {

        this.visibleDataCPSIntake = [...event.detail.records];     
    }

    paginationHandlerIntake(event) {

        this.visibleDataIntake = [...event.detail.records];     
    }

    paginationHandlerServiceCase(event) {

        this.visibleDataServiceCase = [...event.detail.records];     
    }

}