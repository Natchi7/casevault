({
    getHistory: function(component, columns) {
        var action = component.get("c.getService");
        action.setParams({
            'recordId': component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.columns", columns);
                var storeResponse = response.getReturnValue();

                if (JSON.parse(storeResponse).serviceCaseList.length == 0) {
                    component.set("v.childErrorMessage", true);
                } else {
                    component.set("v.childErrorMessage", false);
                }
                component.set("v.serviceCaseList", JSON.parse(storeResponse).serviceCaseList);

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
    //show toast error message
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