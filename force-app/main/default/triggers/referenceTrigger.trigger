trigger referenceTrigger on Reference__c (before insert, before update) {    
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
    
        Set<Id> homeApprovalIds = new Set<Id>();
        Set<Id> notMetHomeApprovalIds = new Set<Id>();
        List<Home_Approval__c> approvalList = new List<Home_Approval__c>();
        
        for(Reference__c reference : Trigger.new) {
            
            if(reference.Home_Approval__c != null && reference.Related_To__c != null && reference.Related_To__c  == 'Applicant') {
                
                homeApprovalIds.add(reference.Home_Approval__c);                
            }
            
            if(reference.Home_Approval__c != null && reference.Related_To__c != null 
                    && Trigger.oldMap != null && Trigger.oldMap.get(reference.Id).Related_To__c == 'Applicant' 
                    && Trigger.oldMap.get(reference.Id).Related_To__c != reference.Related_To__c) {
                
                notMetHomeApprovalIds.add(reference.Home_Approval__c);
            }
        }
        
        if(homeApprovalIds != null) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Minimum_of_three_references__c','view','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
            for(Home_Approval__c approvals : [SELECT Id, Name, Minimum_of_three_references__c From Home_Approval__c WHERE Id IN :homeApprovalIds]) {
                
                approvals.Minimum_of_three_references__c = True;
                approvalList.add(approvals);
            }
        }
        
        if(notMetHomeApprovalIds != null) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Minimum_of_three_references__c','view','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
            for(Home_Approval__c approvals : [SELECT Id, Name, Minimum_of_three_references__c From Home_Approval__c WHERE Id IN :notMetHomeApprovalIds]) {
                
                approvals.Minimum_of_three_references__c = False;
                approvalList.add(approvals);
            }
        }
        
        if(approvalList != null) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Minimum_of_three_references__c','update','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
            Update approvalList;
        }
    }

}