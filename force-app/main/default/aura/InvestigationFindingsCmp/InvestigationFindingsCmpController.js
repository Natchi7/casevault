({
    doInit: function(component, event, helper) {

        helper.getInitialInfos(component, event, helper);
    },

    onSave: function(component, event, helper) {
        var updatingCurrentRec = event.getSource().get('v.value');
        var isValid = true;
        let findingValue = updatingCurrentRec.Findings__c;
        if(findingValue) {
			$A.util.removeClass(requiredInputField, 'slds-has-error');            
        } else {
            $A.util.addClass(requiredInputField, 'slds-has-error'); 
            isValid = false
        }
        var requiredInputField = component.find("requiredFields");
        
        
        if (isValid) {
            var action = component.get("c.updateInvestigationFinding");
            action.setParams({
                'UpdatingInvestigationFindingStr': JSON.stringify(component.find("utils").checkNameSpace(updatingCurrentRec, true))
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.showToast(component, event, helper, "success", "Record saved successfully", "Success!");                  
                    var FindingList = component.get('v.FindingsList');
                    var recordId = updatingCurrentRec.Id;
                    //component.set("v.FindingsList",FindingList);
                    for(var i =0; i < FindingList.length; i++) {
                        if(FindingList[i].Id == recordId) {
                            FindingList[i].enableCompleteInvestigation = true;

                        }    
                    	component.set("v.FindingsList",FindingList);
                    }
                    var activeSections = component.get("v.activeSections");
                    if (activeSections.includes(recordId)) {
                        var index = activeSections.indexOf(recordId);
                        activeSections.splice(index, 1);
                    }
                    component.set("v.activeSections", activeSections);

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
        } else {
            helper.showToast(component, event, helper, "error", "Please complete the required field(s).", "Error!");
        }
    },

    handleChange: function(component, event, helper) {

        component.set("v.selectedFindingId", event.getSource().get('v.name'));

    },

    closeModel: function(component, event, helper) {
        component.set("v.selectedFindingId", "");
        component.set("v.saveButton",true);

    },

    refreshPage: function(component, event, helper) {

        component.set('v.activeSections', []);
        component.set('v.selectedFindingId', "");
        component.set('v.FindingsList', []);
        component.set('v.FindingsOptionsList', []);
        component.set('v.childErrorMessage', false);
        component.set('v.spinner', true);
        helper.getInitialInfos(component, event, helper);
        component.set('v.spinner', false);
    },
    
     
    onSubmitForApporval: function(component, event, helper) {
        component.set("v.openModal",true);
        var flow = component.find('flowData');
        var inputVariables = [
            {
                name : "InvestigationFindingRecordId",
                type : "String",
                value : event.getSource().get('v.name')
            }
        ];
        flow.startFlow('Investigation_Finding_Approval_Flow',inputVariables); 
       
    },
    
     closeApprovalModel : function(component, event, helper) {
    	component.set("v.openModal",false);
	},
    
    handleStatusChange : function(component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
        	component.set("v.openModal",false);
    	}
    },
    
    openViewModal : function(component, event, helper) {
        component.set('v.readOnly',true);
    	component.set('v.selectedFindingId', event.getSource().get('v.value'));
        component.set("v.saveButton",false);
	},
    
    openEditModal : function(component, event, helper) {
    	component.set('v.readOnly',false);
        component.set('v.selectedFindingId', event.getSource().get('v.value'));
        component.set("v.saveButton",true);
	},
    

})