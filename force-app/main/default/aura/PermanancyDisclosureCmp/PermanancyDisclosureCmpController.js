({
    getInitialInfos: function(component, event, helper) {
        
        var action = component.get("c.getDisclosureInitialInformation");
        action.setParams({'permanencyPlanId': component.get("v.recordId")});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                var utilityBase = component.find("utils");
                var cpaProviderId = utilityBase.checkNameSpace(JSON.parse(storeResponse).cpaProviderId, false);
                component.set("v.cpaProvider",cpaProviderId);
                component.set("v.disclosureOptions",JSON.parse(storeResponse).disclosurePicklist);
                var permanencyRec = utilityBase.checkNameSpace(JSON.parse(storeResponse).permanencyPlanRecord, false);
           		component.set("v.permanancyPlanRec", permanencyRec);
                component.set("v.showApprovalBtn", JSON.parse(storeResponse).showApprovalBtn);

                if (permanencyRec.Guardianship_Planing__c == '6') {
                	component.set("v.isReadOnly", true);    
                } else if (component.get("v.onClickCurrentStage") < permanencyRec.Guardianship_Planing__c) {
                    component.set("v.isReadOnly", true);
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
        });
        $A.enqueueAction(action);
    },  
    
    onSave : function (component, event, helper) {
        helper.updatePermanency(component, event, helper);
    }, 
    
    onSubmitForApprovalAndSave : function (component, event, helper) {
        var requiredInputField = component.find("requiredFields");
        var isValid = true;
        if(Array.isArray(requiredInputField)) {
            for(var i = 0;i < requiredInputField.length;i++) {      
                if(!requiredInputField[i].get("v.value")) {
                    $A.util.addClass(requiredInputField[i], 'slds-has-error'); 
                    isValid = false;
                }else {   
                    $A.util.removeClass(requiredInputField[i], 'slds-has-error');
                }
            }
        } else {
            if(!requiredInputField.get("v.value")) {
                
                $A.util.addClass(requiredInputField, 'slds-has-error');
                isValid = false;
            }else{
                
                $A.util.removeClass(requiredInputField, 'slds-has-error');
            }
        }
        
        if (isValid) {
            var action = component.get("c.upsertApplication");
            action.setParams({
                'applicationDataJSON': JSON.stringify(component.find("utils").checkNameSpace(component.get("v.permanancyPlanRec"), true))
            });
            action.setCallback(this, function(response) {
                // hide spinner when response coming from server 
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    helper.showToast(component, event, helper, "success", "Permanancy record updated successfully!", "Success!");
                    component.set("v.openModal",true);
                    var flow = component.find("flowData");
                    var inputVariables = [
                        {
                            name : 'PermanencyPlanId',
                            type : 'String',
                            value : component.get("v.recordId")
                        },
                        {
                            name : 'ApprovalProcessName',
                            type : 'String',
                            value : 'Permanancy_Disclosure_Approval_Process'
                        },
                        {
                            name : 'OnClickedStage',
                            type : 'Number',
                            value : component.get("v.onClickCurrentStage")
                        },]
                        
                        flow.startFlow("Permanency_Plan_Proceed_Approval_Flow", inputVariables);
                        /* var url= '/'+storeResponse; 
                            setTimeout(function() { 
                                window.location = url;
                            }, 3000);*/
            
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
                                   });
            $A.enqueueAction(action);
        } else {
            helper.showToast(component, event, helper, "error", "Please complete the required field(s).", "Error!");    
        }
        
    },
    closeModel: function (component, event, helper) {
        component.set("v.openModal",false);
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.openModal",false);
        }
    },
})