trigger deletePermanencyPlan on Permanency_Plan__c (before delete) {

    if(trigger.isBefore && trigger.isDelete) {
    
        for(Permanency_Plan__c per : Trigger.old) {
        
            if(per.Permanency_Plan_Status__c == 'Approved') {
                per.addError('You cannot delete the Approved Permanency Plan'); 
            }
        }
    }
}