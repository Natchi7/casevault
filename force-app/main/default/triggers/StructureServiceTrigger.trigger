trigger StructureServiceTrigger on Structure_Services__c (Before insert, before delete) {

    if (Trigger.isInsert && Trigger.isBefore) {
    
        StructureServiceHandler.homeApprovedStructure(Trigger.new);
    }
    
    if (Trigger.isBefore && Trigger.isInsert) {
    
        StructureServiceHandler.updateStructureToParentProvider(Trigger.new);
    }
    
    if(trigger.isBefore && trigger.isDelete) {
        
        StructureServiceHandler.updateStructureToParentProvider(Trigger.old);
    }
}