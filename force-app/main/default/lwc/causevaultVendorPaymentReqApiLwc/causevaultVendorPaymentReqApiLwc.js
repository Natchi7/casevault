import { LightningElement,track,api} from 'lwc';
import getpaymentinputRec from '@salesforce/apex/CaseVaultCalloutHandler.getpaymentinputdetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UtilityBaseElement from 'c/utilityBaseLwc';
//import uploadCsvFiles from '@salesforce/apex/CaseVaultCsvFileUpload.handleCsvFile';

const columns = [
    { label: 'Client ID', fieldName: 'clientID' },
    { label: 'Vendor Number', fieldName: 'vendorNo' },
    { label: 'Vendor Type', fieldName: 'vendorType' },
    { label: 'Placement ID', fieldName: 'placementID' },
    { label: 'Service Type ID', fieldName: 'serviceTypeID' },
    { label: 'Service Start Date', fieldName: 'serviceStartDate' ,type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"}},
    { label: 'Service End Date', fieldName: 'serviceEndDate',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
    { label: 'Rate Amount', fieldName: 'rateAmount',type:'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"} },
    { label: 'Rate Type', fieldName: 'rateType' },
    { label: 'Rate Start Date', fieldName: 'rateStartDate',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
    { label: 'Rate End Date', fieldName: 'rateEndDate',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
    { label: 'Changed Date', fieldName: 'changedDate',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
];
export default class CausevaultVendorPaymentReqApiLwc extends UtilityBaseElement {

    @track paymentInputData = [];
    columns = columns;
    @api myRecordfile;
    isLoading=true;
    @track fileNames='';
    @track visibleData = [];
    showChild = false;
    get acceptedFormats() {
        return ['.csv'];
    }
    connectedCallback(){
        this.showChild = false;
        getpaymentinputRec()
        .then(result => {
            let res = JSON.parse(result);
            if (res.status == 'success') {
            this.isLoading=false;
            this.paymentInputData = res.data;
            this.showChild = true;
            }
            else if (res.status == 'error') {
            this.paymentInputData = [];
            let errorMsg = res.error.message;
            const event = this.onToastEvent('warning', 'Warning!', errorMsg);
            this.dispatchEvent(event); 
            }
        })
        .catch(error => {

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
    }
    onToastEvent(type, toastTitle, msg) {

        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        var reader = new FileReader();
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
            reader.onload = () => {
                var base64 = reader.result.split(',')[1];
                this.fileData = {
                'filename' : file.name,
                'base64' : base64
                }
                }
                reader.readAsDataURL(file);
        }
        this.fileNames=uploadedFileNames;
    }
    handleCancel(){
        this.myRecordfile='';
        this.fileNames='';
    }
    handleFile(){
        
    }
    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
}