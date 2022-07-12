import { LightningElement, track, api} from 'lwc';
import getPlacementTableRec from '@salesforce/apex/CasePlanController.getPlacementTableRecords';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { NavigationMixin } from 'lightning/navigation';
import id from '@salesforce/user/Id';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';

const placementTable= [{label: 'Child', fieldName: 'child', type: 'string', wrapText: true},
    {label: 'Casevault PID', fieldName: 'casevaultPid', type: 'string', wrapText: true},
    { label: 'DOB', fieldName: 'dob', type: 'date', wrapText: true,typeAttributes : {day:"numeric",month:"numeric",year:"numeric"}},
    { label: 'Gender', fieldName: 'gender', type: 'string', wrapText: true},
    { label: 'Removal Date', fieldName: 'removaldate', type: 'date', wrapText: true,typeAttributes : {day:"numeric",month:"numeric",year:"numeric"}},
];

export default class CasePlanPlacementTableLwc extends NavigationMixin(UtilityBaseElement) {
@api recordId;
@track PlacementRecordList =[];
placementTable= placementTable;
@track casevaultPid;
@track dob;
@track gender;
@track removaldate;
@track child;
@track placementId;
@track loading = false;
showMsg = false;
connectedCallback() {
    
    loadScript(this, momentForTime)
    this.doInit();
}
doInit() {
    this.loading = true;
    getPlacementTableRec({serviceCaseId : this.recordId})
    .then(result=>{
        let res = JSON.parse(result);
        this.PlacementRecordList = this.checkNamespaceApplicable(res.placementTableRecord, false);
        if(this.PlacementRecordList.length > 0) {
            for(let i =0;i<this.PlacementRecordList.length;i++){
                if(this.PlacementRecordList[i].Child_Removal__c) {
                    this.PlacementRecordList[i].removaldate =this.PlacementRecordList[i].Child_Removal__r.Removal_Date__c;
                }
                if(this.PlacementRecordList[i].Child__r) {
                    this.PlacementRecordList[i].casevaultPid = this.PlacementRecordList[i].Child__r.Casevault_PID__c;
                    this.PlacementRecordList[i].dob = this.PlacementRecordList[i].Child__r.Date_of_Birth__c;
                    this.PlacementRecordList[i].gender = this.PlacementRecordList[i].Child__r.Gender__c;
                    this.PlacementRecordList[i].child = this.PlacementRecordList[i].Child__r.Name;
                }
            }
            this.showMsg = false;
        } else {
            this.showMsg = true;
        }
        this.loading = false;
    })
    .catch(error => {
    
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

   handleRowSelection(event) {
    var selectedRows=event.detail.selectedRows;
    this.placementId = selectedRows[0].Id; 
    var compDefinition = {
        componentDef: "c:casePlanLwc",
        attributes: {
            propertyValue: this.placementId
        }
    };
    var encodedCompDef = btoa(JSON.stringify(compDefinition));
    this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: '/one/one.app#' + encodedCompDef
        }
    });
   }

   /*this[NavigationMixin.Navigate]({
                type: 'standard__recordRelationshipPage',
                attributes: {
                    recordId: this.placementId,
                    objectApiName: 'Case_Plan__c',
                    relationshipApiName: 'Case_Plans__r',
                    actionName: 'view'
                }
            });
   }*/
}