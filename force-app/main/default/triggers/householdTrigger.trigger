trigger householdTrigger on Household__c (before insert, before update, after insert, after update, after delete) {
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
    
        Set<Id> homeApprovalIds = new Set<Id>();
        Set<Id> notMetHomeApprovalIds = new Set<Id>();
        List<Home_Approval__c> approvalList = new List<Home_Approval__c>();
        Boolean statecriminal = False;
        Boolean physicalexam = False;
        Boolean federalcriminal = False;
        
        for(Household__c household : Trigger.new) {
        
            if(household.Home_Approval__c != null) {
                
                if(household.Ethnicity_Hispanic__c != null && household.Ethnicity_Hispanic__c  == 'Yes') {
                    statecriminal = True;
                    homeApprovalIds.add(household.Home_Approval__c);                
                }
                
                if(household.Related_To__c != null && household.Related_To__c  == 'Applicant') {
                    physicalexam = True;
                    homeApprovalIds.add(household.Home_Approval__c);                
                }
                
                if(household.Child_Household_Member__c != null && household.Child_Household_Member__c  == 'Child') {
                    federalcriminal = True;
                    homeApprovalIds.add(household.Home_Approval__c);                
                }
                
                 if(household.Ethnicity_Hispanic__c != null 
                    && Trigger.oldMap != null && Trigger.oldMap.get(household.Id).Ethnicity_Hispanic__c == 'Yes' 
                    && Trigger.oldMap.get(household.Id).Ethnicity_Hispanic__c != household.Ethnicity_Hispanic__c) {
                
                    statecriminal = False;
                    notMetHomeApprovalIds.add(household.Home_Approval__c);
                }
                
                if(household.Related_To__c != null 
                        && Trigger.oldMap != null && Trigger.oldMap.get(household.Id).Related_To__c == 'Applicant' 
                        && Trigger.oldMap.get(household.Id).Related_To__c != household.Related_To__c) {
                    
                    physicalexam = False;
                    notMetHomeApprovalIds.add(household.Home_Approval__c);
                }
                
                if(household.Child_Household_Member__c != null 
                        && Trigger.oldMap != null && Trigger.oldMap.get(household.Id).Child_Household_Member__c == 'Child' 
                        && Trigger.oldMap.get(household.Id).Child_Household_Member__c != household.Child_Household_Member__c) {
                    
                    federalcriminal = False;
                    notMetHomeApprovalIds.add(household.Home_Approval__c);
                }
            }
        }
        
        if(homeApprovalIds != null) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, State_criminal_record_household_members__c, Federal_criminal_record_household_member__c, Physical_exams_for_household_members__c','view','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
            for(Home_Approval__c approvals : [SELECT Id, Name, State_criminal_record_household_members__c, Federal_criminal_record_household_member__c, Physical_exams_for_household_members__c 
                                                From Home_Approval__c WHERE Id IN :homeApprovalIds]) {
                
                if(statecriminal) {
                    approvals.State_criminal_record_household_members__c = True;
                }
                
                if(federalcriminal) {
                    approvals.Federal_criminal_record_household_member__c = True;
                }
                
                if(physicalexam) {
                    approvals.Physical_exams_for_household_members__c = True;
                }
                
                approvalList.add(approvals);
            }
        }
        
        if(notMetHomeApprovalIds != null) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, State_criminal_record_household_members__c, Federal_criminal_record_household_member__c, Physical_exams_for_household_members__c','view','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
            for(Home_Approval__c approvals : [SELECT Id, Name, State_criminal_record_household_members__c, Federal_criminal_record_household_member__c, Physical_exams_for_household_members__c 
                                                From Home_Approval__c WHERE Id IN :notMetHomeApprovalIds]) {
                
                
                approvals.State_criminal_record_household_members__c = statecriminal; 
                approvals.Federal_criminal_record_household_member__c = federalcriminal;
                approvals.Physical_exams_for_household_members__c = physicalexam;
                approvalList.add(approvals);
            }
        }
        
        if(approvalList != null) {
            
            Update approvalList;
        }
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    
        Map<Id, Boolean> homeApprovalIdFilledMap = new Map<Id, Boolean>();
        List<Home_Approval__c> updateHomeApprovalList = new List<Home_Approval__c>();
        for(Household__c household : Trigger.new) {
        
            if (household.Verified__c && household.Household_Verified__c) {
            
                homeApprovalIdFilledMap.put(household.Home_Approval__c, true);
            } else {
                homeApprovalIdFilledMap.put(household.Home_Approval__c, false);
            }
        } 
        for (Id homeApprovalId: homeApprovalIdFilledMap.keySet()) {
        
            Home_Approval__c updateHomeApprovalRec = new Home_Approval__c();
            updateHomeApprovalRec.Id = homeApprovalId;
            updateHomeApprovalRec.Filled_Household__c = homeApprovalIdFilledMap.get(homeApprovalId);
            updateHomeApprovalList.add(updateHomeApprovalRec);
        }
        if (updateHomeApprovalList != null && updateHomeApprovalList.size() > 0) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Filled_Household__c','update','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
            update updateHomeApprovalList;
        }   
    }
    
    if(Trigger.isAfter && Trigger.isDelete) {
    
        Set<Id> homeApprovalIds = new Set<Id>();
        List<Home_Approval__c> updateHomeApprovalList = new List<Home_Approval__c>();
        for(Household__c household : Trigger.old) {
            homeApprovalIds.add(household.Home_Approval__c);
        } 
        for (Id homeApprovalId: homeApprovalIds) {
        
            Home_Approval__c updateHomeApprovalRec = new Home_Approval__c();
            updateHomeApprovalRec.Id = homeApprovalId;
            updateHomeApprovalRec.Filled_Household__c = false;
            updateHomeApprovalList.add(updateHomeApprovalRec);
        }
        if (updateHomeApprovalList != null && updateHomeApprovalList.size() > 0) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Filled_Household__c','update','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
            update updateHomeApprovalList;
        }        
    }
}