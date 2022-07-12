({
	getAcknowldgeLetter : function(component, event, helper) {
        
       var recordId = component.get("v.recordId");
       var url = '/apex/IntakeAcknowldgementLetter?id='+recordId;
	   window.open(url, '_blank');
		
	}
})