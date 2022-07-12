({
    viewHistory: function(component, event, helper) {
        component.set("v.showHistoryModal", true);
        var action = component.get("c.getCurrentRecordHistroy");

        action.setParams({
            'placementRecordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.historyPlacementApprovalList", JSON.parse(storeResponse).approvalPlacementList);
                component.set("v.historyCaseApprovalList", JSON.parse(storeResponse).approvalCaseList);
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
})