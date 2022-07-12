trigger placementTrigger on Placement__c (before delete) {
    
    for(Placement__c placementRec : Trigger.Old) {
        
        if(placementRec.Placement_Approval_Status__c == 'Approved') {
            
            placementRec.addError('Approved Placement record cannot be deleted');
        }
    }
}