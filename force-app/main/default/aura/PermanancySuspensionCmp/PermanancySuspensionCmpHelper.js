({
    getInitialInformations : function(component, event, helper, initial) {
        /*var actions = [
            { label: 'Show details', name: 'show_details' },
            { label: 'Delete', name: 'delete' }
        ]*/
        //component.set("v.actions",actions);
        var actions = helper.getRowActions.bind(this, component);
        var columns = [
            {label: 'Suspension Reason', fieldName: 'Suspension_Reason__c', type: 'text'},
            {label: 'Start Date', fieldName: 'Start_Date__c', type: 'date', typeAttributes:{year: "numeric",month: "2-digit",day: "2-digit"}},
            {label: 'End Date', fieldName: 'End_Date__c', type: 'date', typeAttributes:{year: "numeric",month: "2-digit",day: "2-digit"}},
            {label: 'Approval Status', fieldName: 'Approval_Status__c', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions} }
        ];
        component.set("v.columns",columns);
        var action = component.get("c.getSuspensionInitialInformation");
        action.setParams({'permanencyPlanId': component.get("v.recordId")});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var utilityBase = component.find("utils");
                component.set("v.showApprovalBtn", JSON.parse(storeResponse).showApprovalBtn);
                component.set("v.suspensionList", utilityBase.checkNameSpace(JSON.parse(storeResponse).suspensionList, false));
                component.set("v.suspensionReasonOptions", JSON.parse(storeResponse).suspensionReasonPicklist);
                var permanencyRec = utilityBase.checkNameSpace(JSON.parse(storeResponse).permanencyPlanRecord, false);
                component.set("v.permanancyPlanRec", permanencyRec);
                if (permanencyRec.Guardianship_Planing__c == '6') {
                    component.set("v.isReadOnly", true);
                } else if (component.get("v.onClickCurrentStage") < permanencyRec.Guardianship_Planing__c) {
                    component.set("v.isReadOnly", true);
                }
                var existingNotApprovedSuspension =  utilityBase.checkNameSpace(JSON.parse(storeResponse).existingSuspensionRec, false);
                if (existingNotApprovedSuspension.length) {
                    component.set("v.suspensionRec", existingNotApprovedSuspension[0]);
                    if (initial) {
                        component.set("v.openSuspensionModal", true);
                    }
                }
                /* var exstingAllSuspensionRecs = component.get("v.suspensionList");
                for(var i=0; i<exstingAllSuspensionRecs.length; i++) {
                    if(String.isNotBlank(exstingAllSuspensionRecs[i].End_Date__c )) {
                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        if(exstingAllSuspensionRecs[i].End_Date__c > today) {
                            helper.showToast(component, event, helper, "error", 'cannot new add Suspension Record', "Error!");
                        }
                    }
                }*/
                
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
    
    getRowActions: function (component, row, doneCallback) {
        
        var actions = [{
            'label': 'Show Details',
            'iconName': 'utility:zoomin',
            'name': 'show_details'
        }];
        var deleteAction = {
            'label': 'Delete',
            'iconName': 'utility:delete',
            'name': 'delete'
        };
        
        if (row.Approval_Status__c == 'Approved') {
            deleteAction.disabled = 'true';
        } else {
            
        }
        
        actions.push(deleteAction);
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    
    showToast : function(component, event, helper, type, msg, title, time) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type":type,
            "duration":time
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
            var action = component.get("c.upsertSuspension");
            var suspensionIns = component.get("v.suspensionRec");
            suspensionIns.Permanency_Plan__c = component.get("v.recordId");
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
                        helper.showToast(component, event, helper, "success", toastMsg, "Success!", 5000);
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
                 helper.showToast(component, event, helper, "error", overlappedErrorMsg, "Error!", 7000);    
            }
        } else {
            helper.showToast(component, event, helper, "error", "Please complete the required field(s).", "Error!", 5000);    
        }
    },
    
    selectionRow: function (component, event, row, action, helper) {
        var actions = component.get('v.actions');
        if(row.Approval_Status__c != 'Approved') { 
            actions.push(
                { label: 'Show details', name: 'show_details' },
                { label: 'Delete', name: 'delete' });
            component.set("v.actions",actions);
        } else {
            actions.push(
                { label: 'Show details', name: 'show_details' });
            component.set("v.actions",actions);
        }
        switch (action.name) {
            case 'show_details':
                component.set("v.suspensionRec", row);
                component.set("v.openSuspensionModal",true); 
                //helper.showToast(component, event, helper, "error", "Show details button working progress.", "Error!");
                break;
            case 'delete':
                helper.deleteSuspension(component, event, row, helper);
                break;
        }
    },
    
    deleteSuspension : function (component, event, row, helper) {
        
        var action = component.get("c.deleteSuspensionRec");
        action.setParams({
            "suspensionJSONRec": JSON.stringify(row)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = component.get('v.suspensionList');
                var rowIndex = rows.indexOf(row);
                rows.splice(rowIndex, 1);
                helper.showToast(component, event, helper, "success", 'Suspension record deleted successfully.', "Success!", 5000);
                component.set('v.suspensionList',rows);
            }
            else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errMsg = errors[0].message;
                        helper.showToast(component, event, helper, "error", errMsg, "Error!", 7000);
                    }
                } else {
                    helper.showToast(component, event, helper, "error", 'Something went wrong to delete this supension record.', "Error!", 5000);
                }
                // handle error
                
            }
        });
        $A.enqueueAction(action);
    }
})