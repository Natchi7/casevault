({
	//show toast error message
    showToast : function(component, event, helper, type, msg, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type":type
        });
        toastEvent.fire();
	},  
    
    checkNamespaceApplicable : function(component, event, helper,  Obj) {
        
        var addNSMap = Obj;
        if("{!$Label.HasNamespace}" == "true") {
            var Namespace = $A.get("$Label.c.Org_NamePrefix");
            if (Obj && Object.keys(Obj).length) {
                
                Object.keys(Obj).forEach((element) => {
                    
                    if (Obj[element].endsWith('__c') && !(Obj[element].startsWith(Namespace))) {
                        addNSMap[element] = Namespace + Obj[element];
                    } else {
                    addNSMap[element] = Obj[element];                   
                    }
                });
                component.set("v.recordEditFormFields", addNSMap);
            } 
        } else {
            component.set("v.recordEditFormFields", Obj);
        }
    },
})