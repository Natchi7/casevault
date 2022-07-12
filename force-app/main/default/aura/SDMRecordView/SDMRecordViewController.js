({
    init: function(component, event, helper) {
        component.set("v.isSpinner", "True");
        if(component.get("v.isRefresh") == true) {
            helper.getCPSResponseWrapper(component, helper);
        } else {
        var action = component.get("c.getExpenses");
        action.setParams({ caseId: component.get("v.recordId")});

        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var comboList = response.getReturnValue();
                var CPSResponseObj = JSON.parse(comboList);
                component.set("v.CPSResponseMap", CPSResponseObj.CPSResponseMap);
                if(CPSResponseObj.sdmId != null) {
                    component.set("v.recordId", CPSResponseObj.sdmId);
                	component.set("v.showCPSResponse",true);
                	helper.getCPSResponseWrapper(component, helper);
                	component.set("v.isRefresh", true);
                }
                
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
            component.set("v.isSpinner", "false");
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        }
    },

    handleChange: function(component, event, helper) {
        component.set("v.isSpinner", "True");
        var selectedOptionValue = event.getParam("value");
        component.set("v.selectedAbuseName", selectedOptionValue);
        if (selectedOptionValue) {
            helper.getCPSResponseWrapper(component);
        } else {
            component.set("v.isSpinner", "false");
        }
    },

    checkBoxChangeHandle: function(component, event) {
        let updatingRulesMap = new Map(component.get("v.updatingSDMRuleMap"));
        //if (event.getSource().get('v.checked')) {
        updatingRulesMap.set(event.getSource().get('v.value').fieldAPIName, event.getSource().get('v.checked'));
        /*} else {
            if (updatingRulesMap.has(event.getSource().get('v.value').fieldAPIName)) {
                updatingRulesMap.delete(event.getSource().get('v.value').fieldAPIName);
            }
        }*/
        component.set("v.updatingSDMRuleMap", updatingRulesMap);
        let updatingRulesMap1 = new Map(component.get("v.updatingSDMRuleMap"));
        if (updatingRulesMap1.size > 0) {
            component.set('v.isReadOnly', false);
        } else {
            component.set('v.isReadOnly', true);
        }
    },

    saveSDMRule: function(component, event, helper) {

        component.set("v.isSpinner", "True");
        //if (component.get('v.updatingSDMRuleMap')) {
        if(component.get('v.updatingSDMRuleMap') != null) {
                var mapToSend = {}
                for (var key of component.get('v.updatingSDMRuleMap').keys()) {
                    mapToSend[key] = component.get('v.updatingSDMRuleMap').get(key);
                }
            
                var action = component.get("c.saveSDMRuleRecord");
                action.setParams({ SDMId: component.get("v.recordId"), checkboxValueMap: mapToSend });
                // Add callback behavior for when response is received
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //helper.getCPSResponseWrapper(component, component.get("v.selectedAbuseName"));  
                        helper.showToast(component, event, helper, 'success', 'CPS Response type updated successfully.', 'Success!');
                        //var workspaceAPI = component.find("workspace");
                        /*workspaceAPI.getFocusedTabInfo().then(function(response) {
                       	 var focusedTabId = response.tabId;*
                        	workspaceAPI.closeTab({tabId: focusedTabId});
                    	})
                        .catch(function(error) {
                        });*/
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
                    component.set("v.isSpinner", "false");
                });
                $A.enqueueAction(action);
        } else {
            helper.showToast(component, event, helper, 'success', 'CPS Response type updated successfully.', 'Success!');
            component.set("v.isSpinner", "false");

            /*var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
            })*/
        }
        
       
    },

    refreshPage: function(component, event, helper) {
		
            var reInit = component.get("c.init");
        	$A.enqueueAction(reInit);
            //$A.get('e.force:refreshView').fire();

        
    },
})