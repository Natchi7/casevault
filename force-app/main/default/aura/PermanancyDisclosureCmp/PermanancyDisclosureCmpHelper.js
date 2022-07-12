({
	showToast : function(component, event, helper, type, msg, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type":type
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
    }
})