({
    getInitialInfos : function(component, event, helper) {
        
        helper.getInitialInformations(component, event, helper, true);
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
                    } else {   
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
            var annualRecIns = component.get("v.annualReviewsRec");
            if (annualRecIns && annualRecIns.Review_Date__c != null && annualRecIns.Primary_Caregiver_Sign_Date__c != null && annualRecIns.Director_Sign_Date__c != null) {
            annualRecIns.Permanency_Plan__c = component.get("v.recordId");
            component.set("v.annualReviewsRec",annualRecIns);
            var action = component.get("c.upsertAnnualReviews");
            action.setParams({
                'annualReviewsDataJSON': JSON.stringify(component.find("utils").checkNameSpace(component.get("v.annualReviewsRec"), true))
            });
            action.setCallback(this, function(response) {
                // hide spinner when response coming from server 
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    helper.showToast(component, event, helper, "success", "Annual Review record created successfully!", "Success!");
                    component.set("v.openAnnualReviewModal",false);
                    helper.getInitialInformations(component, event, helper, false);
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
                            value : 'Permanancy_Annual_Approval_Process'
                        },
                        {
                            name : 'OnClickedStage',
                            type : 'Number',
                            value : component.get("v.onClickCurrentStage")
                        },
                    	{
                            name : 'AnnualReviewId',
                            type : 'String',
                            value : storeResponse
                        }]
                    
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
                helper.showToast(component, event, helper, "error", "Please add the Annual Review record", "Error!"); 
            }
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
    
    addAnnualReview : function (component, event, helper) {
        
        //component.set("v.openAnnualReviewModal",true);
        var action = component.get("c.addRateAnnualRec");
        action.setParams({'permanencyPlanId': component.get("v.recordId")});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var existingRateRec = component.find("utils").checkNameSpace(JSON.parse(storeResponse).rateRec, false);
                var existingAnnualReviewRec = component.find("utils").checkNameSpace(JSON.parse(storeResponse).annualReviewRec, false);
                if (existingRateRec && existingRateRec.length) {
                    
                    if(existingRateRec[0].Approval_Status__c == 'Approved') {
                        if (existingAnnualReviewRec && existingAnnualReviewRec.length) {
                            if (existingAnnualReviewRec[0].Approval_Status__c == 'Approved') {
                                helper.showToast(component, event, helper, "warning", "Annual Review is Completed. If you want to create an annual review create a new rate under agreement Tab.", "Warning!");
                            } else {
                                helper.showToast(component, event, helper, "warning", "Current Annual Review approval must be complete to continue the create new Annual Review.", "Warning!");
                            }
                            
                        } else {
                            //Set default rate end date value set review Date in Annual Review 
                            component.set("v.annualReviewsRec",{});
                            var annualRecIns = component.get("v.annualReviewsRec");
                            annualRecIns.Review_Date__c = existingRateRec[0].Rate_End_Date__c;
            				component.set("v.annualReviewsRec",annualRecIns);
                            component.set("v.openAnnualReviewModal",true);   
                        }
                    } else {
                        helper.showToast(component, event, helper, "warning", "Rate approval must be completed to continue adding a new Annual Review.", "Warning!"); 
                    }
                } else {
                    helper.showToast(component, event, helper, "warning", "There is no existing Rate record found.", "Warning!");  
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