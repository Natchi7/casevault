({
    invoke : function(component, event, helper) {
       
        var message = component.get("v.messageText");
        var type = component.get("v.type");
        helper.showToast(type, message);

    }
})