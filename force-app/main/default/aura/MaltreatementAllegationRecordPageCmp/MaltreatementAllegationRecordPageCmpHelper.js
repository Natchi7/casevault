({
	getInitialInfos: function(component, event, helper) {
        
        var action = component.get("c.fetchInformation");
        
        action.setParams({
            'investigationId': component.get("v.recordId")
        });   
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.childList", component.find("utils").checkNameSpace(JSON.parse(storeResponse).victimList,false));
                if (JSON.parse(storeResponse).victimList.length == 0) {
                    component.set("v.childErrorMessage", true);
                } else {
                    component.set("v.childErrorMessage", false);
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
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
    },
    
    checkNamespaceApplicable : function(component, event, helper,  Obj) {
        
        var addNSMap = Obj;
        if("{!$Label.HasNamespace}" == "true") {
            var Namespace = $A.get("$Label.c.Org_NamePrefix");
            if (Obj && Object.keys(Obj).length) {
            
                Object.keys(Obj).forEach((element) => {
                    
                    if (Obj[element].endsWith('__c') && !(Obj[element].startsWith(Namespace))) {
                        addNSMap[element] = Namespace + Obj[element];
                    } else {
                      addNSMap[element] = Obj[element];                   
                    }
                });
                component.set("v.recordEditFormFields", addNSMap);
            } 
        } else {
            component.set("v.recordEditFormFields", Obj);
        }
        
    },
    
    showToast : function(component, event, helper, type, msg, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type":type
        });
        toastEvent.fire();
    },
})