({
    onSubmitForApprovalAndSave : function (component,event,helper) {
        var requiredInputField = component.find("requiredFields");
        var isValid = true;
        if(Array.isArray(requiredInputField)) {
            for(var i = 0;i < requiredInputField.length;i++) {
                if(requiredInputField[i].get("v.type") != "checkbox"){
                    if(!requiredInputField[i].get("v.value")) {
                        $A.util.addClass(requiredInputField[i], 'slds-has-error'); 
                        isValid = false;
                    }else {   
                        $A.util.removeClass(requiredInputField[i], 'slds-has-error');
                    }
                } else{
                    if(!requiredInputField[i].get("v.checked")) {
                        $A.util.addClass(requiredInputField[i], 'slds-has-error'); 
                        isValid = false;
                    }else {   
                        $A.util.removeClass(requiredInputField[i], 'slds-has-error');
                    }
                }
            }
        } else {
            if(requiredInputField.get("v.type") != "checkbox"){
                if(!requiredInputField.get("v.value")) {
                    
                    $A.util.addClass(requiredInputField, 'slds-has-error');
                    isValid = false;
                }else{
                    
                    $A.util.removeClass(requiredInputField, 'slds-has-error');
                }
            } else {
                if(!requiredInputField.get("v.checked")) {
                    $A.util.addClass(requiredInputField, 'slds-has-error'); 
                    isValid = false;
                }else {   
                    $A.util.removeClass(requiredInputField, 'slds-has-error');
                }
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
                            value : 'Permanancy_Application_Approval_Process'
                        },
                        {
                            name : 'OnClickedStage',
                            type : 'Number',
                            value : component.get("v.onClickCurrentStage")
                        },
                    ]
                        
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
    
    closeModel : function(component,event,helper) {
        component.set("v.openModal",false);
    },
    
    handleStatusChange : function (component, event) {
        
        if(event.getParam("status") === "FINISHED") {
            component.set("v.openModal",false);
        }
    },
    
    getInitialInfos :function (component,event,helper) {
        var action = component.get("c.getApplicationInitialInformation");
        action.setParams({'permanencyPlanId': component.get("v.recordId")});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                var applicationInfos =  JSON.parse(storeResponse);
                var utilityBase = component.find("utils");
                var permanencyRec = utilityBase.checkNameSpace(applicationInfos.permanencyPlanRecord, false);
                component.set("v.GuradianRelationoptions", utilityBase.checkNameSpace(applicationInfos.GurdianRelationPicklist, false));
                var applCoAppls = utilityBase.checkNameSpace(applicationInfos.applicantCoApplList, false);
                var cpaProviderId =applicationInfos.cpaProviderId;
                component.set("v.cpaProvider",cpaProviderId);
                component.set("v.showApprovalBtn", applicationInfos.showApprovalBtn);
                if (applCoAppls.length) {
                    for(var i = 0;i < applCoAppls.length;i++) {
                        if (applCoAppls[i].Applicant_or_Co_Applicant__c == 'Applicant') {
                            permanencyRec.Guardian_One_Name__c = applCoAppls[i].Name;
                            permanencyRec.Guardian_One_SSN__c = applCoAppls[i].SSN__c;
                            permanencyRec.Guardian_One_DOB__c = applCoAppls[i].Date_of_Birth__c;
                        } else {
                            permanencyRec.Guardian_Two_Name__c = applCoAppls[i].Name;
                            permanencyRec.Guardian_Two_SSN__c = applCoAppls[i].SSN__c;
                            permanencyRec.Guardian_Two_DOB__c = applCoAppls[i].Date_of_Birth__c;
                        }    
                    }    
                }
                component.set("v.permanancyPlanRec", permanencyRec);
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
    
    onSave: function(component,event,helper){
        helper.updatePermanency(component,event,helper);
    }
    
})