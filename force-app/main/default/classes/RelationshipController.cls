public with sharing class RelationshipController {
    
    @AuraEnabled
    public static String getAllPersons(String recordId) {
        
        getInitialWrapper initWrap = new getInitialWrapper ();
        initWrap.relationshipPicklist = Utility.getPicklistinfo('Relationship__c','Relationship_Values__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Age__c,Gender__c,Is_Caregiver__c,Date_of_Birth__c, Casevault_PID__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        initWrap.contactList = [SELECT Id, Name, Age__c,Gender__c,Is_Caregiver__c,Date_of_Birth__c, Casevault_PID__c  FROM Contact WHERE Service_Case__c = :recordId OR Intake__c =:recordId OR Investigation__c =:recordId LIMIT :Utility.queryLimit];
        
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getRelationRecord(String personId) {
        
        if(String.isNotBlank(personId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Person__c, Person_Related_To__c, Relationship_Values__c, Is_Caregiver__c', 'view', 'Relationship__c',  Boolean.valueOf(Label.HasNamespace));
            List<Relationship__c> relationships = [SELECT Id,Person__c, Person_Related_To__c, Relationship_Values__c, Is_Caregiver__c FROM Relationship__c WHERE Person__c = :personId LIMIT :Utility.queryLimit];
        	return JSON.serialize(relationships);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String saveRelationship(String relationshipJSON) {
        
        if (String.isNotBlank(relationshipJSON)) {
            Relationship__c relationship = (Relationship__c)JSON.deserialize(relationshipJSON,Relationship__c.class);
                FieldLevelSecurity.checkFieldAccessByCriteria('Is_Caregiver__c', 'update', 'Contact',  Boolean.valueOf(Label.HasNamespace));
                Contact contactRecord = new Contact();
                contactRecord.Is_Caregiver__c = relationship.Is_Caregiver__c;
                contactRecord.Id = relationship.Person_Related_To__c;
                update contactRecord;
            if (String.isBlank(relationship.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Person__c, Person_Related_To__c, Relationship_Values__c, Is_Caregiver__c', 'create', 'Relationship__c',  Boolean.valueOf(Label.HasNamespace));
                insert relationship;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Person__c, Person_Related_To__c, Relationship_Values__c, Is_Caregiver__c', 'update', 'Relationship__c',  Boolean.valueOf(Label.HasNamespace));
                update relationship;
            }
          return relationship.Id;
       } else {
        return null;
       }
        
    }

    public class getInitialWrapper { 
    	
        @AuraEnabled
        public List<Utility.pickListWrap> relationshipPicklist;
        @AuraEnabled
        public List<Contact> contactList;
        
    }
}