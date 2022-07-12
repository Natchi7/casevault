public with sharing class ContactMeetingController {
    
    @AuraEnabled
    public static String getMeetingInfo(String recordId){
        
        ContactMeetingWrapperClass wrap = new ContactMeetingWrapperClass();
        wrap.nameOfThePerson = Utility.getPicklistinfo('Meeting__c','Name_of_the_person_completing_the_report__c',false);
        wrap.meetingType = Utility.getPicklistinfo('Meeting__c','Type_of_the_Meeting__c',false);
        wrap.meetingStatus = Utility.getPicklistinfo('Meeting__c','Meeting_Status__c',false);
        wrap.typeOptions = Utility.getPicklistinfo('Meeting__c','Type__c',true);
        wrap.followupMeetingValues = Utility.getPicklistinfo('Meeting__c','Follow_up_Meeting__c',false);
        wrap.meetingDecisionValue = Utility.getPicklistinfo('Meeting__c','Meeting_Decision__c',false);
        wrap.participantTypeOptions = Utility.getPicklistinfo('Meeting_participants__c','Type__c', false);
        wrap.acceptanceAgreementOptions = Utility.getPicklistinfo('Meeting_participants__c','Acceptance_Agreement__c',false);
        
        if(String.isNotBlank(recordId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Service_Case__c, Investigation__c, Intake_Person_Role__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            
            List<Contact> childFamilyMembersContact = [SELECT Id,Name FROM Contact WHERE Service_Case__c = :recordId OR Investigation__c = :recordId LIMIT :Utility.queryLimit];
            wrap.childContact = [SELECT Id,Name FROM Contact 
                                 WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) AND Intake_Person_Role__c INCLUDES('Biological Child','Other Child (Not in Household)','Private Adoptive Child') LIMIT :Utility.queryLimit];
            List<Utility.pickListWrap> childFamilyMemberPicklist = new List<Utility.picklistWrap>();
            Utility.picklistWrap pick;
            for(Contact contactRec : childFamilyMembersContact) {
                if(String.isNotBlank(contactRec.Id)) {
                    pick = new Utility.picklistWrap();
                    pick.label = contactRec.Name;
                    pick.value = contactRec.Id;
                    childFamilyMemberPicklist.add(pick);
                }
            }
            
            wrap.childFamilyMembers = childFamilyMemberPicklist;
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Date_of_Meeting__c, Name_of_the_person_completing_the_report__c, Select_Child_Family_Member__c, Name_of_the_person__c, Type_of_the_Meeting__c, Meeting_Status__c, Type__c,'
                                                          +'Participants__c, Meeting_Notes__c, Additional_Comments__c, Follow_up_Meeting__c, Follow_up_meeting_Start_date__c, Service_Case__c, Investigation__c,'
                                                          +'Meeting_Decision__c', 'view', 'Meeting__c',  Boolean.valueOf(Label.HasNamespace));
            
            wrap.meetings = [SELECT Id,Date_of_Meeting__c, Name_of_the_person_completing_the_report__c, Select_Child_Family_Member__c, Name_of_the_person__c, Type_of_the_Meeting__c, Meeting_Status__c, Type__c,
                             Participants__c, Meeting_Notes__c, Additional_Comments__c, Follow_up_Meeting__c, Follow_up_meeting_Start_date__c, Meeting_Decision__c FROM Meeting__c 
                             WHERE Service_Case__c = :recordId OR Investigation__c = :recordId LIMIT :Utility.queryLimit];
            
            return JSON.serialize(wrap);
            
        }  else {
            return null;
        }
        
        
    }
    
    @AuraEnabled
    public static string getParticipantsInit(String contactId){
        
        ContactMeetingWrapperClass wrap = new ContactMeetingWrapperClass();
        
        if(String.isNotBlank(contactId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('FirstName, LastName', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            
            wrap.contactRec = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactId LIMIT :Utility.queryLimit];
            Meeting_participants__c meetingParticipantRec = new Meeting_participants__c();
            meetingParticipantRec.Type__c = 'Involved Persons';
            meetingParticipantRec.Participants__c = wrap.contactRec.Id;
            FieldLevelSecurity.checkFieldAccessByCriteria('Type__c, Participants__c', 'create', 'Meeting_participants__c',  Boolean.valueOf(Label.HasNamespace));
            
            insert meetingParticipantRec;
            FieldLevelSecurity.checkFieldAccessByCriteria('Type__c, Invited__c, Attended__c, Acceptance_Agreement__c, First_Name__c, Last_Name__c, Participants__c', 'view', 'Meeting_participants__c',  Boolean.valueOf(Label.HasNamespace));
            
            wrap.meetingParticipants = [SELECT Id,Type__c, Invited__c, Attended__c, Acceptance_Agreement__c, First_Name__c, Last_Name__c, Participants__c
                                        FROM Meeting_participants__c WHERE Id = :meetingParticipantRec.Id LIMIT :Utility.queryLimit];
            return JSON.serialize(wrap);
        } else {
            return null;
        }
    }  
    
    @AuraEnabled
    public static string getMeetingParticipantsInit(String meetingId){
        
        if(String.isNotBlank(meetingId)) {
            
            ContactMeetingWrapperClass wrap = new ContactMeetingWrapperClass();
            FieldLevelSecurity.checkFieldAccessByCriteria('Type__c, Invited__c, Attended__c, Acceptance_Agreement__c, First_Name__c, Last_Name__c, Participants__c, Electronic_Signature__c, Meeting__c', 'view', 'Meeting_participants__c',  Boolean.valueOf(Label.HasNamespace));
            
            wrap.meetingParticipantsList = [SELECT Id,Type__c, Invited__c, Attended__c, Acceptance_Agreement__c, First_Name__c, Last_Name__c,Meeting__c,Electronic_Signature__c,Participants__c
                                            FROM Meeting_participants__c WHERE Meeting__c = :meetingId LIMIT :Utility.queryLimit];
            return JSON.serialize(wrap);
        } else {
            return null;
        }
    } 
    
    @AuraEnabled
    public static String saveMeeting(String meetingJSON, String meetingParticipantsJSON, List<String> contentDocumentIds, String signatureJSON, List<String> deleteMeetingPartcipantsId){
        
        Meeting__c meetingRec = (Meeting__c)JSON.deserialize(meetingJSON,Meeting__c.class);
        if(String.isBlank(meetingRec.Id)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Date_of_Meeting__c, Name_of_the_person_completing_the_report__c, Select_Child_Family_Member__c, Name_of_the_person__c,'
                                                          +'Type_of_the_Meeting__c, Meeting_Status__c, Type__c, Participants__c, Meeting_Notes__c,'
                                                          +'Additional_Comments__c, Follow_up_Meeting__c, Follow_up_meeting_Start_date__c, Meeting_Decision__c','create', 'Meeting__c',  Boolean.valueOf(Label.HasNamespace));
            insert meetingRec;
        } else {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Date_of_Meeting__c, Name_of_the_person_completing_the_report__c, Select_Child_Family_Member__c, Name_of_the_person__c,'
                                                          +'Type_of_the_Meeting__c, Meeting_Status__c, Type__c, Participants__c, Meeting_Notes__c,'
                                                          +'Additional_Comments__c, Follow_up_Meeting__c, Follow_up_meeting_Start_date__c, Meeting_Decision__c','update', 'Meeting__c',  Boolean.valueOf(Label.HasNamespace));
            update meetingRec;
        }
        
        List<Meeting_participants__c> meetingParticipantsList = (List<Meeting_participants__c>)JSON.deserialize(meetingParticipantsJSON,List<Meeting_participants__c>.class);
        List<Meeting_participants__c> updateMeetingParticipants = new List<Meeting_participants__c>();
        for(Meeting_participants__c meetingParticipant : meetingParticipantsList) {
            if(meetingParticipant.Meeting__c == null) {
                meetingParticipant.Meeting__c = meetingRec.Id;
            }
            updateMeetingParticipants.add(meetingParticipant);
        }
        if(updateMeetingParticipants.size() > 0) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Invited__c, Attended__c, Acceptance_Agreement__c','update','Meeting_participants__c',Boolean.valueOf(Label.HasNamespace));
            update updateMeetingParticipants;
        } 
        if(contentDocumentIds.size() > 0) {
            String result = createContentLink(contentDocumentIds,meetingRec.Id);
        }
        if(String.isNotBlank(signatureJSON)) {
            List<SignatureClass> signatureList = (List<SignatureClass>)JSON.deserialize(signatureJSON,List<SignatureClass>.class);
            List<Meeting_participants__c> meetingParticipantsSignature = new List<Meeting_participants__c>();
            Meeting_participants__c meetingParticipantSignRec;
            for(SignatureClass wrapObj : signatureList) {
                meetingParticipantSignRec = new Meeting_participants__c();
                meetingParticipantSignRec.Id = wrapObj.Id;
                meetingParticipantSignRec.Electronic_Signature__c = wrapObj.electronicSignature;
                meetingParticipantsSignature.add(meetingParticipantSignRec);
            }
            if(meetingParticipantsSignature.size() > 0) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Electronic_Signature__c','update','Meeting_participants__c',Boolean.valueOf(Label.HasNamespace));
                update meetingParticipantsSignature;
            }
        }
        if(deleteMeetingPartcipantsId.size() > 0) {
            List<Meeting_participants__c> deleteMeetingParticipants = new List<Meeting_participants__c>();
            Meeting_participants__c meetingParticipantDeleteRec;
            for(String deleteId : deleteMeetingPartcipantsId) {
                meetingParticipantDeleteRec = new Meeting_participants__c();
                meetingParticipantDeleteRec.Id = deleteId;
                deleteMeetingParticipants.add(meetingParticipantDeleteRec);
            }
            if(deleteMeetingParticipants.size() > 0) {
                FieldLevelSecurity.checkObjectAccessByDelete('Meeting_participants__c');
                delete deleteMeetingParticipants;
            }
        }
        return meetingRec.Id;
    } 
    
    @AuraEnabled
    public static string deleteMeetingParticipant(String meetingParticipantId){
        
        if(String.isNotBlank(meetingParticipantId)) {
            
            FieldLevelSecurity.checkObjectAccessByDelete('Meeting_participants__c');
            Meeting_participants__c meetingParticipant = new Meeting_participants__c();
            meetingParticipant.Id = meetingParticipantId;
            delete meetingParticipant;
            return 'Success';
            
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
    public static String createContentLink(List<String> contentDocumentIds, String recordId) {
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        ContentDocumentLink cdl;
        for(String str : contentDocumentIds) {
            cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = str;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            contentDocumentLinks.add(cdl);
        }
        if(contentDocumentLinks.size() > 0) {
            insert contentDocumentLinks;
        }
        
        return 'Success';   
    }
    
    public class ContactMeetingWrapperClass {
        
        @AuraEnabled
        public List<Utility.pickListWrap> nameOfThePerson;
        @AuraEnabled
        public List<Utility.pickListWrap> childFamilyMembers;
        @AuraEnabled
        public List<Utility.pickListWrap> meetingType;
        @AuraEnabled
        public List<Utility.pickListWrap> meetingStatus;
        @AuraEnabled
        public List<Utility.picklistWrap> typeOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> participantsOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> followupMeetingValues;
        @AuraEnabled
        public List<Utility.pickListWrap> meetingDecisionValue;
        @AuraEnabled
        public List<Utility.pickListWrap> participantTypeOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> acceptanceAgreementOptions;
        @AuraEnabled
        public Contact contactRec;
        @AuraEnabled
        public  Meeting_participants__c meetingParticipants;
        @AuraEnabled
        public  List<Meeting_participants__c> meetingParticipantsList;
        @AuraEnabled
        public  List<Meeting__c> meetings;
        @AuraEnabled
        public  List<Contact> childContact;
        
    }
    
    public class SignatureClass {
        
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String electronicSignature;
    }
    
}