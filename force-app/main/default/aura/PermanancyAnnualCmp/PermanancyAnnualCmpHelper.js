({
    getInitialInformations : function(component, event, helper, initial) {
        
        var columns = [
            {label: 'REVIEW DATE', fieldName: 'Review_Date__c', type: 'date', typeAttributes:{year: "numeric",month: "2-digit",day: "2-digit"}},
            {label: 'APPROVAL STATUS', fieldName: 'Approval_Status__c', type: 'text'}
        ];
        //{label: 'ACTION', type: 'button', initialWidth: 135, typeAttributes: { label: 'View', name: 'view', title: 'Click to View'}}
        
        component.set("v.columns",columns);
        var action = component.get("c.getAnnuvalReviewsInitialInformation");
        action.setParams({'permanencyPlanId': component.get("v.recordId")});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var utilityBase = component.find("utils");
                component.set("v.annualReviewsOptions",JSON.parse(storeResponse).annualReviewsPicklist);
                var permanencyRec = utilityBase.checkNameSpace(JSON.parse(storeResponse).permanencyPlanRecord, false);
           		component.set("v.permanancyPlanRec", permanencyRec);
                if (permanencyRec.Guardianship_Planing__c == '6') {
                	component.set("v.isReadOnly", true);
                    component.set("v.isAllReadOnly", true);
                } else if (component.get("v.onClickCurrentStage") < permanencyRec.Guardianship_Planing__c) {
                    component.set("v.isReadOnly", true);
                }
                component.set("v.annualReviewList", utilityBase.checkNameSpace(JSON.parse(storeResponse).annualReviewsList, false));
                var existingNotApprovedAnnual =  utilityBase.checkNameSpace(JSON.parse(storeResponse).existingAnnualReviewRec, false);
                component.set("v.showApprovalBtn", JSON.parse(storeResponse).showApprovalBtn);

                if (existingNotApprovedAnnual.length) {
                    component.set("v.annualReviewsRec",existingNotApprovedAnnual[0]);
                    if (initial) {
                        component.set("v.openAnnualReviewModal", true);
                    }
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
    
    showToast : function(component, event, helper, type, msg, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type":type,
            "duration": 8000
        });
        toastEvent.fire();
    },
    
    updatePermanency : function(component,event,helper){
        
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
                        helper.getInitialInformations(component, event, helper, false);
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
    }
})