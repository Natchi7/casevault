@isTest
private class ChildRemovalController_Test {

    @isTest static void testgetInitialInfoAndUpdateChildRemoval() {
        
        Child_Removal__c childRemovalRec = new Child_Removal__c();
        childRemovalRec.Autism_Personal_Hygiene__c = 'Bathes Self';
        childRemovalRec.Autism_Special_Needs__c = 'Age is > 6';
        insert childRemovalRec;
        
        ChildRemovalController.getInitialWrapper childRemovalWrapperRec = (ChildRemovalController.getInitialWrapper)JSON.deserialize(ChildRemovalController.getInitialInfo(childRemovalRec.Id), ChildRemovalController.getInitialWrapper.class);
        System.assertEquals(childRemovalWrapperRec.childRemovalRecord, childRemovalRec);
        
        childRemovalRec.Removal_Type__c = 'Judicial Determination'; 
        ChildRemovalController.updateChildRemoval(JSON.serialize(childRemovalRec));  
        
        Child_Removal__c childRemovalTestRecord = [SELECT Id, Removal_Type__c FROM Child_Removal__c LIMIT 1];
        system.assertEquals(childRemovalTestRecord.Removal_Type__c == 'Judicial Determination', true);
        
        
    }
}