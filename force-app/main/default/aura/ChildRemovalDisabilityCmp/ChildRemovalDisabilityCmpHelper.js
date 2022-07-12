({
    getInitInfo: function(component) {

        var action = component.get("c.getInitialInfo");
        action.setParams({
            "childRemovalId": component.get('v.recordId')
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                var utilityBaseCmp = component.find("utils");
                component.set('v.childRemovalIns', utilityBaseCmp.checkNameSpace(JSON.parse(resultData).childRemovalRecord), false);
                component.set('v.personalHygieneOptions', utilityBaseCmp.checkNameSpace(JSON.parse(resultData).personalHygienePicklist), false);
                component.set('v.specialNeedsOptions', utilityBaseCmp.checkNameSpace(JSON.parse(resultData).specialNeedsPicklist, false));
                if (component.get("v.childRemovalIns").Does_the_person_have_disabilities__c) {
                    component.set("v.disabledRadioButtons", false);
                }
            } else if (state === "INCOMPLETE") {
                helper.showToast(component, event, helper, "error", "Response is Incompleted", "Error!");
                //alert('Response is Incompleted');
            } else if (state === "ERROR") {
                var errors = result.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        /* alert("Error message: " + 
                               errors[0].message);*/
                        helper.showToast(component, event, helper, "error", errors[0].message, "Error!");
                    }
                } else {
                    helper.showToast(component, event, helper, "error", "Unknown error", "Error!");
                    //alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    //show toast error message
    showToast: function(component, event, helper, type, msg, title, duarationTime) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type": type,
            "duration": duarationTime
        });
        toastEvent.fire();
    },
})