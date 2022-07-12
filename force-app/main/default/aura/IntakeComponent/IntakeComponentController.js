({  
    doInit: function(component, event, helper) {        
       
        var today = new Date();
        component.set("v.todayDateTime",today);
        var action = component.get("c.getInitialInformation");
        action.setParams({"intakeId": component.get('v.recordId')
                         });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var returnResponse = JSON.parse(storeResponse);
                let communicationPicklist = returnResponse.communicationPicklist;
                let originpicklist = returnResponse.originPicklist;
                let jurisdictionPicklist = returnResponse.jurisdictionPicklist
                let voluntaryPicklist = returnResponse.voluntaryPicklist
                communicationPicklist.splice(0, 1);
                originpicklist.splice(0, 1);
                jurisdictionPicklist.splice(0, 1);
                voluntaryPicklist.splice(0, 1);
                component.set("v.communicationOptions", communicationPicklist);
                component.set("v.originOptions", originpicklist);
                component.set("v.jurisdictionOptions", jurisdictionPicklist);
                component.set("v.voluntaryPlacementTypeOptions", voluntaryPicklist);
                component.set("v.orgNamespacePrefix", returnResponse.orgNamespacePrefix);
                var returnVal = component.find("utils").checkNameSpace(returnResponse.caseRecIns,false);
                component.set("v.createddate", moment(returnVal.CreatedDate).format('MM/DD/YYYY hh:mm A'));
                component.set('v.intakeRecordIns', returnVal);
                var purpose = component.get('v.intakeRecordIns.Origin');
                if(purpose == 'Request for services') {
                    component.set("v.isHomeService", true);
                    component.set("v.isInformation", false);
                } else if(purpose == 'Information and Referral') {
                    component.set("v.isHomeService", false);
                    component.set("v.isInformation", true);
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
                    /*alert("Unknown error");*/
                }
            }
        });
        $A.enqueueAction(action);        
    },    
    
  /*getInitialInfos: function(component, event, helper) {
        
        var action = component.get("c.getIntakeRecord");
        action.setParams({"intakeId": component.get('v.recordId')
                         });        
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                var returnVal = component.find("utils").checkNameSpace(resultData,false);
                component.set("v.createddate",moment(returnVal.Created_Date__c).format('DD-MM-YYYY hh:mm a'))
                //resultData.Created_Date__c=moment(resultData.Created_Date__c).format('DD-MM-YYYY hh:mm a');
                component.set('v.intakeRecordIns', returnVal);
                var purpose = component.get('v.intakeRecordIns.Origin');
                if(purpose == 'Request for services') {
                    component.set("v.isHomeService", true);
                    component.set("v.isInformation", false);
                } else if(purpose == 'Information and Referral') {
                    component.set("v.isHomeService", false);
                    component.set("v.isInformation", true);
                }
            }
            else{
                alert("error");
            }
        });        
        
        $A.enqueueAction(action); 
    },*/
    
    onSave : function(component, event, helper) {
        
        if(component.get('v.isHomeService') == true) {
            
            var inputname = event.getSource().get('v.name')
            
            if(inputname === 'homeService') {
                component.set("v.intakeRecordIns.Private_Adoption_Subsidy__c", false);
                component.set("v.intakeRecordIns.ICPC__c", false);
                component.set("v.intakeRecordIns.CPS_History_Clearance__c", false);
                component.set("v.intakeRecordIns.ASCRS_Adpotion_Search_Contact__c", false);
                component.set("v.intakeRecordIns.ICAMA__c", false);
            } else if(inputname === 'privateAdoption') {
                component.set("v.intakeRecordIns.In_Home_Services__c", false);
                component.set("v.intakeRecordIns.ICPC__c", false);
                component.set("v.intakeRecordIns.CPS_History_Clearance__c", false);
                component.set("v.intakeRecordIns.ASCRS_Adpotion_Search_Contact__c", false);
                component.set("v.intakeRecordIns.ICAMA__c", false);
            } else if(inputname === 'icpc') {
                component.set("v.intakeRecordIns.In_Home_Services__c", false);
                component.set("v.intakeRecordIns.Private_Adoption_Subsidy__c", false);
                component.set("v.intakeRecordIns.CPS_History_Clearance__c", false);
                component.set("v.intakeRecordIns.ASCRS_Adpotion_Search_Contact__c", false);
                component.set("v.intakeRecordIns.ICAMA__c", false);
            } else if(inputname === 'cpsHistory') {
                component.set("v.intakeRecordIns.In_Home_Services__c", false);
                component.set("v.intakeRecordIns.Private_Adoption_Subsidy__c", false);
                component.set("v.intakeRecordIns.ICPC__c", false);
                component.set("v.intakeRecordIns.ASCRS_Adpotion_Search_Contact__c", false);
                component.set("v.intakeRecordIns.ICAMA__c", false);
            } else if(inputname === 'ascrsAdoption') {
                component.set("v.intakeRecordIns.In_Home_Services__c", false);
                component.set("v.intakeRecordIns.Private_Adoption_Subsidy__c", false);
                component.set("v.intakeRecordIns.CPS_History_Clearance__c", false);
                component.set("v.intakeRecordIns.ICPC__c", false);
                component.set("v.intakeRecordIns.ICAMA__c", false);
            } else if(inputname === 'icama') {
                component.set("v.intakeRecordIns.In_Home_Services__c", false);
                component.set("v.intakeRecordIns.Private_Adoption_Subsidy__c", false);
                component.set("v.intakeRecordIns.CPS_History_Clearance__c", false);
                component.set("v.intakeRecordIns.ASCRS_Adpotion_Search_Contact__c", false);
                component.set("v.intakeRecordIns.ICPC__c", false);
            }   
        }
        helper.saveMethod(component, event, helper);
    },
    
    onCommunicationChange: function(component, event, helper) {
        //var selectedCommunication = component.find("InputCaseCommunication");
        helper.saveMethod(component, event, helper);
        //alert(selectedCommunication.get("v.value"));
    },
    
    onPurposeChange: function(component, event, helper) {
        var selectedPurpose = event.getSource();       
        
        if(selectedPurpose.get("v.value") == 'Information and Referral') {
            component.set("v.isInformation", true);  
            component.set("v.isHomeService", false);
            component.set("v.intakeRecordIns.In_Home_Services__c", false);
        } else if (selectedPurpose.get("v.value") == 'Request for services') {
            component.set("v.isHomeService", true);
            component.set("v.isInformation", false);
        }
        helper.saveMethod(component, event, helper);
        //alert(selectedPurpose.get("v.value"));
    },
    
    onJurisdictionChange: function(component, event, helper) {
        var selectedJurisdiction = event.getSource();
        helper.saveMethod(component, event, helper);
        //alert(selectedJurisdiction.get("v.value"));
    },
    
    onPlacementType: function(component, event, helper) {
        var selectedVoluntaryType = event.getSource();
        //alert(selectedVoluntaryType.get("v.value"));
        helper.saveMethod(component, event, helper);
    },
    
    
})