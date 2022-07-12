({
    getInitialInfos: function(component, event, helper) {

       
        if(component.get("v.recordId") !=null) {
            component.set("v.showEditView", "true");
            var columns = [
                { label: 'PROVIDER ID', fieldName: 'Casevault_ProID__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
                { label: 'PROVIDER NAME', fieldName: 'Name', type: 'text', sortable: true },
                { label: 'VACANCY', fieldName: 'Number_of_Beds__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
                { label: 'PLACEMENT STRUCTURE', fieldName: 'Placement_Service__c', type: 'text', sortable: true },
                { label: 'PROVIDER CATEGORY', fieldName: 'Type__c', type: 'text', sortable: true },
                { label: 'ACTION', type: 'button', initialWidth: 135, typeAttributes: { label: 'View Map', name: 'view_Map', title: 'Click to View Map' } }
            ];
            component.set("v.columns", columns);
            var action = component.get("c.getInitialInformation");

            action.setParams({
                'placementRecordId': component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    component.set("v.pickListValueMap", component.find("utils").checkNameSpace(JSON.parse(storeResponse), false));
                    component.set("v.placementRec", component.find("utils").checkNameSpace(JSON.parse(storeResponse).placementRecord, false));
                    
                } else if (state === "INCOMPLETE") {
                    helper.showToast(component, event, helper, "error", "Response is Incomplete.", "Error!");
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
            var pageReference = component.get("v.pageReference");
            var servicecaseRecordId = pageReference.state.c__servicecase; 
            var action = component.get("c.getChildRemovalRecords");

            action.setParams({
                'servicecaseId': servicecaseRecordId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    component.set("v.childOptions",JSON.parse(storeResponse).childPicklist);
                    component.set("v.placementRecordList",JSON.parse(storeResponse).placementRecordList);
                   
                } else if (state === "INCOMPLETE") {
                    helper.showToast(component, event, helper, "error", "Response is Incomplete.", "Error!");
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
            component.set("v.showCreateView", "true");
        }
    },

    Search: function(component, event, helper) {

        component.set("v.showAddedProviderDetail", "false");
        component.set("v.selectedProviderRec", null);
        helper.SearchHelper(component, event);
    },

    viewMapClick: function(component, event, helper) {

        helper.showMap(component, event);
    },

    closeModel: function(component, event, helper) {

        component.set("v.isModalOpen", false);
        component.set("v.showHistoryModal", false);
    },

    openProviderModal: function(component, event, helper) {

        component.set("v.showAddedProviderDetail", "true");
        component.set("v.searchResult", []);
    },


    upsertPlacement: function(component, event, helper) {
        var requiredInputField = component.find("requiredFields");
        var isValid = true;
        if (Array.isArray(requiredInputField)) {
            for (var i = 0; i < requiredInputField.length; i++) {
                if (!requiredInputField[i].get("v.value")) {
                    $A.util.addClass(requiredInputField[i], 'slds-has-error');
                    isValid = false;
                } else {
                    $A.util.removeClass(requiredInputField[i], 'slds-has-error');
                }
            }
        } else {
            if (!requiredInputField.get("v.value")) {

                $A.util.addClass(requiredInputField, 'slds-has-error');
                isValid = false;
            } else {

                $A.util.removeClass(requiredInputField, 'slds-has-error');
            }
        }

        if (isValid) {

            var isChildProviderAdded = true;
            let placementRecIns = component.get("v.placementRec");
            if (component.get("v.selectedProviderRec") && component.get("v.searchResult").length == 0) {
                if (component.get("v.selectedProviderRec").Number_of_Beds__c > 0) {
                    placementRecIns.Provider__c = component.get("v.selectedProviderRec").Id;
                } else {
                    helper.showToast(component, event, helper, "error", "No vacancy for this provider, please select another provider.", "Error!");
                    isChildProviderAdded = false;
                }
            } else {
                helper.showToast(component, event, helper, "error", "Please add the Provider.", "Error!");
                isChildProviderAdded = false;
            }
            component.set("v.placementRec", placementRecIns)

            if (isChildProviderAdded) {
                var action = component.get("c.upsertPlacementRec");
                action.setParams({
                    'placementDataJSON': JSON.stringify(component.find("utils").checkNameSpace(component.get("v.placementRec"), true)),
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();
                        if (response.getReturnValue()) {
                            helper.showToast(component, event, helper, "success", "Placement record updated successfully!", "Success!");
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
                            
                        } else {
                            helper.showToast(component, event, helper, "error", "Placement Begin Date shouldn't be less than child removal date.", "Error!");
                        }

                    } else if (state === "INCOMPLETE") {

                        helper.showToast(component, event, helper, "error", "Response is Incomplete.", "Error!");
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
            }
        } else {
            helper.showToast(component, event, helper, "error", "Please complete the required field(s).", "Error!");
        }
    },

    selectedProvider: function(component, event, helper) {

        component.set("v.selectedProviderRec", event.getSource().get('v.value'));
    },

    selectedChild: function(component, event, helper) {

        component.set("v.selectedChildRec", event.getSource().get('v.value'));
    },

    onHistory: function(component, event, helper) {
        component.set("v.showHistoryModal", true);
        var action = component.get("c.getCurrentCaseRecord");
        action.setParams({
            'placementRecordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.histroyList", component.find("utils").checkNameSpace(response.getReturnValue(), false));
                var placement = response.getReturnValue();
                var action = component.get("c.getCurrentPlacementApprovalDetails");
                action.setParams({
                    'placementRecordId': component.get("v.recordId")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var approvalList = component.find("utils").checkNameSpace(response.getReturnValue(), false);
                        component.set("v.approvalList", approvalList);
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action);
    },

    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    },

    handleRowAction: function(cmp, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'view_Map':
                helper.showMap(cmp, event);
                break;
        }
    },

    handleRowSelection: function(cmp, event, helper) {

        cmp.set("v.selectedProviderRec", event.getParam('selectedRows')[0]);
    },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();       
        var fields = event.getParam('fields');
        let foundelement = component.get("v.placementRecordList").find(ele => ele.Child__c ==  component.get("v.childId"));
                                if (foundelement) {
                                    fields.Child_Removal__c = foundelement.Child_Removal__c;                                
                                    fields.Service_Case__c = foundelement.Service_Case__c;
                                    fields.Child__c = foundelement.Child__c;
                                    fields.Updated_Record__c  = 'Yes';
                                }

        component.find('recordEditForm').submit(fields);
    },

    handleSuccess : function(component, event, helper) {
        helper.showToast(component, event, helper, "success", "Placement Created Successfully", "Success!");
    },
    paginationHandler:  function(component, event, helper) {
    	 var visibleDataPagination = event.getParam('records'); 
    	component.set("v.visibleData",visibleDataPagination);
	}
})