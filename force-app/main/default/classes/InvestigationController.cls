public  with sharing class InvestigationController {
    
    @AuraEnabled
    public static String getInvestigationRecord(Id investigationId, String objectApiName) {
        
        getInitialWrapper intiWrapper = new getInitialWrapper();
        
        if(String.isNotBlank(investigationId)) {
            
            if(objectApiName == 'Child_Removal__c') {
                investigationId = [SELECT Id, Investigation__c FROM Child_Removal__c WHERE Id = :investigationId LIMIT :Utility.queryLimit].Investigation__c;
            }

            FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c, Number_of_days_created_date__c,Due_On__c, Head_of_Household__c, Response_Timer__c', 'view', 'Investigation__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Restrict_UnRestrict__c, Origin, CaseNumber, Supervisor_Approver__c,Status', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_PID__c, Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));

            intiWrapper.investigationRecord = [SELECT Id,Name, Intake__c, Intake__r.CaseNumber, Due_On__c,Intake__r.Supervisor_Approver__r.Name, 
                                               Intake__r.Restrict_UnRestrict__c, Head_of_Household__r.Name, Head_of_Household__r.Casevault_PID__c, Response_Timer__c,
                                               Intake__r.Origin, CreatedDate, Number_of_days_created_date__c, Owner.Name, Intake__r.Status 
                                               FROM Investigation__c 
                                               WHERE Id =: investigationId LIMIT :Utility.queryLimit
                                              ];
            
            Datetime createddate = intiWrapper.investigationRecord.CreatedDate;
            intiWrapper.startDate = createddate.format('MM/dd/yyyy hh:mm a');
            if (String.isNotBlank(intiWrapper.investigationRecord.Intake__c)) {
            List<Case> intakeReviewerDetails = [SELECT Id, Owner.Name FROM Case 
                                                              WHERE Id=:intiWrapper.investigationRecord.Intake__c LIMIT :Utility.queryLimit];
            if(intakeReviewerDetails != Null && intakeReviewerDetails.size() > 0) {
                intiWrapper.reviewer = intakeReviewerDetails[0].Owner.Name;
            }
           }
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Investigation__c, Approval_Status__c, Supervisor_Approver__c', 'view', 'Investigation_Findings__c',  Boolean.valueOf(Label.HasNamespace));
            
            List<Investigation_Findings__c> invenstigationFindingRec = [SELECT Id, Investigation__c, Approval_Status__c, Supervisor_Approver__r.Name 
                                                                        FROM Investigation_Findings__c WHERE Investigation__c = :investigationId 
                                                                        ORDER BY LastModifiedDate DESC LIMIT 1];
            
            
            return JSON.serialize(intiWrapper);
            
        } else {
            
            return null;
            
        }
        
        
    }
    
    public class getInitialWrapper { 
        @AuraEnabled
        public Investigation__c investigationRecord;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String reviewer; 
        
    }
}