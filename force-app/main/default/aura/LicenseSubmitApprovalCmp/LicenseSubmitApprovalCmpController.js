({
	handleClick : function(component, event, helper) {
		component.set("v.isModalOpen", true);
        var flow = component.find("flowId");
        // In that component, start your flow. Reference the flow's Unique Name.
        var inputVariables = [
               {
                  name : "recordId",
                  type : "String",
                  value: component.get("v.recordId")
               }
            ];
        flow.startFlow("License_Site_Approver_Flow", inputVariables);
	},
    
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
      // Set isModalOpen attribute to true
      
    },
    
    handleStatusChange : function (component, event) {
    	if(event.getParam("status") === "FINISHED") {
        	component.set("v.isModalOpen", false);    
        }
    },    
})