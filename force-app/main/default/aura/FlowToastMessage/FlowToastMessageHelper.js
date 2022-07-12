({
    showToast : function(type, message) {
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type ,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})