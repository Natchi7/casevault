({
	init : function(component, event, helper) {
		component.set('v.columns', [
            {label: 'CASE NUMBER', fieldName: 'caseNumber', type: 'string'},
            {label: 'CASE WORKER', fieldName: 'caseWorker', type: 'string'},
            {label: 'HEAD OF HOUSEHOLD', fieldName: '', type: 'string'},
            {label: 'RECEVIED DATE & TIME', fieldName: 'receivedDateTime', type: 'date', typeAttributes:{
                month: 'numeric', day: 'numeric', year: 'numeric',hour: 'numeric',minute:'numeric'}},
            {label: 'SUBMITTED DATE & TIME', fieldName: 'submittedDateTime', type: 'date',typeAttributes:{
                month: 'numeric', day: 'numeric', year: 'numeric',hour: 'numeric',minute:'numeric'}},
            {label: 'SERVICE TYPE', fieldName: '', type: 'string'},
            {label: 'APPROVAL STATUS', fieldName: 'approvalStatus', type: 'string'},
            {label: 'EVENT DESCRIPTION', fieldName: 'eventDescription', type: 'string'},
        ]);
       //helper.getInfo(componenet,fromDate,toDate);
        var action = component.get("c.allApprovedRecords");
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
            	var  approvedListNSIns = component.find("utils").checkNameSpace(JSON.parse(storeResponse).approvedWrapperList,false);
                component.set("v.approvedList", approvedListNSIns);
            }else if (state === "INCOMPLETE") {
            	helper.showToast(component, event, helper, "error", "Response is Incompleted", "Error!");
                //alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
            			helper.showToast(component, event, helper, "error", errors[0].message, "Error!");
                        /*alert("Error message: " + 
                              errors[0].message);*/
                    }
                } else {
    				helper.showToast(component, event, helper, "error", "Unknown error", "Error!");
                   // alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
       
})