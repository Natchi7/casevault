({
    getInitialInformations : function(component, event, helper, initial) {
        
        var columns = [
            {label: 'PROVIDER ID', fieldName: 'Provider_Id__c', type: 'number', cellAttributes: { alignment: 'left' }}, 
            {label: 'RATE BEGIN DATE', fieldName: 'Rate_Begin_Date__c', type: 'date', typeAttributes:{year: "numeric",month: "2-digit",day: "2-digit"}},
            {label: 'RATE END DATE', fieldName: 'Rate_End_Date__c', type: 'date', typeAttributes:{year: "numeric",month: "2-digit",day: "2-digit"}},
            {label: 'PAYMENT AMOUNT', fieldName: 'Negotiated_Amount__c', type: 'currency', typeAttributes: { currencyCode: 'USD'}},
            {label: 'STATUS', fieldName: 'Approval_Status__c', type: 'text'},
            {label: 'ACTION', type: 'button', initialWidth: 135, typeAttributes: { label: 'View', name: 'view', title: 'Click to View'}}
        ];
        component.set("v.columns",columns);
        var action = component.get("c.getAgreementInitialInformation");
        action.setParams({'permanencyPlanId': component.get("v.recordId")});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var permanencyNsRecIns = component.find("utils").checkNameSpace(JSON.parse(storeResponse), false);
                var cpaProviderId = JSON.parse(storeResponse).cpaProviderId;
                component.set("v.cpaProvider",cpaProviderId);
                component.set("v.rateTypePicklistOption", permanencyNsRecIns.rateTypePicklist);
                component.set("v.hasNotificationPicklistOption", permanencyNsRecIns.hasNotificationPicklist);
                component.set("v.childsupportPicklistOption", permanencyNsRecIns.childsupportPicklist);
                component.set("v.isChildreceivingTCAPicklistOption", permanencyNsRecIns.isChildreceivingTCAPicklist);
                component.set("v.showApprovalBtn", permanencyNsRecIns.showApprovalBtn);
                var permanencyRec = permanencyNsRecIns.permanencyPlanRecord;
                if (permanencyRec.Placement__r.End_Date__c != null) {
                    permanencyRec.All_Placements_and_Removal_have_been_End__c = true;
                } else {
                    permanencyRec.All_Placements_and_Removal_have_been_End__c = false;
                }
                component.set("v.permanancyPlanRec", permanencyRec);
                component.set("v.providerId", permanencyRec.Placement__r.Provider__c);
                if (permanencyRec.Guardianship_Planing__c == '6') {
                    component.set("v.isReadOnly", true);
                    component.set("v.isAllReadOnly", true);
                } else if (component.get("v.onClickCurrentStage") < permanencyRec.Guardianship_Planing__c) {
                    component.set("v.isReadOnly", true);
                }
                var existingNotApprovedRate = permanencyNsRecIns.existingRateRec;
                
                if (existingNotApprovedRate.length) {
                    component.set("v.RateRec",existingNotApprovedRate[0]);
                    if (initial) {
                        component.set("v.openRateModal", true);
                    }
                } 
                component.set("v.RateList",permanencyNsRecIns.rateRecList);
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
                if(requiredInputField[i].get("v.type") != "checkbox"){
                    if(!requiredInputField[i].get("v.value")) {
                        $A.util.addClass(requiredInputField[i], 'slds-has-error'); 
                        isValid = false;
                    }else {   
                        $A.util.removeClass(requiredInputField[i], 'slds-has-error');
                    }
                } else {
                    if(!requiredInputField[i].get("v.checked")) {
                        $A.util.addClass(requiredInputField[i], 'slds-has-error'); 
                        isValid = false;
                    } else {   
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
            var startDate = component.get("v.permanancyPlanRec").Agreement_Start_Date__c;
            var beginDate =component.get("v.RateRec").Rate_Begin_Date__c;
            
            var rateRecIns = component.get("v.RateRec");
            if (rateRecIns && rateRecIns.Rate_End_Date__c != null) {
                const oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
                const firstDate = new Date(rateRecIns.Rate_Begin_Date__c);
                const secondDate = new Date(rateRecIns.Rate_End_Date__c);
                const diffDays = Math.round(Math.abs((firstDate - secondDate) / oneDay));
                if(beginDate > startDate){
                    if (diffDays == 365) {
                        //if (rateRecIns.Negotiated_Amount__c == null || /^\d*\.?\d*$/.test(rateRecIns.Negotiated_Amount__c)) {
                        rateRecIns.Permanency_Plan__c = component.get("v.recordId");
                        component.set("v.RateRec",rateRecIns);
                        var action = component.get("c.upsertAgreement");
                        action.setParams({
                            'permanencyPlanDataJSON': JSON.stringify(component.find("utils").checkNameSpace(component.get("v.permanancyPlanRec"), true)),
                            'rateDataJSON': JSON.stringify(component.find("utils").checkNameSpace(component.get("v.RateRec"), true)),
                            'isApproved': component.get("v.isReadOnly")
                        });
                        action.setCallback(this, function(response) {
                            // hide spinner when response coming from server 
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var storeResponse = response.getReturnValue();
                                helper.showToast(component, event, helper, "success", "Permanancy record updated successfully!", "Success!");
                                /*  var url= '/'+storeResponse; 
                    setTimeout(function() { 
                        window.location = url;
                    }, 3000);*/
                                component.set("v.openRateModal", false);	
                                helper.getInitialInformations(component, event, helper, false);
                                
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
                    //} else {
                    //    helper.showToast(component, event, helper, "Please enter only numeric amount value", errMsg, "Error!"); 
                    //}
                } else {
                    var errMsg = 'Rate end date and begin date difference should be 365 days. But actual days difference: '+ diffDays;
                    helper.showToast(component, event, helper, "error", errMsg, "Error!");    
                }
                } else {
                  helper.showToast(component, event, helper, "error", "Rate begin Date should not be less than agreement start date", "Error!");  
                }
            } else {
                helper.showToast(component, event, helper, "error", "Please add the Rate record", "Error!");        
            }
        } else {
            helper.showToast(component, event, helper, "error", "Please complete the required field(s).", "Error!");    
        }
    }
})