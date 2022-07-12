import { LightningElement,track, api } from 'lwc';
import getAdoptionEffortsInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getAdoptionEffortsInfo';
import updateAdoptionPlanning from '@salesforce/apex/PermanacyPlanAdoptionController.updateAdoptionPlanning';
import upsertEffortsRecord from '@salesforce/apex/PermanacyPlanAdoptionController.upsertEffortsRecord';
import deleteEffortsRecord from '@salesforce/apex/PermanacyPlanAdoptionController.deleteEffortsRecord';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PermanencyPlanAdoptionEfforts extends UtilityBaseElement {

    @api permanencyRecId;
    @track readOnly = false;
    @track showUpdateModal = false;
    loading = false;
    @track permanencyRec = {};
    @track updatepermanencyRec = {};
    checkboxValue = false;
    @track effortRecords = [];
    @track effortRec = {};

    connectedCallback() {

        this.doInit();

    }

    doInit() {

        this.loading = true;
        getAdoptionEffortsInfo ( {permanencyPlanId : this.permanencyRecId})
        .then(result => {

            let res = JSON.parse(result);
            this.effortRecords = this.checkNamespaceApplicable(res.adoptionEfforts, false);
            this.permanencyRec = this.checkNamespaceApplicable(res.permanencyPlanRec, false);
            
            if(this.permanencyRec.Reasonable_but_unsuccessful_efforts__c == 'Yes') {
                this.checkboxValue = true;
            } else if(this.permanencyRec.Reasonable_but_unsuccessful_efforts__c == 'No') {
                this.checkboxValue = false;
            }
            this.loading = false;

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
       });

    }

    handleChange(event) {

        let fieldType = event.target.type;
        let name = event.target.name;
        let value = event.target.value;
        if (fieldType != 'checkbox') {
            this.updatepermanencyRec[name] = value;
        } else if(name == 'Reasonable_but_unsuccessful_efforts__c') {
            if(event.target.checked == true) {
                this.updatepermanencyRec[name] = 'Yes';
            } else {
                this.updatepermanencyRec[name] = 'No';
            }
             
        } else {
            this.updatepermanencyRec[name] = event.target.checked;
        }

    }

    handleSave() {

        this.updatepermanencyRec.Id = this.permanencyRecId;
        this.updatepermanencyRec.Adoption_Planning_Stage__c = 'EMOTIONAL TILES';
        this.doSave();

    }

    handleSaveNext() {

        this.handleSave();
        const adoptionStageEvent = new CustomEvent('adoptionstage');
        this.dispatchEvent(adoptionStageEvent);
    }

    doSave() {

        this.loading = true;
        updateAdoptionPlanning({adoptionPlanningJSON : JSON.stringify(this.checkNamespaceApplicable(this.updatepermanencyRec,true))})
        .then(result => {

            const evt = new ShowToastEvent({
                title : 'Success',
                message : 'Adoption Efforts updated',
                variant : 'success',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt);
            this.doInit();
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

    handleAddAdoption() {

        this.effortRec = {};
        this.showUpdateModal = true;
    }

    closeUpdateModal() {

        this.showUpdateModal = false;
    }

    handleUpdate(event) {

        this.effortRec[event.target.name] = event.target.value;
    }

    handleEffortSave() {

        this.loading = true;
        this.effortRec.Permanency_Plan__c = this.permanencyRecId;
        upsertEffortsRecord({effortsRecordJSON : JSON.stringify(this.checkNamespaceApplicable(this.effortRec,true))})
        .then(result => {
            const evt = new ShowToastEvent({
                title : 'Success',
                message : 'Adoption Efforts updated',
                variant : 'success',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt);
            this.doInit();
            this.loading = false;
            this.showUpdateModal = false;
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

    handleEffortEdit(event) {

        this.effortRec = {};
        let id = event.target.dataset.id;
        for(let i=0;i<this.effortRecords.length;i++) {
            if(this.effortRecords[i].Id == id) {
                this.effortRec = this.effortRecords[i];
            }
        }
        this.showUpdateModal = true;
    }

    handleEffortDelete(event) {

        this.loading = true;
        let id = event.target.dataset.id;
        deleteEffortsRecord({effortRecordId:id})
        .then(result => {

            const evt1 = new ShowToastEvent({
                title : 'Success',
                message : 'Effort record deleted',
                variant : 'success',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt1);
            this.doInit();
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

}