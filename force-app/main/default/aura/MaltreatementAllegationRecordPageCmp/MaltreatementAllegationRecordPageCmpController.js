({
    doInit: function(component, event, helper) {

        component.set('v.spinner', true);
        helper.getInitialInfos(component, event, helper);
        helper.checkNamespaceApplicable(component, event, helper, component.get("v.recordEditFormFields"));
    },

    getMaltreatmentRec: function(component, event, helper) {

        var action = component.get("c.fetchMaltreatmentRecords");
        action.setParams({
            'investigationId': component.get("v.recordId"),
            'childId': event.getSource().get("v.value")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = JSON.parse(response.getReturnValue());
                component.set("v.maltreatmentList", component.find("utils").checkNameSpace(storeResponse, false));
                if (storeResponse.length == 0) {
                    component.set("v.maltreatmentErrorMessage", true);
                } else {
                    component.set("v.maltreatmentErrorMessage", false);
                }
            } else if (state === "INCOMPLETE") {
                helper.showToast(component, event, helper, "error", "Response is Incompleted", "Error!");
                //alert('Response is Incompleted');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(component, event, helper, "error", errors[0].message, "Error!");
                        /*alert("Error message: " +
                            errors[0].message);*/
                    }
                } else {
                    helper.showToast(component, event, helper, "error", "Unknown error", "Error!");
                    //alert("Unknown error");
                }
            } else {
                helper.showToast(component, event, helper, "error", "Something went wrong", "Error!");
                //alert('Something went wrong');
            }
        });
        $A.enqueueAction(action);
    },

    refreshPage: function(component, event, helper) {

        component.set('v.childList', []);
        component.set('v.maltreatmentList', []);
        component.set('v.childErrorMessage', false);
        component.set('v.maltreatmentErrorMessage', false);
        component.set('v.spinner', false);
        helper.getInitialInfos(component, event, helper);
    }
})