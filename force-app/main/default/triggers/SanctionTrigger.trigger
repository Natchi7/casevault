trigger SanctionTrigger on Sanction__c (before insert) {

    if(Trigger.isInsert && Trigger.isBefore) {
    
        for(Sanction__c rec : Trigger.new) {
        
            rec.Completed_By__c = userinfo.getUserId();
        }
    
    }
}