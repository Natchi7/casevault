import { LightningElement, track, api } from 'lwc';
import getAdoptionEmotionalInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getAdoptionPlanningEmotionalInitialInfos';
import savePermanencyPlan from '@salesforce/apex/PermanacyPlanAdoptionController.updateAdoptionPlanning';
import getEmotionalTiesInitInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getEmotionalTiesInitInfo';
import getProviders from '@salesforce/apex/PlacementController.fetchAccount';
import upsertEmotionalTies from '@salesforce/apex/PermanacyPlanAdoptionController.upsertEmotionalTies';
import UtilityBaseElement from 'c/utilityBaseLwc';

const columns = [
    { label: 'PROVIDER ID', fieldName: 'Casevault_ProID__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'PROVIDER NAME', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'VACANCY', fieldName: 'Number_of_Beds__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'PLACEMENT STRUCTURE', fieldName: 'Placement_Service__c', type: 'text', sortable: true },
    { label: 'PROVIDER CATEGORY', fieldName: 'Type__c', type: 'text', sortable: true }
];
export default class PermanencyPlanEmotionalTiles extends UtilityBaseElement {

    @api permanencyRecId;
    @track permanencyPlanRec = {};
    loading = false;
    showAddEmotionalTies = false;
    @track emotionalTiesRec = {};
    @track typeList = [];
    showProvider = false;
    showOther = false;
    @track prefixList = [];
    @track suffixList = [];
    showSearchProvider = false;
    @track searchInput = {};
    @track providerList = [];
    @track childCharPick = [];
    @track placementStructurePick = [];
    @track localDeptPick = [];
    showProviderList = false;
    columns = columns;
    @track selectedProvider = {};
    @track emotionalTiesList = [];
    readOnly = false;


    connectedCallback() {

        this.doInitInfo();
    }

    doInitInfo() {

        this.loading = true;
        getAdoptionEmotionalInfo({ permanencyPlanId: this.permanencyRecId })

        .then(result => {
            if (result) {
                this.permanencyPlanRec = this.checkNamespaceApplicable(JSON.parse(result).permanencyPlanRec, false);
            }
            this.loading = false;
        }).catch(error => {

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
            this.loading = false;
        });

        this.loading = true;
        getEmotionalTiesInitInfo({ permanencyPlanId: this.permanencyRecId })
        .then(result => {
            this.loading = false;
            let res = JSON.parse(result);
            this.typeList = res.typePicklist.slice(1);
            this.prefixList = res.prefixList;
            this.suffixList = res.suffixList;
            this.childCharPick = res.childCharPicklist;
            this.placementStructurePick = res.placementStructurePicklist;
            this.localDeptPick = res.localDeptPicklist;
            this.emotionalTiesList = this.checkNamespaceApplicable(res.emotionalTieList,false);
            for(let i =0; i<this.emotionalTiesList.length; i++) {
                if(this.emotionalTiesList[i].Type__c == 'Provider' && this.emotionalTiesList[i].Provider__c != null) {

                    this.emotionalTiesList[i].providerId = this.emotionalTiesList[i].Provider__r.Casevault_ProID__c;
                    this.emotionalTiesList[i].providerName = this.emotionalTiesList[i].Provider__r.Name;

                } else if(this.emotionalTiesList[i].Type__c == 'Other') {
                    let name = '';
                    if(this.emotionalTiesList[i].Prefix__c) {
                        name = name + this.emotionalTiesList[i].Prefix__c + ' ';
                    }
                    if(this.emotionalTiesList[i].First_Name__c) {
                        name = name + this.emotionalTiesList[i].First_Name__c + ' ';
                    }
                    if(this.emotionalTiesList[i].Middle_Name__c) {
                        name = name + this.emotionalTiesList[i].Middle_Name__c + ' ';
                    }
                    if(this.emotionalTiesList[i].Last_Name__c) {
                        name = name + this.emotionalTiesList[i].Last_Name__c + ' ';
                    }
                    if(this.emotionalTiesList[i].Suffix__c) {
                        name = name + this.emotionalTiesList[i].Suffix__c;
                    }
                    
                    this.emotionalTiesList[i].providerName = name;
                }
            }
            
        }).catch(error => {

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
            this.loading = false;
        });


    }

    handleChange(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let fieldValue = event.target.value;
        let fieldType = event.target.type;
        if (fieldType == 'checkbox') {
            this.permanencyPlanRec[fieldName] = checkedfields;
        } else {
            this.permanencyPlanRec[fieldName] = fieldValue;
        }

    }

