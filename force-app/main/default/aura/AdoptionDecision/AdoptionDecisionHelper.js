({
	getDecision : function(component, columns) {
        var action = component.get("c.getDecision");
        action.setParams({
            'caseId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.columns", columns);
                var storeResponse = response.getReturnValue();
                var utilityBaseCmp = component.find("utils");
                component.set("v.caseList", utilityBaseCmp.checkNameSpace(JSON.parse(storeResponse).caseList,false));
            } else if (state === "INCOMPLETE") {
                helper.showToast(component, event, helper, "error", "Response is Incomplete.", "Error!");

            } else if (state === "ERROR") {

                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(component, event, helper, "error", errors[0].message, "Error!");

                    }
                } else {

                    helper.showToast(component, event, helper, "error", "Unknown error", "Error!");
                }
            }
        });
        	$A.enqueueAction(action);
        },
    
    showToast: function(component, event, helper, type, msg, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type": type
        });
        toastEvent.fire();
    }
		
})