({
	startFlow : function(component, event, helper) {
		component.set("v.openModal",true);
        var flow = component.find('flowData');
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        flow.startFlow('AdoptionDecisionFlow',inputVariables); 
        
	},
    
    closeModel : function(component, event, helper) {
    	component.set("v.openModal",false);
	},
    
    handleStatusChange : function(component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
        	component.set("v.openModal",false);
    	}
    },
    
    getInitialInfos: function(component,event,helper) {
    
        var columns = [
                {label: 'Date', fieldName: 'Decision_Approved_DateTime__c', type: 'date',
                 typeAttributes:{
                    month: 'numeric', day: 'numeric', year: 'numeric',hour: 'numeric',minute:'numeric'}}, 
                {label: 'Status', fieldName: 'Status', type: 'text'},
                {label: 'Recommendation', fieldName: 'Intake_Recommendations__c', type: 'Text', cellAttributes: { alignment: 'left' }},
                {label: 'User', fieldName: 'Decision_Submitted_By__c', type: 'text'},
                {label: 'Role', fieldName: 'Decision_Submitted_By__c', type: 'text'},
                {label: 'Reviewer Comments', fieldName: 'Decision_Review_Comments__c', type: 'text'},
                {label: 'Approval Status', fieldName: 'Decision_Approval_Status__c', type: 'text'},
                {label: 'Approved By', fieldName: 'Decision_Approved_By__c', type: 'text'},
                
            ];
            helper.getDecision(component,columns); 
 	}
})