    handleSave() {

        if (!this.onValidate()) {
            this.loading = true;
            this.permanencyPlanRec.Adoption_Planning_Stage__c = 'NARRATIVE';
            savePermanencyPlan({ adoptionPlanningJSON: JSON.stringify(this.checkNamespaceApplicable(this.permanencyPlanRec, true)) })
                .then(result => {
                    if (result) {
                        this.title = "Success!";
                        this.type = "success";
                        this.message = 'Adoption plan emotional tiles saved succesfully.';
                        this.fireToastMsg();
                        this.doInitInfo();
                    }
                    this.loading = false;
                }).catch(error => {

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
                    this.loading = false;
                })
        } else {
            this.title = "Error!";
            this.type = "error";
            this.message = "Complete the required field(s).";
            this.fireToastMsg();
        }
    }

    handleSaveNext() {

        this.handleSave();
        const adoptionStageEvent = new CustomEvent('adoptionstage');
        this.dispatchEvent(adoptionStageEvent);
    }

    handleModal() {

        this.selectedProvider = {};
        this.emotionalTiesRec = {};
        this.readOnly = false;
        this.showProvider = false;
        this.showOther = false;
        this.showAddEmotionalTies = true;
    }

    closeModal() {

        this.showAddEmotionalTies = false;
    }

    handleTypeChange(event) {

        this.emotionalTiesRec = {};
        this.selectedProvider = {};
        this.showProvider = false;
        this.showOther = false;
        let name = event.target.name;
        let value = event.target.value;
        this.emotionalTiesRec[name] = value;
        
        if(value == 'Provider') {

            this.showProvider = true;
        } else if(value == 'Other') {

            this.showOther = true;
        }

    }

    handleEmotionalTieChange(event) {

        this.emotionalTiesRec[event.target.name] = event.target.value;
    }

    handleSearchProvider(event) {

        this.showAddEmotionalTies = false;
        this.searchInput = {};
        this.showSearchProvider = true;
    }
    closeSearchProviderModal() {

        this.showSearchProvider = false;
    }

    searchHandle(event) {

        let name = event.target.name;
        let value = event.target.value;
        if(name == 'childCharacter'){
            
            let multiHearingValues = value.join(';');
            this.searchInput[name] =  multiHearingValues;
        } else {
            this.searchInput[name] = value;
        }

    }

    handleSearch(event) {
        this.loading = true;
        getProviders({searchInputJSON:JSON.stringify(this.searchInput)})   
        .then(result => {
            if (result) {
                this.providerList = this.checkNamespaceApplicable(JSON.parse(result),false);
                if(this.providerList.length > 0) {
                    this.selectedProvider = {};
                    this. showSearchProvider = false;
                    this.showProviderList = true;
                } else {
                    this.title = "Error!";
                    this.type = "error";
                    this.message = "No records are found";
                    this.fireToastMsg();
                }
                this.loading = false;
                
            }
        }).catch(error => {
            this.loading = false;
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

    handleClear() {

        this.searchInput = {};
    }

    closeshowProviderList() {

        this.showProviderList = false;
    }

    handleRowSelection = event => {

        var selectedRows=event.detail.selectedRows;
        let length = selectedRows.length - 1;
        this.selectedProvider = selectedRows[length];
       
        if(selectedRows.length>1)
        {
            var el = this.template.querySelector('lightning-datatable');
            selectedRows=el.selectedRows=el.selectedRows.slice(1);
            event.preventDefault();
            return;
        }
        
    }

    handleBacktoSearch() {

        this.showProviderList = false;
        this.showSearchProvider = true;
    }

    handleSelectProvider() {

        this.showProviderList = false;
        this.showProvider = true;
        this.showAddEmotionalTies = true;
        
    }

    handleEmotionalTiesSave() {

        this.loading = true;
        this.showAddEmotionalTies = false;
        this.emotionalTiesRec.Permanency_Plan__c = this.permanencyRecId;
        this.emotionalTiesRec.Provider__c = this.selectedProvider.Id;
        upsertEmotionalTies({emotionalTiesJSON:JSON.stringify(this.checkNamespaceApplicable(this.emotionalTiesRec,true))})
        .then(result => {

            this.loading = false;
            this.title = "Success!";
            this.type = "success";
            this.message = 'Emotional tiles saved successfully.';
            this.fireToastMsg();
            this.doInitInfo();
        }).catch(error => {
            this.loading = false;
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

    handleView(event) {

        let id = event.target.dataset.id;
        let foundElement=this.emotionalTiesList.find(ele => ele.Id == id);
        this.emotionalTiesRec = foundElement;
        this.showProvider = false;
        this.showOther = false;
        if(this.emotionalTiesRec.Type__c == 'Provider') {

            this.selectedProvider.Casevault_ProID__c = this.emotionalTiesRec.Provider__r.Casevault_ProID__c;
            this.showProvider = true;

        } else if(this.emotionalTiesRec.Type__c == 'Other') {
            this.showOther = true;
        }
        this.readOnly = true;
        this.showAddEmotionalTies = true;
    }


}