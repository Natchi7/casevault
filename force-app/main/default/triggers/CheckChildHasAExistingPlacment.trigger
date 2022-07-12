trigger CheckChildHasAExistingPlacment on Child_Removal__c (before insert) {

    CheckChildHasExistingPlacementHanlder CCEPHIns = new CheckChildHasExistingPlacementHanlder();
    if(Trigger.isBefore && Trigger.isInsert) {
        CCEPHIns.beforeInsertTrigger(Trigger.new);      
    }
}