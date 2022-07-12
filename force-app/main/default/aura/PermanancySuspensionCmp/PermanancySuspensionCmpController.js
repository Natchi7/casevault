({
    getInitialInfos: function(component, event, helper) {
        helper.getInitialInformations(component, event, helper, true);
    },
    
    onSave : function (component, event, helper) {
        helper.updatePermanency(component, event, helper);
    },
    
    handleHeaderAction : function(component, event, helper) {
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        helper.selectionRow(component, event, row, action, helper);
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
            var action = component.get("c.upsertSuspension");
            var suspensionIns = component.get("v.suspensionRec");
            suspensionIns.Permanency_Plan__c = component.get("v.recordId");
            var action = component.get("c.upsertSuspension");
            var exstingAllSuspensionRecs = component.get("v.suspensionList");
            var latestSuspenionApprovedRec;
            var isOverlapped = true;
            var overlappedErrorMsg = '';
            for(var i=0; i<exstingAllSuspensionRecs.length > 0; i++) { 
                if(exstingAllSuspensionRecs[i].Approval_Status__c == 'Approved') {
                    latestSuspenionApprovedRec = exstingAllSuspensionRecs[i];
                    break;
                }
            }
            /*if((suspensionIns.Start_Date__c <= latestSuspenionApprovedRec.End_Date__c && latestSuspenionApprovedRec.End_Date__c) && (suspensionIns.End_Date__c &&
              suspensionIns.End_Date__c >= latestSuspenionApprovedRec.Start_Date__c)) {*/
            if(latestSuspenionApprovedRec) {
                /*if((suspensionIns.Start_Date__c <= latestSuspenionApprovedRec.Start_Date__c && suspensionIns.End_Date__c >= latestSuspenionApprovedRec.Start_Date__c && latestSuspenionApprovedRec.End_Date__c) ||
                   (suspensionIns.Start_Date__c <= latestSuspenionApprovedRec.End_Date__c &&  suspensionIns.End_Date__c >= latestSuspenionApprovedRec.End_Date__c && latestSuspenionApprovedRec.End_Date__c)) {
                    isOverlapped = false;
                    helper.showToast(component, event, helper, 'error', "you can't add new suspension record in beween days choose another dates", "Error!");
                } else*/
                if(latestSuspenionApprovedRec.Start_Date__c < suspensionIns.Start_Date__c ) {
                    if(latestSuspenionApprovedRec.End_Date__c) {
                        if(latestSuspenionApprovedRec.End_Date__c < suspensionIns.Start_Date__c  ) {
                            
                            if(suspensionIns.End_Date__c) {
                                if(latestSuspenionApprovedRec.End_Date__c < suspensionIns.End_Date__c) {
                                    if( suspensionIns.Start_Date__c < suspensionIns.End_Date__c) {
                                        isOverlapped = true;
                                    } else {
                                        isOverlapped = false;
                                        overlappedErrorMsg = 'New suspension record end date should be greater than new start date.';
                                    }
                                } else {
                                    isOverlapped = false;
                                    overlappedErrorMsg = 'New suspension record end date must be greater than old end date.';
                                }
                            } else {
                                isOverlapped = true; 
                            }
                        } else {
                            isOverlapped = false;
                            overlappedErrorMsg = 'New suspension record Start date must be greater than old end date.';
                        }
                        
                    } else {
                        if(suspensionIns.End_Date__c) {
                            if (latestSuspenionApprovedRec.Start_Date__c < suspensionIns.End_Date__c) {
                                if ( suspensionIns.Start_Date__c < suspensionIns.End_Date__c)  {
                                    isOverlapped = true;
                                } else {
                                    isOverlapped = false;
                                    overlappedErrorMsg = 'New suspension record end date should be greater than new start date.';
                                }
                                
                            } else {
                                isOverlapped = false;
                                overlappedErrorMsg = 'New suspension record end date should be greater than old Start date.';
                            }
                        } else {
                            isOverlapped = true;
                        }
                    }
                } else {
                    isOverlapped = false;
                    overlappedErrorMsg = 'New suspension record start date should be greater than old Start date.';
                }
            }
            if(isOverlapped) {
                action.setParams({
                    'suspensionDataJSON': JSON.stringify(component.find("utils").checkNameSpace(component.get("v.suspensionRec"), true))
                });
                action.setCallback(this, function(response) {
                    // hide spinner when response coming from server 
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();
                        var toastMsg = suspensionIns.Id?'Suspension record updated successfully!':'Suspension record created successfully!';
                        helper.showToast(component, event, helper, "success", toastMsg, "Success!", 7000);
                        component.set("v.openSuspensionModal",false);
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
                                value : 'Permanancy_Suspension_Approval_Process'
                            },
                            {
                                name : 'OnClickedStage',
                                type : 'Number',
                                value : component.get("v.onClickCurrentStage")
                            },
                            {
                                name : 'SuspensionId',
                                type : 'String',
                                value : storeResponse
                            }]
                        flow.startFlow("Permanency_Plan_Proceed_Approval_Flow", inputVariables);
                        
                        
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
                helper.showToast(component, event, helper, "error", overlappedErrorMsg, "Error!", 7000);    
            }
        } else {
            helper.showToast(component, event, helper, "error", "Please complete the required field(s).", "Error!", 7000);    
        }
    },
    
    closeModel: function (component, event, helper) {
        component.set("v.openModal",false);
    },
    
    handleStatusChange : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.openModal",false);
            helper.getInitialInformations(component, event, helper, false);
        }
    },
    
    addSuspension : function (component, event, helper) {
        
        //component.set("v.openAnnualReviewModal",true);
        var action = component.get("c.addSuspensionRec");
        action.setParams({'permanencyPlanId': component.get("v.recordId")});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var existingSuspensionRec = component.find("utils").checkNameSpace(JSON.parse(storeResponse), false);
                if (existingSuspensionRec && existingSuspensionRec.length) {
                    if (!existingSuspensionRec[0].End_Date__c) {
                    	helper.showToast(component, event, helper, "warning", "Existing Suspension end date must be complete to continue the create new suspension.", "Warning!", 7000);
                    } else if (existingSuspensionRec[0].Approval_Status__c != 'Approved') {
                        helper.showToast(component, event, helper, "warning", "Existing Suspension approval must be complete to continue the create new suspension.", "Warning!", 7000);
                    } else {
                        component.set("v.suspensionRec",{});
                    	component.set("v.openSuspensionModal",true); 
                    }    
                    
                } else {
                    //Set default rate end date value set review Date in Annual Review 
                    component.set("v.suspensionRec",{});
                    component.set("v.openSuspensionModal",true);   
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
    
})