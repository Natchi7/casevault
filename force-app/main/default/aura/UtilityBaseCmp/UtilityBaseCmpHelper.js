({
    checkNamespaceApplicable: function(component, event, helper, obj, addNS) {

        var Namespace = $A.get("$Label.c.Org_NamePrefix");
        var addNSMap = {};
        let objects = {};
        if (Array.isArray(obj)) {
            
            obj.forEach((element) => {
              Object.assign(objects, element);
            });
           
            
        } else {
            objects = obj ;
        }
        if (objects && Object.keys(objects).length) {
            if (addNS) {

                Object.keys(objects).forEach((element) => {

                    if ((element.endsWith('__c') || element.endsWith('__r')) && !(element.startsWith(Namespace))) {
                        addNSMap[element] = Namespace + element;
                    }
                });
                return this.renameKeys(component, event, helper, obj, addNSMap, addNS);
            } else {

                Object.keys(objects).forEach((element) => {

                    if ((element.endsWith('__c') || element.endsWith('__r')) && element.startsWith(Namespace)) {

                        addNSMap[element] = element.substring(Namespace.length);
                    }
                });
                return helper.renameKeys(component, event, helper, obj, addNSMap, addNS);
            }
        } else {
            return obj;
        }
    },
    renameKeys: function(component, event, helper, obj, newKeys, addNS) {

        if (Array.isArray(obj)) {

            var objAssignList = [];

            obj.forEach((element) => {

                var newkeyValues = Object.keys(element).map(key => {
                    var newKey2 = newKeys[key] || key;
                    if (typeof element[key] == 'object') {
                        return {
                            [newKey2]: helper.checkNamespaceApplicable(component, event, helper, element[key], addNS)
                        };
                    } else {

                        return {
                            [newKey2]: element[key]
                        };
                    }

                });

                objAssignList.push(Object.assign({}, ...newkeyValues));
            });
            component.set('v.returnList', objAssignList);
            return objAssignList;

        } else {
            var keyValues = Object.keys(obj).map(key => {
                var newKey = newKeys[key] || key;
                if (typeof obj[key] == 'object') {

                    return {
                        [newKey]: helper.checkNamespaceApplicable(component, event, helper, obj[key], addNS)
                    };
                } else {
                    return {
                        [newKey]: obj[key]
                    };
                }

            });
            return Object.assign({}, ...keyValues);
        }
    }
})