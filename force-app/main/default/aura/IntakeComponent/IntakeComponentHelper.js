({
	saveMethod : function(component, event, helper) {
        
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
		var action = component.get("c.updateIntake");
        var intakeRecNSIns = component.find("utils").checkNameSpace(component.get('v.intakeRecordIns'),true);
        action.setParams({"updatingIntakeJSONStr": JSON.stringify(intakeRecNSIns)
                         });
        
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                //location.reload();
                $A.get('e.force:refreshView').fire();
            } else if (state === "INCOMPLETE") {
                helper.showToast(component, event, helper, 'error', 'Response is Incompleted', 'Error!');
            } else if (state === "ERROR") {
                var errors = result.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        var errMsg = 'Save Error:' + errors[0].message;
                        helper.showToast(component, event, helper, 'error', errMsg, 'Error!');
                    }
                } else {
                    helper.showToast(component, event, helper, 'error', 'Unknown error', 'Error!');
                }
            } else {
                helper.showToast(component, event, helper, 'error', 'Something wrong', 'Error!');
            }
        });
        $A.enqueueAction(action);
	},
    
    //show toast error message
    showToast : function(component, event, helper, type, msg, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type":type
        });
        toastEvent.fire();
	}
    
   
})