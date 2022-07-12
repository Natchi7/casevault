public  with sharing class ContactNotesController {
    @AuraEnabled
    public static String getNotesInitialInformation(String recordId){
        NotesWrapper notesWrap = new NotesWrapper();
        notesWrap.contactPurposePicklist = Utility.getPicklistinfo('Notes__c','Contact_Purpose__c',false);
        notesWrap.contactTypePicklist = Utility.getPicklistinfo('Notes__c','Contact_Type__c',false);
        notesWrap.contactLoactionPicklist = Utility.getPicklistinfo('Notes__c','Contact_Location__c',false);
        notesWrap.contactAttemptedPicklist = Utility.getPicklistinfo('Notes__c','Contact_was_Attempted_Completed__c',false);
        notesWrap.contactInitiatedPicklist = Utility.getPicklistinfo('Notes__c','Contact_was_initiated_received__c',false);
        if(String.isNotBlank(recordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            List<Contact> personList = [SELECT Id, Name,Intake_Person_Role__c FROM Contact 
                                        WHERE Service_Case__c = :recordId OR Investigation__c =:recordId OR Intake__c =:recordId LIMIT :Utility.queryLimit];
            List<Utility.pickListWrap> personsRecPickList = new List<Utility.pickListWrap>();
            Utility.pickListWrap intialPick = new Utility.pickListWrap();
            intialPick.label = '--None--';
            intialPick.value = '';
            personsRecPickList.add(intialPick);
            Utility.pickListWrap pick;
            for(Contact con : personList) {
                
                if (String.isNotBlank(con.Id)) {
                    pick = new Utility.pickListWrap();
                    pick.label = con.Name;
                    pick.value = con.Name;
                    personsRecPickList.add(pick);
                }
            }  
            notesWrap.involvedPersonPicklist = personsRecPickList;
            notesWrap.contactList = personList;
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'User',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Contact_Purpose__c, Contact_Date__c, Contact_Location__c, Contact_Type__c,'+
            ' Start_Time__c, Contact_Duration__c, End_Time__c, Involved_Persons__c, Contact_was_Attempted_Completed__c, Notes__c, Travel_Duration__c, Contact_was_initiated_received__c', 'view', 'Notes__c',  Boolean.valueOf(Label.HasNamespace));
            notesWrap.notesList = [SELECT Id, Contact_Purpose__c, Contact_Date__c, Contact_Location__c, Contact_Type__c,
                                   Start_Time__c, Contact_Duration__c, End_Time__c, Involved_Persons__c, CreatedDate, Owner.Name,  
                                   Contact_was_Attempted_Completed__c, Notes__c, Travel_Duration__c, Contact_was_initiated_received__c
                                   FROM Notes__C 
                                   WHERE Service_Case__c = :recordId OR Investigation__c =:recordId OR Intake__c =:recordId LIMIT :Utility.queryLimit
                                  ];
        }
        return JSON.serialize(notesWrap);
    }
    
    @AuraEnabled
    public static String createNotesRecord(String notesJOSN, List<String> contentDocumentIds) {
        if(String.isNotBlank(notesJOSN)) {
            Notes__c notesRec = (Notes__c)JSON.deserialize(notesJOSN, Notes__c.class);
            if (String.isBlank(notesRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Contact_Purpose__c, Contact_Date__c, Contact_Location__c, Contact_Type__c,'+
                'Start_Time__c, Contact_Duration__c, End_Time__c, Involved_Persons__c, Contact_was_Attempted_Completed__c, Notes__c, Travel_Duration__c, Contact_was_initiated_received__c', 'create', 'Notes__c',  Boolean.valueOf(Label.HasNamespace));
                insert notesRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Contact_Purpose__c, Contact_Date__c, Contact_Location__c, Contact_Type__c,'+
                'Start_Time__c, Contact_Duration__c, End_Time__c, Involved_Persons__c, Contact_was_Attempted_Completed__c, Notes__c, Travel_Duration__c, Contact_was_initiated_received__c', 'update', 'Notes__c',  Boolean.valueOf(Label.HasNamespace));
                update notesRec;
            }
            if(contentDocumentIds.size() > 0) {
                String result = ContactMeetingController.createContentLink(contentDocumentIds,notesRec.Id);
            }
            return notesRec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String createQualityCareRecord(String qualityJOSN) {
        if(String.isNotBlank(qualityJOSN)) {
            Quality_Of_Care__c qualityCareRec = (Quality_Of_Care__c)JSON.deserialize(qualityJOSN, Quality_Of_Care__c.class);
            if (String.isBlank(qualityCareRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Describe_the_quality_of_care__c, Describe_a_the_child_s_adjustment__c,Describe_child_s_adjustment_to_foster__c', 'create', 'Quality_Of_Care__c',  Boolean.valueOf(Label.HasNamespace));
                insert qualityCareRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Describe_the_quality_of_care__c, Describe_a_the_child_s_adjustment__c,Describe_child_s_adjustment_to_foster__c', 'update', 'Quality_Of_Care__c',  Boolean.valueOf(Label.HasNamespace));
                update qualityCareRec;
            }
            return qualityCareRec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String deleteNotesRecord(String notesJOSN) {
        if(String.isNotBlank(notesJOSN)) {
            Notes__c notesRec = (Notes__c)JSON.deserialize(notesJOSN, Notes__c.class);
            if (String.isNotBlank(notesRec.Id)) {
                FieldLevelSecurity.checkObjectAccessByDelete('Notes__c');            
                delete notesRec;
            } 
            return notesRec.Id;  
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        FieldLevelSecurity.checkFieldAccessByCriteria('VersionData,Title,PathOnClient','create','ContentVersion', Boolean.valueOf(Label.HasNamespace));
        insert cv;
        ContentVersion contentVersionRec = [SELECT ContentDocumentId FROM ContentVersion 
                                            WHERE Id = :cv.Id LIMIT :Utility.queryLimit];
        return contentVersionRec.ContentDocumentId;
    }
    
    @AuraEnabled
    public static String getNotesHistories(String notesRecId) {
        NotesWrapper notesWrap = new NotesWrapper ();
        if(String.isNotBlank(notesRecId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Contact_Purpose__c, Contact_Type__c, Contact_Location__c,'+
            'Travel_Duration__c, Contact_was_Attempted_Completed__c, Person_Contact__c,Modified_Name__c, Notes_Comments__c, Notes__c, Modified_Date__c,Source__c', 'view', 'Notes_History__c',  Boolean.valueOf(Label.HasNamespace));
            notesWrap.notesHistoryList = [SELECT Id, Name, Contact_Purpose__c, Contact_Type__c, Contact_Location__c, 
                                          Travel_Duration__c, Contact_was_Attempted_Completed__c, Person_Contact__c, 
                                          Modified_Name__c, Notes_Comments__c, Notes__c, Modified_Date__c, Owner.Name, 
                                          Source__c FROM Notes_History__c WHERE Notes__c =:notesRecId LIMIT :Utility.queryLimit];
            return JSON.serialize(notesWrap);
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String getQualityOfCareRecord(String notesRecId) {
        NotesWrapper notesWrap = new NotesWrapper ();
        if(String.isNotBlank(notesRecId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Describe_the_quality_of_care__c, Describe_a_the_child_s_adjustment__c,Describe_child_s_adjustment_to_foster__c', 'view', 'Quality_Of_Care__c',  Boolean.valueOf(Label.HasNamespace));
            List<Quality_Of_Care__c> qualityOfCareRecord = [SELECT Id, Describe_the_quality_of_care__c, Describe_a_the_child_s_adjustment__c,
                                                      Describe_child_s_adjustment_to_foster__c
                                                      FROM Quality_Of_Care__c WHERE Notes__c =:notesRecId LIMIT :Utility.queryLimit];
            if (qualityOfCareRecord.size() >0) {
                notesWrap.qualityOfCareRec = qualityOfCareRecord[0];
                
            }
            return JSON.serialize(notesWrap);
        } else {
            return null;
        }
        
    }
    
    
    public class NotesWrapper{
        @AuraEnabled
        public List<Utility.pickListWrap> contactPurposePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactTypePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactLoactionPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> involvedPersonPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactInitiatedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactAttemptedPicklist;
        @AuraEnabled
        public List<Notes__c> notesList;
        @AuraEnabled
        public Notes__c notesRecord;
        @AuraEnabled
        public List<Notes_History__c> notesHistoryList;
        @AuraEnabled
        public Quality_Of_Care__c qualityOfCareRec;
        @AuraEnabled
        public List<Contact> contactList;
        
        public  NotesWrapper() {
            qualityOfCareRec = new Quality_Of_Care__c();
        }
    }
}