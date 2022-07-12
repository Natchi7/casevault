trigger contactTrigger on Contact (before insert, before update) {
    
    if(Trigger.isBefore) {
        
        if(Trigger.isInsert) {
            
            ContactTriggerHandler.onBeforeInsert(Trigger.New);
        }
        
        if(Trigger.isUpdate) {
             
            ContactTriggerHandler.onBeforeUpdate(Trigger.New);
        }
    }   
}