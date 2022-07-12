({
    
    closeCurrentAccordian: function (cmp, event, helper) {
        
        helper.showToast(cmp, event, helper, "success", "Record saved Succesfully", "Success!");
            var appEvent = $A.get("e.c:RefreshEvent");
            appEvent.setParams({
                "message" : "An application event fired me. " +
                "It all happened so fast. Now, I'm everywhere!" });
            appEvent.fire();
            
        var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
      
        var recordId = updatedRecord.response.id;
        var activeSections = cmp.get("v.activeSections");
        if (activeSections.includes(recordId)) {
            var index = activeSections.indexOf(recordId);
            activeSections.splice(index, 1);
        }
        cmp.set("v.activeSections", activeSections);
        let accordianSectionTag = cmp.find('accSection');
        
        if(Array.isArray(accordianSectionTag)) {
        	accordianSectionTag.forEach(item => {
                if(item.get('v.name') === recordId) {
                    $A.util.addClass(item, 'CompletedColor');
                }    
        	}); 
        } else {
        	 if(accordianSectionTag.get('v.name') === recordId) {
            	$A.util.addClass(accordianSectionTag, 'CompletedColor');
        	}    
        }    
        
	},
            
    errorSubmission: function (cmp, event, helper) {
                
        helper.showToast(cmp, event, helper, "error", "Something went wrong. Error on form submission", "Error!");
    },
    
    handleChange: function (component, event, helper) {
                

        var value = event.getParam("checked");
        var recordId = event.getSource().get('v.name');
        var action = component.get("c.updateMaltreatmentAllegation");
        action.setParams({
            'recordId': recordId,
            'field': value
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(value == true) {
                    helper.showToast(component, event, helper, "info", "This maltreatment  marked as  not applicable", "Info!");
                } else if(value == false) {
                    helper.showToast(component, event, helper, "info", "This maltreatment  marked as  applicable", "Info!");
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
            } else {
                helper.showToast(component, event, helper, "error", "Something went wrong", "Error!");
                //alert('Something went wrong');
            }
        });
        $A.enqueueAction(action);
    },
    
    /*handleSubmit: function (cmp, event, helper) {
                

            var fields = event.getParam('fields');
            let index;
            var record = event.getParams();
           
            let foundelement = cmp.get("v.maltreatmentList").find(ele => ele.Id == fields.Id);
                                if (foundelement) {
                                    index=cmp.get("v.maltreatmentList").indexOf(foundelement);
                                }   
           
            fields.This_maltreatment_is_not_applicable__c = cmp.get("v.maltreatmentList")[index].This_maltreatment_is_not_applicable__c;
            cmp.find(index).submit(fields);
    },*/
                              
})