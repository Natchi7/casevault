import { LightningElement, api, track } from 'lwc';
import getPlacementRec from '@salesforce/apex/CasePlanController.getPlacementRecords';
import createCaseplanVersionRec from '@salesforce/apex/CasePlanController.createCasePlanVersion';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';

const casePlanTable= [{label: 'Name', fieldName: 'Name', type: 'string', wrapText: true},
{label: 'From Date', fieldName: 'From_Date__c', type: 'string', wrapText: true},
{label: 'To Date', fieldName: 'To_Date__c', type: 'string', wrapText: true},
];

const casePlanVersionFilterColumns= [{ label: 'Period Range', fieldName: 'PeriodRange', type: 'string', wrapText: true},
    { label: 'Timeframe', fieldName: 'Timeframe', type: 'string', wrapText: true},
    { label: 'From Date', fieldName: 'FromDate', type: 'date', wrapText: true},
    { label: 'To Date', fieldName: 'ToDate', type: 'date', wrapText: true},
    { label: 'Completed', fieldName: '', type: 'string', wrapText: true},
];


export default class CasePlanLwc extends NavigationMixin(UtilityBaseElement) {
    
    @api propertyValue;
    @track placementId;
    casePlanTable = casePlanTable;
    @track filterRecord = {};
    @track casePlanVersionRecord = {};
    casePlanVersionFilterColumns = casePlanVersionFilterColumns;
    @track placementRecord = {};
    @track casePlanFilterList=[];
    @track showCasePlanFilterModal = false;
    @track showCasePlan = false;
    @track filterMap = [];
    @track  Periodrange = {};
    @track  Timeframe;
    @track PeriodRange;
    @track FromDate;
    @track  ToDate;
    @track days = {};
    @track timeFrame= {};
    @track showConfirmationModal = false;
    @track removaldate;
    @track showFilterTable = true;
    filterTable = 'DateRange';
    readOnly = true;
    @track casePlanVersionRecordId;
    @track loading = false;
    @track casePlanRecordList =[];
    showMsg = false;

    get options() {
        return [
            { label: 'Period Range', value: 'PeriodRange' },
            { label: 'Date Range', value: 'DateRange' },
        ];
    }
    connectedCallback() {
        this.placementId = this.propertyValue;
        loadScript(this, momentForTime)
        this.doInit();
    }

    doInit() {
        this.loading = true;
        this.Periodrange[1] = '0 - 60 days';
        this.Periodrange[2] = '60 - 180 days';
        this.Periodrange[3] = '180 - 360 days';
        this.Periodrange[4] = '360 - 540 days';
        this.Periodrange[5] = '540 - 720 days';
        this.Periodrange[6] = '720 - 900 days';
        this.Periodrange[7] = '900 + days';

        this.timeFrame[1] = '0-2 months';
        this.timeFrame[2] = '2-6 months';
        this.timeFrame[3] = '6-12 months';
        this.timeFrame[4] = '12-18 months';
        this.timeFrame[5] = '18-24 months';
        this.timeFrame[6] = '24-30 months';
        this.timeFrame[7] = '30+ months';

        this.days[1] =0;
        this.days[2] = 60;
        this.days[3] = 180;
        this.days[4] = 360;
        this.days[5] = 540;
        this.days[6] = 720;
        this.days[7] = 900;

        this.getPlacement();
        setTimeout(()=>{
            this.generateCasePlanVersionFilter(this.placementRecord);
        },3000);  
    }

    getPlacement() {

        getPlacementRec({placementId : this.placementId})
        .then(result =>{
            let res = JSON.parse(result);
            this.placementRecord = this.checkNamespaceApplicable(res.placementRecord, false);
            this.casePlanRecordList  = this.checkNamespaceApplicable(res.casePlanRecords, false);
            if(this.casePlanRecordList.length > 0) {
                this.showMsg =false;
            } else {
                this.showMsg = true;
            }
            this.casePlanVersionRecord.Placement__c = this.placementRecord.Id;
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
        });

    }
    

    generateCasePlanVersionFilter(row) {

        for(let i=0; i<7; i++) {
            this.removaldate = row.Child_Removal__r.Removal_Date__c;
            this.filterRecord.PeriodRange = this.Periodrange[i+1];
            this.filterRecord.Timeframe = this.timeFrame[i+1];
            this.filterRecord.FromDate = new Date(this.removaldate);
            this.filterRecord.FromDate = new Date(this.filterRecord.FromDate.setDate(this.filterRecord.FromDate.getDate()+this.days[i+1]));
            if( i != 6) {
                this.filterRecord.ToDate = new Date(this.removaldate);
                this.filterRecord.ToDate = new Date(this.filterRecord.ToDate.setDate(this.filterRecord.ToDate.getDate()+this.days[i+2]));
            }
            this.filterRecord.FromDate = moment(this.filterRecord.FromDate).format('MM/DD/YYYY');
            this.filterRecord.ToDate = moment(this.filterRecord.ToDate).format('MM/DD/YYYY');
            this.casePlanFilterList.push(this.filterRecord);
            this.filterRecord={};

        }
        this.showCasePlan = true;

    }
    closeCasePlanFilterModal() {
        this.showCasePlanFilterModal = false;
    }

    handleCreateCasePlanVersion() {
        this.showCasePlanFilterModal = true;
    }
    openConfirmationModal() {
        this.showCasePlanFilterModal = false;
        this.showConfirmationModal = true;
    }
    closeConfirmationModal() {
        this.showConfirmationModal = false;

    }
    handleCasePlaneFilter(event) {
        if(event.target.value == 'PeriodRange') {
            this.filterTable = event.target.value;
            this.showFilterTable = false;
        } else {
            this.filterTable = event.target.value;
            this.showFilterTable = true;
        }
    }

    handleCasePlanFilterRowAction(event) {

        var selectedRows=event.detail.selectedRows;
        var row = selectedRows[0];
        this.casePlanVersionRecord.Period__c = row.Timeframe;
        this.casePlanVersionRecord.From_Date__c = row.FromDate;
        this.casePlanVersionRecord.To_Date__c = row.ToDate;
        this.casePlanVersionRecord.Approval_Status__c = 'Status-Draft';


    }
    handleCasePlanRecord() {
        this.loading = true;
        createCaseplanVersionRec({casePlanVersionDataJSON : JSON.stringify(this.checkNamespaceApplicable(this.casePlanVersionRecord, true))})
        .then(res =>{
                this.showConfirmationModal = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'CasePlanVersion Created Successfully!';
                this.fireToastMsg();
                
                this.getPlacement();
                this.loading = false;
                //this.casePlanRecordList.push(JSON.parse(res));
                //const handleAura = new CustomEvent('handleRefresh', {detail : res});
                //this.dispatchEvent(handleAura);                
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
        });

    }

    handleModal() {
        this.showCasePlanFilterModal = true;
    }

    navigateClick(event) {
        var selectedRows=event.detail.selectedRows;
        var id = selectedRows[0].Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'cv123__Case_Plan__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}