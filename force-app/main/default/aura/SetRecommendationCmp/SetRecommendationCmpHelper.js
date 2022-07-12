({
    getContactIns: function(component) {
        var action = component.get("c.getContact");
        action.setParams({ "homeApprovalId": component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnWrapper = response.getReturnValue();
                component.set("v.contactIns", JSON.parse(returnWrapper));
                component.set("v.recommendationSelectValue",JSON.parse(returnWrapper).homeRecommendation);
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

    updateHomeRecord: function(component) {
        var action = component.get("c.updateHomeApproval");
        action.setParams({ "homeApprovalId": component.get("v.recordId"), "recommendationValue": component.get("v.recommendationSelectValue") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast(component, event, helper, "success", "Set Recommendation Updated", "SUCCESS!");
                location.reload(true);
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
            component.set("v.isModalOpen", false);

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
    },
})