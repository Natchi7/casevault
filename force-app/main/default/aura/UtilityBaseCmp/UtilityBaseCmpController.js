({
    checkNamespaceIsApplicable: function(component, event, helper) {

        var hasNamespace = $A.get("$Label.c.HasNamespace");
        var params = event.getParam("arguments");
        var obj, addNS;

        if (params) {

            obj = params.objParam;
            addNS = params.addNSParam;
        }
        if (hasNamespace.toLowerCase() == 'true') {

            return helper.checkNamespaceApplicable(component, event, helper, obj, addNS);

        }
        return obj;

    }
})