import { LightningElement, track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import versionsInit from '@salesforce/apex/ServicePlanController.getServicePlanVersionsInitInfo';
import saveVersion from '@salesforce/apex/ServicePlanController.upsertServicePlanVersions';


const actions =[
                {label: 'Edit', name: 'edit'}
               ];

const columns= [{ label: 'Version Name', fieldName: 'Name'},
                { label: 'Persons Benefiting', fieldName: 'Persons_Benefitizing__c'},
                { label: 'Documents', fieldName: ''},
                { label: 'Signatures', fieldName: ''},
                { label: 'Status', fieldName: ''},
                { type: 'action', typeAttributes: { rowActions: actions} }
];
export default class ServicePlanVersionsLwc extends UtilityBaseElement {

    @api recordId;
    @track showServicePlanVersionModal = false;
    columns = columns;
    @track serviceplanversionlist = [];
    @track serviceplanversionRec = {};
    @track personBenefitingPicklistValue = [];
    @track getSelected = [];
    @track selected = [];
    loading = false;

    connectedCallback() {

        this.doInit();
    }

    doInit() {

        this.loading = true;
        versionsInit({recordId:this.recordId})
        .then(result => {

            let res =JSON.parse(result);
            this.personBenefitingPicklistValue = res.personBenefitingPicklist;
            this.serviceplanversionlist = this.checkNamespaceApplicable(res.servicePlanVersionList,false);
            this.showServicePlanVersionModal = false;
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


    openServicePlanVersionsModal(){

        this.serviceplanversionRec = {};
        this.getSelected = [];
        this.showServicePlanVersionModal = true;
    }

    handleCancel() {
        this.showServicePlanVersionModal = false;

    }

    handleChange(event) {

        let targetName = event.target.name;
        let targetValue = event.target.value;
        if(targetName != 'Persons_Benefitizing__c') {

            this.serviceplanversionRec[targetName] = targetValue;
        } else {
            this.selected = targetValue;
        }
    }

    handleRowAction(event) {

        var name = event.detail.action.name;
        var selectedrow = event.detail.row;
        if(name == 'edit') {
            this.serviceplanversionRec = selectedrow;
            if(selectedrow.Persons_Benefitizing__c != null) {
                this.getSelected =selectedrow.Persons_Benefitizing__c.split(';');
            } else {
                this.getSelected = [];
            }
            this.showServicePlanVersionModal = true;
        }

    }

    handleSave() {

        if(!this.onValidate()) {
            this.serviceplanversionRec.Service_Plan__c = this.recordId;
            this.serviceplanversionRec.Persons_Benefitizing__c = this.selected.join(';');
            this.loading = true;
            saveVersion({servicePlanVersionJSON : JSON.stringify(this.checkNamespaceApplicable(this.serviceplanversionRec,true))})
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
}