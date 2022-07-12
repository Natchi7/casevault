({
    handleClick: function(component, event, helper) {
        helper.getContactIns(component);
        component.set("v.isModalOpen", true);
    },

    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    onCombohandleChange: function(component, event) {

        var selectedOptionValue = event.getParam("value");
        component.set("v.recommendationSelectValue", selectedOptionValue);
    },

    updateHomeRecord: function(component,event, helper) {
        let contactWrapper = component.get("v.contactIns");
        if (component.get("v.recommendationSelectValue") == 'This home should be Approved') {
            if (contactWrapper.applicationSigned && contactWrapper.homeAssessment && contactWrapper.familyAssessment && contactWrapper.atleastOneHomeVisit && contactWrapper.recommendationsEntered &&
                contactWrapper.personalInfoStatus && contactWrapper.clearanceStatus && contactWrapper.backgroudStatus && contactWrapper.childhoodStatus && contactWrapper.adulthoodStatus &&
                contactWrapper.co_personalInfoStatus && contactWrapper.co_clearanceStatus && contactWrapper.co_backgroudStatus && contactWrapper.co_childhoodStatus && contactWrapper.co_adulthoodStatus &&
                contactWrapper.householdStatus && contactWrapper.childEvaluStatus && contactWrapper.clearanceTabStatus && contactWrapper.familyAsAStatus && contactWrapper.petsStatus && contactWrapper.referenceStatus && contactWrapper.motivationStatus &&
                contactWrapper.backupStatus && contactWrapper.householdStatus && contactWrapper.childEvaluStatus) {
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

            } else {
                helper.showToast(component, event, helper, 'warning', 'If we select the recommendation value: This home should be approved. We need to have Complete the all tab status. ', 'Error!');
            }
        } else {
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
        }
    },
})