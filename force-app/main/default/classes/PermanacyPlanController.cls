public with sharing class PermanacyPlanController {
    
    @AuraEnabled
    public static String getInitialInformation(String serviceCaseRecordId, String permanencyPlanRecordId) {  
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.primaryPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Primary_Permanency_Plan__c',false);
        initWrap.concurrentPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Concurrent_Permanency_Plan__c',false);
        initWrap.returnPicklist = Utility.getPicklistinfo('Permanency_Plan__c','If_the_Permanency_plan_is_to_return_home__c',false);
        initWrap.guardianshipPlaningPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Guardianship_Planing__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c,Child__c, Exit_Approval_Status__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Intake_Person_Role__c,Age__c,Date_of_Birth__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        
        initWrap.approvedPlacementChildList = [SELECT Service_Case__c, Id, Child__c, Child__r.Name, Child__r.Intake_Person_Role__c, Child__r.Age__c, Child__r.Date_of_Birth__c, Exit_Approval_Status__c FROM Placement__c 
                                     WHERE Child__c != Null AND Placement_Approval_Status__c = 'Approved'
                                     AND Service_Case__c = :serviceCaseRecordId AND 
                                     Exit_Approval_Status__c != 'Approved' AND End_Date__c = null ORDER BY lastModifiedDate  DESC LIMIT :Utility.queryLimit];
        
        if(String.isNotBlank(permanencyPlanRecordId)){
        FieldLevelSecurity.checkFieldAccessByCriteria('Primary_Permanency_Plan__c, Plan_Established_Date__c, Plan_Comments__c, Concurrent_Permanency_Plan__c, Concurrent_Plan_Established_Date__c, Concurrent_Comments__c, End_Date__c, End_Reason__c, Court_order_received_and_upload_in_CJAMS__c, If_the_Permanency_plan_is_to_return_home__c, Explanation_Required__c,Discuss_how_the_caregiver_is_meeting__c, Discuss_and_explain_changes_in_the_child__c, Describe_how_the_worker_is_carrying_out__c, Document_what_steps_have_been_taken__c,Describe_how_the_worker_is_ensuring__c,What_efforts_were_made_to_promote__c,Has_a_Lifebook_been_prepared__c,Describe_the_parent_s_compliance__c,Does_the_Provider_agree_permanency__c,Permanancy_Agree_Explanation_Required__c,Discuss_services_being_provided__c,Contact__c', 'view', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
        initWrap.permanencyInst = [SELECT Id, Primary_Permanency_Plan__c, Plan_Established_Date__c, Plan_Comments__c, Concurrent_Permanency_Plan__c,
                                   Concurrent_Plan_Established_Date__c, Concurrent_Comments__c, End_Date__c, End_Reason__c, 
                                   Court_order_received_and_upload_in_CJAMS__c, If_the_Permanency_plan_is_to_return_home__c,
                                   Explanation_Required__c,Discuss_how_the_caregiver_is_meeting__c, Discuss_and_explain_changes_in_the_child__c,
                                   Describe_how_the_worker_is_carrying_out__c, Document_what_steps_have_been_taken__c, Describe_how_the_worker_is_ensuring__c,
                                   What_efforts_were_made_to_promote__c, Has_a_Lifebook_been_prepared__c, Describe_the_parent_s_compliance__c, 
                                   Does_the_Provider_agree_permanency__c, Permanancy_Agree_Explanation_Required__c, Discuss_services_being_provided__c, 
                                   Contact__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanRecordId LIMIT :Utility.queryLimit];
        }                          
       return JSON.serialize(initWrap);
    }
   
    @AuraEnabled
    public static String createPermanancyPlan(String permanancyDataJSON) {
    
       if (String.isNotBlank(permanancyDataJSON)) {
           Permanency_Plan__c createPermanacyRec = (Permanency_Plan__c) JSON.deserialize(permanancyDataJSON, Permanency_Plan__c.class);
           if (String.isBlank(createPermanacyRec.Id)) {
               
               FieldLevelSecurity.checkFieldAccessByCriteria('Name,Primary_Permanency_Plan__c,Plan_Established_Date__c,Plan_Comments__c,Concurrent_Permanency_Plan__c,Concurrent_Plan_Established_Date__c,'+
                                                      'Concurrent_Comments__c,End_Date__c,End_Reason__c,Court_order_received_and_upload_in_CJAMS__c,If_the_Permanency_plan_is_to_return_home__c,Explanation_Required__c,'+
                                                      'Discuss_how_the_caregiver_is_meeting__c,Discuss_and_explain_changes_in_the_child__c,Describe_how_the_worker_is_carrying_out__c,Document_what_steps_have_been_taken__c,Describe_how_the_worker_is_ensuring__c,'+
                                                      'What_efforts_were_made_to_promote__c,Has_a_Lifebook_been_prepared__c,Describe_the_parent_s_compliance__c,Does_the_Provider_agree_permanency__c,Permanancy_Agree_Explanation_Required__c,Discuss_services_being_provided__c', 'create', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
               insert createPermanacyRec;             
           } else {
               FieldLevelSecurity.checkFieldAccessByCriteria('Name,Primary_Permanency_Plan__c,Plan_Established_Date__c,Plan_Comments__c,Concurrent_Permanency_Plan__c,Concurrent_Plan_Established_Date__c,'+
                                                      'Concurrent_Comments__c,End_Date__c,End_Reason__c,Court_order_received_and_upload_in_CJAMS__c,If_the_Permanency_plan_is_to_return_home__c,Explanation_Required__c,'+
                                                      'Discuss_how_the_caregiver_is_meeting__c,Discuss_and_explain_changes_in_the_child__c,Describe_how_the_worker_is_carrying_out__c,Document_what_steps_have_been_taken__c,Describe_how_the_worker_is_ensuring__c,'+
                                                      'What_efforts_were_made_to_promote__c,Has_a_Lifebook_been_prepared__c,Describe_the_parent_s_compliance__c,Does_the_Provider_agree_permanency__c,Permanancy_Agree_Explanation_Required__c,Discuss_services_being_provided__c', 'update', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
              update createPermanacyRec;
           
           }
           return createPermanacyRec.Id;
       } else {
           return null;
       }         
         
    }
    
    
    public class getInitialWrapper { 
        @AuraEnabled
        public List<Utility.pickListWrap> primaryPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> concurrentPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> returnPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> guardianshipPlaningPicklist;
        @AuraEnabled
        public Permanency_Plan__c  permanencyInst;
        @AuraEnabled
        public List<contact>  childList;
        @AuraEnabled
        public Permanency_Plan__c  permanencyInitialInst;
        @AuraEnabled
        public Placement__c placementRecId;
        @AuraEnabled
        public List<Placement__c> approvedPlacementChildList;
        
    }
    
    @AuraEnabled
    public static String getInitialPermanancyDetails(String permanancyPlanId) {  
    
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.guardianshipPlaningPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Guardianship_Planing__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Guardianship_Planing__c, Gender__c, D_O_B__c, Client_Name__c, Contact__c', 'view','Permanency_Plan__c' ,  Boolean.valueOf(Label.HasNamespace));
        initWrap.permanencyInst = [SELECT Id, Guardianship_Planing__c, Gender__c, D_O_B__c, Client_Name__c,
                                   Contact__r.Casevault_PID__c FROM Permanency_Plan__c WHERE Id = :permanancyPlanId LIMIT :Utility.queryLimit];
        
        return JSON.serialize(initWrap);
    }


}