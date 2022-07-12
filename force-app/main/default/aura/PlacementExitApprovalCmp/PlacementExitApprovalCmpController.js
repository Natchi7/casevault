({
    viewHistory: function(component, event, helper) {
        var action = component.get("c.getCurrentRecordHistroy");

        action.setParams({
            'placementRecordId': component.get("v.placementId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.historyPlacementApprovalList", JSON.parse(storeResponse).approvalPlacementList);
               
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
    }

})