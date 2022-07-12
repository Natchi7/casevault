({
    SearchHelper: function(component, event) {
        // show spinner message
        component.find("Id_spinner").set("v.class", 'slds-show');
        var getInputMap = component.get("v.getInputMap");
        getInputMap.childCharacter = '';
        if (getInputMap && getInputMap.childCharacterSet && getInputMap.childCharacterSet.length > 0) {
            getInputMap.childCharacter = '';
            for (var i = 0; i < getInputMap.childCharacterSet.length > 0; i++) {
                getInputMap.childCharacter += (getInputMap.childCharacterSet[i]);
                if ((getInputMap.childCharacterSet.length - 1) != i) {
                    getInputMap.childCharacter += ';';
                }
            }
        }


        var action = component.get("c.fetchAccount");
        action.setParams({
            'searchInputJSON': JSON.stringify(component.get("v.getInputMap"))
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class", 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }

                // set numberOfRecord attribute value with length of return value from server
                component.set("v.TotalNumberOfRecord", storeResponse.length);

                // set searchResult list with return value from server.
                component.set("v.searchResult", component.find("utils").checkNameSpace(JSON.parse(storeResponse), false));
				component.set("v.showChild",true);
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
    },

    //show toast error message
    showToast: function(component, event, helper, type, msg, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type": type
        });
        toastEvent.fire();
    },
    sortBy: function(field, reverse, primer) {
        var key = primer ?

            function(x) {
                return primer(x[field]);
            } :
            function(x) {
                return x[field];
            };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var cloneData = cmp.get("v.searchResult");
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));

        cmp.set('v.searchResult', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    },

    showMap: function(component, event) {
        component.set("v.isModalOpen", true);
        component.set('v.mapMarkers', [{
            location: {
                Latitude: '37.790197',
                Longitude: '-122.396879'
            },

            title: 'The White House',
            description: 'Landmark, historic home & office of the United States president, with tours for visitors.'
        }]);
        component.set('v.zoomLevel', 15);
    }
})