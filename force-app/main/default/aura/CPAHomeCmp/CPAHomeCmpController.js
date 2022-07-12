({
	getInitialInfos: function(component, event, helper) {
        component.set("v.isSpinner", true);
        var action = component.get("c.getInitialInfoCPAHome");
        
        action.setParams({
            'placementRecordId': component.get("v.recordId")
        });   
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //component.set("v.CPAHomeOptions", JSON.parse(storeResponse).cpaHomeList);
                var cpaHomeNsIns = component.find("utils").checkNameSpace(JSON.parse(storeResponse),true);
                component.set("v.CPAHomeOptions", cpaHomeNsIns.privateCPAHomes);
                component.set("v.placementRec", cpaHomeNsIns.placementRecord);
				component.set("v.exitTypepeoptions",cpaHomeNsIns.exitTypePickList);
                component.set("v.reasonforExitoptions",cpaHomeNsIns.reasonForExitPickList);
            } else if (state === "INCOMPLETE") {
                helper.showToast(component, event, helper, "error", "Response is Incompleted", "Error!");
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
            component.set("v.isSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    handleChange: function (cmp, event) {
        // This will contain the string of the "value" attribute of the selected option
        //var selectedOptionValue = JSON.parse(event.getParam("value"));
        /*var currentPlacementRec = cmp.get('v.placementRec');
        if (selectedOptionValue) {
        
        currentPlacementRec.CPA_Home_Id__c = selectedOptionValue.Id;
        currentPlacementRec.CPA_Home_Billing_Street__c = selectedOptionValue.BillingStreet;
        currentPlacementRec.CPA_Home_Billing_City__c = selectedOptionValue.BillingCity;
        currentPlacementRec.CPA_Home_Billing_State__c = selectedOptionValue.BillingState;
        currentPlacementRec.CPA_Home_Billing_Postal_Code__c = selectedOptionValue.BillingPostalCode;
        currentPlacementRec.CPA_Home_Billing_Country__c = selectedOptionValue.BillingCountry;
        currentPlacementRec.CPA_Home_Provider_Id__c = selectedOptionValue.Casevault_ProID__c;
        //alert("Option selected with value: '" + selectedOptionValue + "'");
        
        } else {
        	currentPlacementRec.CPA_Home_Id__c = null;
        currentPlacementRec.CPA_Home_Billing_Street__c = null;
        currentPlacementRec.CPA_Home_Billing_City__c = null;
        currentPlacementRec.CPA_Home_Billing_State__c = null;
        currentPlacementRec.CPA_Home_Billing_Postal_Code__c = null;
        currentPlacementRec.CPA_Home_Billing_Country__c = null;
        currentPlacementRec.CPA_Home_Provider_Id__c = null;    
        }
        cmp.set('v.placementRec', currentPlacementRec);*/
    },
    
    onSave: function (component, event, helper) {
    	var requiredInputField = component.find("requiredFields");
        	var isValid = true;
                if(!requiredInputField.get("v.value")) {
                    
                    $A.util.addClass(requiredInputField, 'slds-has-error');
                    isValid = false;
                } else {
                    
                    $A.util.removeClass(requiredInputField, 'slds-has-error');
                } 
        if (isValid) {
            var action = component.get("c.onSavePlacementCPAHome");
            var placementRecNsIns = component.find("utils").checkNameSpace(component.get("v.placementRec"),true);
            action.setParams({
                'placementDataJSON': JSON.stringify(placementRecNsIns)
            });
            action.setCallback(this, function(response) {
                // hide spinner when response coming from server 
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    helper.showToast(component, event, helper, "success", "Placement CPA Home detail updated successfully!", "Success!");
                    $A.get('e.force:refreshView').fire();
        			$A.get("e.force:closeQuickAction").fire();
                    
                    
                } else if (state === "INCOMPLETE") {
                    
                    helper.showToast(component, event, helper, "error", "Response is Incompleted", "Error!");    
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
            });
            $A.enqueueAction(action);
        } else {
            helper.showToast(component, event, helper, "error", "Please complete the required field(s).", "Error!");    
        }    
        
    },
    
    onCancel: function (component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();    
    }    
    
})