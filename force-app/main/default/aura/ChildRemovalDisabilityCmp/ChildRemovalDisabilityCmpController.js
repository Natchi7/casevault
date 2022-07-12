({
    doInit: function(component, event, helper) {

        helper.getInitInfo(component);

    },

    onChangeHandle: function(cmp, evt, helper) {
        var selectedOption = cmp.find('disabilities').get('v.value');
        cmp.set("v.selectedOption", selectedOption);
        cmp.set("v.isShowModal", true);

    },

    closeModel: function(cmp, evt, helper) {
        cmp.set("v.showAutismModal", false);
        cmp.set("v.showCognitiveModal", false);
        cmp.set("v.showEmotionallyModal", false);
        cmp.set("v.showHearingModal", false);
        cmp.set("v.showIntellectualModal", false);
        cmp.set("v.showPhysicalModal", false);
        cmp.set("v.showOtherModal", false);
        cmp.set("v.showVisualModal", false);

    },

    onChange: function(cmp, evt, helper) {
        var radioName = evt.getSource().get("v.name");
        var radioValue = evt.getParam("value");
        var childRemovalIns = cmp.get("v.childRemovalIns");
        if (radioName == "disabilities") {
            cmp.set("v.disabledRadioButtons", false);
            if (radioValue == 'No') {
                childRemovalIns.Autism_Spectrum_Disorder__c = 'No';
                childRemovalIns.Cognitive_Developmental_Delay__c = 'No';
                childRemovalIns.Emotionally_Disturbed__c = 'No';
                childRemovalIns.Hearing_Disability__c = 'No';
                childRemovalIns.Intellectual_Disability__c = 'No';
                childRemovalIns.Other_Disability__c = 'No';
                childRemovalIns.Physical_Disability__c = 'No';
                childRemovalIns.Visual_Disability__c = 'No';
            }
            cmp.set("v.childRemovalIns", childRemovalIns);
        } else if (radioName == 'input1') {

            if (radioValue == 'Yes') {
                cmp.set("v.showAutismModal", true);
            }
        } else if (radioName == 'input2') {

            if (radioValue == 'Yes') {
                cmp.set("v.showCognitiveModal", true);
            }
        } else if (radioName == 'input3') {

            if (radioValue == 'Yes') {
                cmp.set("v.showEmotionallyModal", true);
            }
        } else if (radioName == 'input4') {

            if (radioValue == 'Yes') {
                cmp.set("v.showHearingModal", true);
            }
        } else if (radioName == 'input5') {

            if (radioValue == 'Yes') {
                cmp.set("v.showIntellectualModal", true);
            }
        } else if (radioName == 'input6') {

            if (radioValue == 'Yes') {
                cmp.set("v.showOtherModal", true);
            }
        } else if (radioName == 'input7') {

            if (radioValue == 'Yes') {
                cmp.set("v.showPhysicalModal", true);
            }
        } else if (radioName == 'input8') {

            if (radioValue == 'Yes') {
                cmp.set("v.showVisualModal", true);
            }
        }
    },

    onSave: function(component, event, helper) {
        var childRemovalIns = component.get('v.childRemovalIns');
        var requiredInputField = component.find("requriedFields");
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
            if (childRemovalIns.Does_the_person_have_disabilities__c == 'Yes' && childRemovalIns.Autism_Spectrum_Disorder__c == 'No' && childRemovalIns.Cognitive_Developmental_Delay__c == 'No' &&
                childRemovalIns.Emotionally_Disturbed__c == 'No' && childRemovalIns.Hearing_Disability__c == 'No' &&
                childRemovalIns.Intellectual_Disability__c == 'No' && childRemovalIns.Other_Disability__c == 'No' && childRemovalIns.Physical_Disability__c == 'No' &&
                childRemovalIns.Visual_Disability__c == 'No') {
                helper.showToast(component, event, helper, "error", "Please Complete The Any One This Question", "Error!", 5000);

            } else {

                var action = component.get("c.updateChildRemoval");
                var returnVal = component.find("utils").checkNameSpace(component.get('v.childRemovalIns'), true);
                action.setParams({
                    "updatingChildRemovalIns": JSON.stringify(returnVal)
                });
                action.setCallback(this, function(result) {
                    var state = result.getState();
                    if (state === "SUCCESS") {
                        var resultData = result.getReturnValue();
                        component.set("v.activeSections", "[]");
                        //component.set('v.childRemovalIns', resultData);
                        helper.showToast(component, event, helper, "success", "Child removal record updated successfully!", "Success!", 5000);
                        $A.get('e.force:refreshView').fire();
                    } else if (state === "INCOMPLETE") {
                        helper.showToast(component, event, helper, "error", 'Response is Incompleted', "Error!", 13000);
                        //alert('Response is Incompleted');
                    } else if (state === "ERROR") {
                        var errors = result.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.showToast(component, event, helper, "error", errors[0].message, "Error!", 13000);
                            }
                        } else {
                            helper.showToast(component, event, helper, "error", "Unknown error", "Error!", 13000);
                            //alert("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        } else {
            helper.showToast(component, event, helper, "error", "Complete the requried field(s)", "Error!", 5000);
        }

    },
})