({
	getInitInfo : function(component, event, helper) {
		    var action = component.get("c.getCPSIntakeRecordHistroy");
        
        action.setParams({
            'serviceCaseRecordId': component.get("v.recordId")
        });   
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.intakeReportRecord",JSON.parse(storeResponse).serviceCaseRec);
            }
        });
        $A.enqueueAction(action);
	}
})