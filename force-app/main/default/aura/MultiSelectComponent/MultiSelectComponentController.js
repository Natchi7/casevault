({

    init: function(component, event, helper) {
        var values = helper.getSelectedValues(component);
        helper.setInfoText(component, values);
    },
    handleClick: function(component, event, helper) {
        var mainDiv = component.find('main-div');
        $A.util.addClass(mainDiv, 'slds-is-open');
    },
    handleSelection: function(component, event, helper) {
        var item = event.currentTarget;
        if (item && item.dataset) {

            var value = item.dataset.value;

            var selected = item.dataset.selected;

            var options = component.get("v.options_");

            if (event.ctrlKey) {
                options.forEach(function(element) {
                    if (element.value === value) {
                        element.selected = selected === "true" ? false : true;
                    }
                });

            } else {
                options.forEach(function(element) {
                    if (element.value === value) {
                        element.selected = selected === "true" ? false : true;
                    } 

                });
                var mainDiv = component.find('main-div');
                $A.util.removeClass(mainDiv, 'slds-is-open');
            }

            component.set("v.options_", options);
            var values = helper.getSelectedValues(component);
            var labels = helper.getSelectedLabels(component);
            helper.setInfoText(component, labels);
            component.set("v.selectedItems",values);
        }

    },

 

    handleMouseLeave: function(component, event, helper) {

        component.set("v.dropdownOver", false);

        var mainDiv = component.find('main-div');

        $A.util.removeClass(mainDiv, 'slds-is-open');

    },

 

    handleMouseEnter: function(component, event, helper) {

        component.set("v.dropdownOver", true);

    },

 

    handleMouseOutButton: function(component, event, helper) {

        window.setTimeout(

            $A.getCallback(function() {

                if (component.isValid()) {

                    //if dropdown over, user has hovered over the dropdown, so don't close.

                    if (component.get("v.dropdownOver")) {

                        return;

                    }

                    var mainDiv = component.find('main-div');

                    $A.util.removeClass(mainDiv, 'slds-is-open');

                }

            }), 200

        );

    }

})