import { LightningElement,track, api, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitialInformation from '@salesforce/apex/FindingPersonController.getInitialInformation';
import getPersons from '@salesforce/apex/FindingPersonController.getPersons';
import updatePerson from '@salesforce/apex/FindingPersonController.updatePerson';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact_OBJECT from '@salesforce/schema/Contact';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';

const columns = [
    { label: 'First Name', fieldName: 'FirstName', type: 'string'},
    { label: 'Last Name', type:  'string', fieldName: 'LastName'},
    { label: 'DOB', fieldName: 'Date_of_Birth__c',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"}},
    { label: 'Gender', fieldName: 'Gender__c', type: 'string' },
    { label: 'SSN', fieldName: 'SSN__c', type: 'string' },
    { label: 'Address', fieldName: 'Address_Line_1__c', type: 'string' },
    { label: 'Casevault ID', fieldName: 'Casevault_PID__c', type: 'string'},
    { label: 'Source', fieldName: '', type: 'string'},
    { label: 'Prior History', fieldName: '', type: 'string'},
];

export default class FindPerson extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @api objectApiName;
    @api recordTypeName;
    @track objectInfo;
    @track currentStep='step1';
    @track isStep1 = true;
    @track isStep2 = false;
    @track genderPickOpt = [];
    @track statePickOpt = [];
    @track countryPickOpt = [];
    @track searchInput = {};
    @track columns = columns;
    @track personList = [];
    @track conRec = {};
    @track selectedPersonId = '';
    @track visibleDataContact = [];
    @track isLoading = false;
    @track showTable = true;
    @track HideSearchButton = false;
    @track disableButton = false;
   
    connectedCallback() {

        loadScript(this, momentForTime)
        this.doInitInfo();
    }
    @wire(getObjectInfo, { objectApiName: Contact_OBJECT})
    objectInfo;

    get contactsRecordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        if(this.recordTypeName) {
            return Object.keys(rtis).find(rti => rtis[rti].name === this.recordTypeName);
        } else {
           return Object.keys(rtis).find(rti => rtis[rti].name === 'Persons Involved');
        }
    }
  
    doInitInfo() {
        getInitialInformation({}).then(result => {
            if(result){
                let res = JSON.parse(result);
                this.genderPickOpt = res.genderPicklist;
                this.statePickOpt = res.statePicklist;
                this.countryPickOpt = res.countryPicklist;
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

    showSearchModal() {
        this.HideSearchButton=true;
    }
    handleChange(event){
        let name = event.target.name;
        let value = event.target.value;
        if (name == 'firstName') {
            this.searchInput.firstName = value;
        }
        if (name == 'lastName') {
            this.searchInput.lastName = value;
        }
        if (name == 'dob') {
            this.searchInput.dob = value;
        }
        if (name == 'ssn') {
            this.searchInput.ssn = value;
        }
        if (name == 'casevaultPId') {
            this.searchInput.casevaultPId = value;
        }
        if(name== 'stateId') {
            this.searchInput.stateId = value;
        }
        if(name== 'gender') {
            this.searchInput.gender = value;
        }
        if(name=='approxAge'){
            this.searchInput.approxAge = value;
        }
        if(name=='addLine1') {
            this.searchInput.addLine1 = value;
        }
        if(name=='addLine2') {
            this.searchInput.addLine2 = value;
        }
        if(name=='zipCode') {
            this.searchInput.zipCode = value;
        }
        if(name =='state') {
            this.searchInput.state = value;
        }
        if(name =='country') {
            this.searchInput.country= value;
        }
        if(name == 'city') {
            this.searchInput.city= value;
        }
        //this.searchInput[name] = value;
        }

        searchPerson(event) {
            this.isLoading = true;
            

           if(Object.keys(this.searchInput).length === 0) {
            this.isLoading = false;
                this.title = "Warning!";
                this.type = "warning";
                this.message = "Please enter atleast one input for search";
                this.fireToastMsg();
            } else{
            
                getPersons({searchJSON : JSON.stringify(this.searchInput)})
                .then(result=>{
                    if(result){
                    this.isLoading = false;
                    let res = JSON.parse(result);
                    this.currentStep ='step2';
                    this.isStep2 = true;
                    this.isStep1 = false;
                    this.personList = this.checkNamespaceApplicable(res,false); 
                    let personListLength = this.personList.length;
                  
                    if(personListLength > 0) {
                        this.showTable = true;
                        this.disableButton = false;
                    } else {
                        this.showTable = false;
                        this.disableButton = true;
                    }
                    }

                }).catch(error => {
                    this.isLoading = false;
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
                })
            }
        }
    handleRowAction1(event) {
        var selectedRows=event.detail.selectedRows;
        this.selectedPersonId = selectedRows[0].Id;
    
    }
    selectPerson(event) {
        this.conRec.Id = this.selectedPersonId;
        if(this.objectApiName == 'Case') {
            this.conRec.Intake__c = this.recordId;
        } else {
            this.conRec[this.objectApiName] = this.recordId;
        }

        this.isLoading = true;
        if(this.conRec.Id) {
            updatePerson({contactJSON :  JSON.stringify(this.checkNamespaceApplicable(this.conRec,true))})
            .then(result=>{
                this.isLoading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Person added successfully';
                this.fireToastMsg();
                this.currentStep ='step1';
                this.conRec = {};
                this.searchInput = {};
                this.isStep2 = false;
                this.isStep1 = true;
                const handleAura = new CustomEvent('handleRefresh', {detail : result});
                this.dispatchEvent(handleAura);

            }).catch(error => {
                this.isLoading=false;
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
        } else{
            this.isLoading=false;
            this.title = 'Info!';
            this.type = 'info';
            this.message = 'Select one person';
            this.fireToastMsg();
        }
    }
    paginationHandlerContact(event) {

        this.visibleDataContact = [...event.detail.records];     
    }
    backToSearch(event) {

        this.handleClearSearch();
        this.isStep1= true;
        this.isStep2= false;
        this.currentStep = 'step1';
        this.conRec = {};
    }

    handleClearSearch() {
        this.searchInput = {};
    }
    handleCloseSearch(event) {
        this.HideSearchButton=false;
    }

    handleNavigate(){
        let recordIdPrefix = this.recordId.slice(0,3);


        if(this.objectApiName == 'Case'){
                this.defaultValues = encodeDefaultFieldValues({
                Intake__c: this.recordId
            });
        } 
        if(this.objectApiName == 'Service_Case__c'){
                this.defaultValues = encodeDefaultFieldValues({
                Service_Case__c: this.recordId,
                Program_Area__c: 'In-Home Services/Family Preservation'
            });
        }
        if(this.objectApiName == 'Investigation__c'){
            this.defaultValues = encodeDefaultFieldValues({
            Investigation__c : this.recordId,
            Program_Area__c: 'CPS/IR'
         });
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
            objectApiName: 'Contact',
            actionName: 'new',
        },
        state: {
           recordTypeId: this.contactsRecordTypeId,
           defaultFieldValues: this.defaultValues
        }
       });
       this.handleClearSearch();
       this.handleCloseSearch();
    }
}