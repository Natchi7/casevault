import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCourtRec from '@salesforce/apex/TitleIvEController.getCourtRecord';
import updateRecord from '@salesforce/apex/TitleIvEController.upserttitleIVE';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class TitleLegalLWC extends UtilityBaseElement {

    @api titleIvERec;
    titlerec;
    @track safeHaveBaby;
    @track isSpinner = false;
    @track courtRecord = [];
    @track courtObj = {};
    @track preventRemoval;
    @track judgeName;
    @track upsertRecord = {};
    @track CTW_Decision;
    @track Court_Order_Signed_By_Judge;
    @track Date_Of_Next_Hearing;
    @track DateOfReasonable;
    @track Court_order_delay_removal;
    @track Is_IV_E_agency_responsible_for_placement;
    @track locationAddress;
    hearingDate;
    nextHearing;
    @track Removal_Date;
    @track reasonableEffortsNotNecessary;

    connectedCallback() {

        this.isSpinner = true;
        loadScript(this, momentForTime)
        let address = '';
        if(this.titleIvERec.Placement__r.Provider__c !=null) {
            address=(this.titleIvERec.Placement__r.Provider__r.BillingStreet ? address+this.titleIvERec.Placement__r.Provider__r.BillingStreet : address);
            address=(this.titleIvERec.Placement__r.Provider__r.BillingCity ? address+','+this.titleIvERec.Placement__r.Provider__r.BillingCity : address);
            address=(this.titleIvERec.Placement__r.Provider__r.BillingState ? address+','+this.titleIvERec.Placement__r.Provider__r.BillingState : address);
            address=(this.titleIvERec.Placement__r.Provider__r.BillingCountry ? address+','+this.titleIvERec.Placement__r.Provider__r.BillingCountry : address);
            address=(this.titleIvERec.Placement__r.Provider__r.BillingPostalCode ? address+','+this.titleIvERec.Placement__r.Provider__r.BillingPostalCode : address);
            this.locationAddress = address;
        }

        getCourtRec({ serviceCaseRecord : this.titleIvERec.Service_Case__c , childId : this.titleIvERec.Placement__r.Child__c})
            .then(result => {
                this.courtRecord = this.checkNamespaceApplicable(JSON.parse(result), false);
                if (this.courtRecord.length) {
                    this.courtObj = this.courtRecord[0];
                    this.Removal_Date = moment(this.titleIvERec.Child_Removal__r.Removal_Date__c).format('MM/DD/YYYY hh:mm A');
                    this.upsertRecord.Id = this.courtObj.Id;
                    if(this.courtObj.Court_Order_Date__c) {
                    this.hearingDate = moment(this.courtObj.Court_Order_Date__c).format('MM/DD/YYYY hh:mm A');
                    }
                    if(this.courtRecord[0].Court__r) {
                        if(this.courtRecord[0].Court__r.records[0]) {
                        this.judgeName = this.courtRecord[0].Court__r.records[0].Judge_s_Name__c;
                        //this.DateOfReasonable = moment(this.courtRecord[0].Court__r.records[0].Court_Order_Date__c).format('MM-DD-YYYY ');
                        this.nextHearing = moment(this.courtRecord[0].Court__r.records[0].Hearing_Date_and_Time__c).format('MM/DD/YYYY hh:mm A');
                        }
                    }
                }
                if (this.courtObj.Reasonable_Efforts_Could_Not_Be_Made__c == true) {
                    this.reasonableEffortsNotNecessary = "Yes";
                } else if (this.courtObj.Reasonable_Efforts_Could_Not_Be_Made__c == false){
                    this.reasonableEffortsNotNecessary = "No";
                } else {
                    this.reasonableEffortsNotNecessary = "";
                }
                if (this.courtObj.Efforts_Were_Made_To_Prevent_Removal__c == true) {
                    this.preventRemoval = "Yes";
                } else if(this.courtObj.Efforts_Were_Made_To_Prevent_Removal__c == false) {
                    this.preventRemoval = "No";
                } else {
                    this.preventRemoval = "";
                }

                if (this.courtObj.Court_Orders_are_not_signed_by_the_judge__c == true) {
                    this.Court_Order_Signed_By_Judge = "No";
                } else if(this.courtObj.Court_Orders_are_not_signed_by_the_judge__c == false){
                    this.Court_Order_Signed_By_Judge = "Yes";
                } else {
                    this.Court_Order_Signed_By_Judge = "";
                }

                if (this.courtObj.Child_s_Home_Is_Contrary__c) {
                    this.CTW_Decision = "Yes";
                } else if (this.courtObj.Child_s_Home__c) {
                    this.CTW_Decision = "No";
                } else {
                    this.CTW_Decision = "";
                }

                if (this.courtObj.Hearing_Outcome__c == 'Shelter Granted' || this.courtObj.Hearing_Outcome__c == 'Commitment to the Agency' || this.courtObj.Hearing_Outcome__c == '	Co-commitment to DSS and DHMH' || this.courtObj.Hearing_Outcome__c == 'Co-commitment to DSS,DDA,DHMH' || this.courtObj.Hearing_Outcome__c == 'Continued Co-Commitment' ||
                    this.courtObj.Hearing_Outcome__c == 'Continued Commitment' || this.courtObj.Hearing_Outcome__c == 'Continued Guardianship' || this.courtObj.Hearing_Outcome__c == 'Co-commitment to DSS and DDA') {
                    this.Is_IV_E_agency_responsible_for_placement = "Yes";
                } else if(this.courtObj.Hearing_Outcome__c) {
                    this.Is_IV_E_agency_responsible_for_placement = "No";

                } else {
                    this.Is_IV_E_agency_responsible_for_placement="";
                }

                if (this.courtObj.Court_order_delay_removal__c == true) {
                    this.Court_order_delay_removal = "Yes";
                } else if (this.courtObj.Court_order_delay_removal__c == false){
                    this.Court_order_delay_removal = "No";
                } else {
                    this.Court_order_delay_removal = "";
                }
                this.isSpinner = false;
            })
            .catch(error => {

                this.isSpinner = false;
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

        if (this.titleIvERec.Placement__r.Child__r.Safe_haven_baby__c == true) {
            this.safeHaveBaby = "Yes";
        } else if (this.titleIvERec.Placement__r.Child__r.Safe_haven_baby__c == false){
            this.safeHaveBaby = "No";
        } else {
            this.safeHaveBaby = "";
        }

    }
    handlechange(event) {
            let fieldName = event.target.name;
            if (event.target.checked) {
                this.upsertRecord[fieldName] = event.target.checked;
            }
        }
    handleSuccess(event) {
        this.title = "Success!";
        this.type = "success";
        this.message ="Record Updated Successfully!";
        this.fireToastMsg();
    }
    handleError(event){
        this.title = "Error!";
        this.type = "error";
        this.message =event.detail;
        this.fireToastMsg();
    }
}