({
    getInitialInfos: function(component, event, helper) {
        
        component.set('v.spinner', true);
        var action = component.get("c.fetchInformation");
        
        action.setParams({
            'investigationId': component.get("v.recordId")
        });   
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.FindingsList", component.find("utils").checkNameSpace(JSON.parse(storeResponse).investigationFindingsList), false);
                component.set("v.FindingsOptionsList", JSON.parse(storeResponse).findingsPicklist);
                component.set("v.victimName",JSON.parse(storeResponse).allegedVictim);
                component.set("v.maltreator",JSON.parse(storeResponse).allegedMaltreator);
                component.set("v.ContributingFactorOptionsList",JSON.parse(storeResponse).ContributingFactorPicklist);
                component.set("v.victimRole",JSON.parse(storeResponse).personRole);
                component.set("v.showApprovalBtn", JSON.parse(storeResponse).showApprovalBtn);
                var relationshipResponse = component.find("utils").checkNameSpace(JSON.parse(storeResponse).relationshipValues,false);
                var findingsList = component.get("v.FindingsList");
                for(let i = 0; i < findingsList.length; i++) {
                    findingsList[i].relationshipValue = relationshipResponse[i];
                    if( findingsList[i].Findings__c ) {
                        findingsList[i].enableCompleteInvestigation = true;
                    }
                }
                component.set("v.FindingsList",findingsList);
                if (JSON.parse(storeResponse).investigationFindingsList.length == 0) {
                    
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