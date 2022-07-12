import { LightningElement, api, track } from 'lwc';
import upsertPlacementRecord from '@salesforce/apex/TitleIvEController.upsertPlacement';
import getPicklist from '@salesforce/apex/TitleIvEController.getPlacementPickList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UtilityBaseElement from 'c/utilityBaseLwc';


export default class TitlePlacementLWC extends UtilityBaseElement {
    title;
    @track placementRec = true;
    providerAddress = '';
    @api titleIvERec;
    @track loading = false;
    @track placement;
    @track address;
    @track placementrecord={};
    @track placementProvider={};
    providerName;
    picklist =[];
    
    get getReimbursible() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
            ];
    }
    get getLiving() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
            ];
    }
    connectedCallback() {

        this.loading = true;
        getPicklist()
        .then(result =>{
            this.picklist = JSON.parse(result);
        })
        this.placementrecord.Id=this.titleIvERec.Id;
        this.placement="Placement";
        let address = '';
        if(this.titleIvERec.Placement__r.Provider__c !=null) {
            this.placementProvider = this.titleIvERec.Placement__r.Provider__c;
            this.providerName = this.titleIvERec.Placement__r.Provider__r.Name;
            address=(this.titleIvERec.Placement__r.Provider__r.BillingStreet ? address+this.titleIvERec.Placement__r.Provider__r.BillingStreet : address);
            address=(this.titleIvERec.Placement__r.Provider__r.BillingCity ? address+','+this.titleIvERec.Placement__r.Provider__r.BillingCity : address);
            address=(this.titleIvERec.Placement__r.Provider__r.BillingState ? address+','+this.titleIvERec.Placement__r.Provider__r.BillingState : address);
            address=(this.titleIvERec.Placement__r.Provider__r.BillingCountry ? address+','+this.titleIvERec.Placement__r.Provider__r.BillingCountry : address);
            address=(this.titleIvERec.Placement__r.Provider__r.BillingPostalCode ? address+','+this.titleIvERec.Placement__r.Provider__r.BillingPostalCode : address);
            this.address = address;
            /*if(this.titleIvERec.Placement__r.Provider__r.Placement__c == true){
                this.placement="Placement";
            }
            else{
                this.placement="Living";
            }*/
        }
        this.loading = false;
    }
    handlechange(event){
            this.placementrecord[event.target.name]=event.target.value;
    }

    handleSave(){
        upsertPlacementRecord({placementDataJSON : JSON.stringify(this.checkNamespaceApplicable(this.placementrecord, true))})
        .then(() => {
          
            this.title = "Success!";
            this.type = "success";
            this.message = "Placement Record Updated Successfully";
            this.fireToastMsg();
                
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
        })

    }
   
}