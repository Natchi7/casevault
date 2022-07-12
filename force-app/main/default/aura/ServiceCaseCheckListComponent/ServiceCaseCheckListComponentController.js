({
    getInitialInfos: function(component,event,helper){
        component.set("v.serviceCaseRecordId",component.get("v.recordId"));
        var columns = [
            {label: 'Date', fieldName: 'updatedDate', type: 'date',
             typeAttributes:{
                month: 'numeric', day: 'numeric', year: 'numeric',hour: 'numeric',minute:'numeric'}}, 
            {label: 'Status', fieldName: 'status', type: 'text'},
            {label: 'Recommendation', fieldName: 'recommendation', type: 'Text', cellAttributes: { alignment: 'left' }},
            {label: 'User', fieldName: 'user', type: 'text'},
            {label: 'Role', fieldName: 'role', type: 'text'},
            {label: 'Reviewer Comments', fieldName: 'reviewerComments', type: 'text'},
            {label: 'Approval Status', fieldName: 'approvalStatus', type: 'text'},
            {label: 'Approved By', fieldName: 'approvedBy', type: 'text'},
            
        ];
        
        var currentRecordId = component.get("v.recordId");
        if(component.get("v.sObjectName") == 'Service_Case__c') {
        	component.set('v.showBtn',true);
        } else {
            component.set('v.showBtn',false);
        }
        
        helper.getHistory(component,columns); 
       
    },
    
    init : function (component,event,helper) {
        component.set("v.openModal",true);
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name : 'ServiceCaseRecordIdCmp',
                type : 'String',
                value : component.get("v.serviceCaseRecordId")
            },]
            flow.startFlow("Service_Case_Decision_Flow",inputVariables);
   },
  
   closeModel : function(component,event,helper){
   	    component.set("v.openModal",false);
        component.set("v.openCPSIntakeReportCmp",false);
   },
  handleStatusChange : function (component, event) {
   if(event.getParam("status") === "FINISHED") {
        component.set("v.openModal",false);
    }
  },
  getCPSIntakeReport: function(component,event,helper){
        var recordId = component.get("v.recordId");
        var url = '/apex/CPSIntakeReport?id='+recordId;
        window.open(url, '_blank');
  	//component.set("v.openCPSIntakeReportCmp",true);
  },
            refreshPage: function(component,event,helper){
            	
                helper.getHistory(component,columns);
                $A.get('e.force:refreshView').fire();
            }
 
})