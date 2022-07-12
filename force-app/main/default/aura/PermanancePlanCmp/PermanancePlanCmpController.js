({
    
    getInitialInfos: function(component, event, helper) {
        var columns = [
            {label: 'Name', fieldName: 'ChildName', type: 'string', cellAttributes: { alignment: 'left' }}, 
            {label: 'Person Role', fieldName: 'Role', type: 'string'},
            {label: 'Age', fieldName: 'Age', type: 'number', cellAttributes: { alignment: 'left' }},
            {label: 'DOB', fieldName: 'DOB', type: 'date',typeAttributes:{month: "2-digit",day: "2-digit",year: "numeric"}},
        ];
            component.set("v.columns",columns);
            var url = window.location.href;// get the current url  
            
            var newUrl= url.replaceAll('%2F','/');
            var lastIndex = newUrl.lastIndexOf('Service_Case__c');
            var serviceCaseId = newUrl.substring(lastIndex+16,lastIndex+34);// get the servicecase recordid from current page url
            component.set("v.serviceCaseId",serviceCaseId);
            var permancyRec = component.get("v.permanancyPlanRec");
            permancyRec.Service_Case__c = component.get("v.serviceCaseId");
            
            component.set("v.permanancyPlanRec",permancyRec);
            var action = component.get("c.getInitialInformation");
            action.setParams({
            'serviceCaseRecordId': component.get("v.serviceCaseId"),
            'permanencyPlanRecordId': component.get("v.recordId")
            });   
            action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
            var storeResponse = response.getReturnValue();
            //component.set("v.placementRecordId",JSON.parse(storeResponse).placementRecId.Id);
            if(JSON.parse(storeResponse).permanencyInst) {
            component.set("v.permanancyPlanRec",JSON.parse(storeResponse).permanencyInst);
            }
            var permancyRec = component.get("v.permanancyPlanRec");
            permancyRec.Placement__c =  component.get("v.placementRecordId");
            if (JSON.parse(storeResponse).approvedPlacementChildList.length == 0) {
            component.set("v.childErrorMessage", true);
            } else {
            component.set("v.childErrorMessage", false);
            }
            //var approvedChildPlacements = JSON.parse(storeResponse).approvedPlacementChildList;
            var approvedChildPlacements = component.find("utils").checkNameSpace(JSON.parse(storeResponse).approvedPlacementChildList,false);
            for ( var i = 0; i < approvedChildPlacements.length; i++ ) {
            
            var row = approvedChildPlacements[i];
        
        if ( row.Child__r ) {
            row.childId = row.Child__c;
            row.ChildName = row.Child__r.Name;
            row.Role = row.Child__r.Intake_Person_Role__c; 
            row.Age = row.Child__r.Age__c;
            row.DOB = row.Child__r.Date_of_Birth__c;
        }
        
    }
    component.set("v.childList", approvedChildPlacements);
    //component.set("v.childList",JSON.parse(storeResponse).childList);
    
    component.set("v.Primary", JSON.parse(storeResponse).primaryPicklist);
    component.set("v.Concurrent", JSON.parse(storeResponse).concurrentPicklist);
    component.set("v.options", JSON.parse(storeResponse).returnPicklist);
}else if (state === "INCOMPLETE") {
    helper.showToast(component, event, helper, "error", "Response is Incompleted", "Error!");
    //alert('Response is Incompleted');
}else if (state === "ERROR") {
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
    
    handleRowSelection: function(component, event, helper) {
        var selectedChildPlacementRec = event.getParam('selectedRows')[0];
        var permancyRec = component.get("v.permanancyPlanRec");
        permancyRec.Contact__c = selectedChildPlacementRec.childId;
        permancyRec.Placement__c = selectedChildPlacementRec.Id;
        component.set("v.permanancyPlanRec",permancyRec);
    },  
        
        onSave : function (component, event, helper) {
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
                var isChildAdded = true;
                if(!component.get("v.permanancyPlanRec").Contact__c){
                    helper.showToast(component, event, helper, "error", "Please Select the Child.", "Error!");
                    isChildAdded = false
                }
                var isUpdate = component.get("v.permanancyPlanRec").Id? true : false;
                if(isChildAdded){
                    var action = component.get("c.createPermanancyPlan");
                    action.setParams({
                        'permanancyDataJSON': JSON.stringify(component.find("utils").checkNameSpace(component.get("v.permanancyPlanRec"), true))
                    });
                    action.setCallback(this, function(response) {
                        // hide spinner when response coming from server 
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var storeResponse = response.getReturnValue();
                            var url= '/'+storeResponse; 
                            if(!isUpdate){
                                helper.showToast(component, event, helper, "success", "Permanancy record created successfully!", "Success!");
                                    
                            } else {
                                helper.showToast(component, event, helper, "success", "Permanancy record updated successfully!", "Success!"); 
                            }
                            var appEvent = $A.get("e.c:servicecaseRefreshEvent");
                            appEvent.fire();
                            
                            window.setTimeout(
                                $A.getCallback(function() {
                                    	   var workspaceAPI = component.find("workspace");
                                           workspaceAPI.getFocusedTabInfo().then(function(response) {
                                           var focusedTabId = response.tabId;
                                           workspaceAPI.closeTab({tabId: focusedTabId});  
                                })
                                }), 4000
							);
                            

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
                }
            } else {
                helper.showToast(component, event, helper, "error", "Please complete the required field(s).", "Error!");    
            }    
        }
});