public with sharing class AssessmentController {
    
    @AuraEnabled
    public static String getSAFECOHPInitialInformation(String recordId) {
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.childInputWarpList = new List<ChildInputWarp>();
       
        initWrap.thechildsImmediatehealthneedsPicklist =  Utility.getPicklistinfo('Assessment__c','The_child_s_Immediate_health_needs__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Service_Case__c, Investigation__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        
        initWrap.conactList = [SELECT Name, Service_Case__c, Investigation__c FROM Contact WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId)  LIMIT :Utility.queryLimit];   
        Id recId = recordId;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, OHP_Signature_Obtained_Date__c, Approval_Status__c, Service_Case__c, Investigation__c, Assessment_Type__c', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
        
        initWrap.assessmentOHPList = [SELECT Id, Name, OHP_Signature_Obtained_Date__c, Approval_Status__c FROM Assessment__c
                                      WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId)  AND Assessment_Type__c = 'SAFE-C-OHP'
                                      ORDER BY Name  LIMIT :Utility.queryLimit
                                     ];
        if(sObjName == 'Service_Case__c') {
            FieldLevelSecurity.checkFieldAccessByCriteria('Status__c','view','Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
            initWrap.statusService = [ SELECT Id, Status__c FROM Service_Case__c WHERE Id = :recordId  LIMIT :Utility.queryLimit];
        }
        List<Utility.pickListWrap> recPickList = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        recPickList.add(intialPick);
        Utility.pickListWrap pick;
        for(Contact contactIns : initWrap.conactList) {
        
            pick = new Utility.pickListWrap();       
            pick.label = contactIns.Name;
            pick.value = contactIns.Id;
            recPickList.add(pick);
        }
        initWrap.cotactsNames = recPickList;
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Service_Case__c,HEAD_OF_HOUSEHOLD__c,Intake_Person_Role__c,Casevault_PID__c, Investigation__c, Age__c,Investigation__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Status__c,Name', 'view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
        
        initWrap.childList = [SELECT Name, Id, Service_Case__c, Service_Case__r.Status__c, HEAD_OF_HOUSEHOLD__c,Service_Case__r.Name, Casevault_PID__c, Investigation__c, Age__c FROM Contact WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId)
                              AND Intake_Person_Role__c includes ('Biological Child','Other Child (Not in Household)','Private Adoptive Child')  LIMIT :Utility.queryLimit
                             ];
        ChildInputWarp childInputWarpTableIns;
        if (initWrap.childList != null && initWrap.childList.size() > 0) {
            
            for (Contact conIns: initWrap.childList) {
                childInputWarpTableIns = new ChildInputWarp();
                childInputWarpTableIns.chidName = conIns.Name;
                childInputWarpTableIns.age = conIns.Age__c;
                childInputWarpTableIns.childId = conIns.Id;
                childInputWarpTableIns.clientId = conIns.Casevault_PID__c;
                initWrap.childInputWarpList.add(childInputWarpTableIns);
            }
        }
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getAssessmentOHP(String assessmentRecordId) { 
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Approval_Status__c, OHP_Child_Name__c, Current_Placement__c,  Potential_Resource__c,  Name_of_Placement_Resource__c,  OHP_Address_Line_1__c,  Address_Line_2__c,'+  
                                                      'OHP_Zipcode__c,  OHP_Work__c,  OHP_Ext__c,  OHP_Fax__c,  Staff_Member_Interviewed_Comments__c,  When_Circumstances_Suggest_That_the_Chil__c,'+ 
                                                      'Initial_Replacement_Placements__c, SAFEC_Before_Completing_a_case__c, The_child_s_Immediate_health_needs__c,  If_the_child_was_on_medication__c,  If_the_child_had_a_history_of_suicidal__c,'+
                                                      'If_the_child_had_a_history_of_aggressive__c, If_the_child_had_a_history_of_sexual__c, If_the_child_had_a_history_of_drug__c,  This_child_s_sleeping_arrangements__c,'+ 
                                                      'This_child_s_is_or_will_be_protected__c, This_child_does_not_express_specific__c, Provider_appears_competent_coherent__c, Any_injuries_to_the_child__c, This_child_s_whereabouts_are_known__c,'+
                                                      'OHP_Unsafe_Influences__c, OHP_Safety_Decision__c, OHP_Child_is_Safe_Influences_1_12_Marked__c,  OHP_Child_is_Unsafe_Any_Influence_1_12__c, OHP_Whereabouts_of_Child_Youth__c,'+ 
                                                      'OHP_If_Placed_with_Potential_Resource__c, OHP_if_they_remain_with_the_current__c,  OHP_Comments__c,  OHP_Signature_Obtained__c,  OHP_Signature_Obtained_Date__c,'+
                                                      'OHP_Representative_Title__c,  OHP_Local_Department__c','view','Assessment__c', Boolean.valueOf(Label.HasNamespace));
        
        initWrap.assessmentOHPRec = [SELECT Id, Approval_Status__c, OHP_Child_Name__c, Current_Placement__c,  Potential_Resource__c,  Name_of_Placement_Resource__c,  OHP_Address_Line_1__c,  Address_Line_2__c,  
                                     OHP_Zipcode__c,  OHP_Work__c,  OHP_Ext__c,  OHP_Fax__c,  Staff_Member_Interviewed_Comments__c,  When_Circumstances_Suggest_That_the_Chil__c, 
                                     Initial_Replacement_Placements__c, SAFEC_Before_Completing_a_case__c, The_child_s_Immediate_health_needs__c,  If_the_child_was_on_medication__c,  If_the_child_had_a_history_of_suicidal__c,
                                     If_the_child_had_a_history_of_aggressive__c, If_the_child_had_a_history_of_sexual__c, If_the_child_had_a_history_of_drug__c,  This_child_s_sleeping_arrangements__c, 
                                     This_child_s_is_or_will_be_protected__c, This_child_does_not_express_specific__c, Provider_appears_competent_coherent__c, Any_injuries_to_the_child__c, This_child_s_whereabouts_are_known__c,
                                     OHP_Unsafe_Influences__c, OHP_Safety_Decision__c, OHP_Child_is_Safe_Influences_1_12_Marked__c,  OHP_Child_is_Unsafe_Any_Influence_1_12__c, OHP_Whereabouts_of_Child_Youth__c, 
                                     OHP_If_Placed_with_Potential_Resource__c, OHP_if_they_remain_with_the_current__c,  OHP_Comments__c,  OHP_Signature_Obtained__c,  OHP_Signature_Obtained_Date__c, 
                                     OHP_Representative_Title__c,  OHP_Local_Department__c FROM Assessment__c WHERE Id =:assessmentRecordId  LIMIT :Utility.queryLimit];
        return JSON.serialize(initWrap);            
    }
    
    @AuraEnabled
    public static String getAssessment(String assessmentRecordId) {
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Approval_Status__c, SAFEC_Date_Time_Assessment_Initiated__c, SAFEC_Case_Worker_Comments__c, SAFEC_Date_Time_of_Last_Safety_Plan__c, SAFEC_Legal_Guardian_Name__c,'+ 
                                                      'SAFEC_CPS_Case_ID__c, SAFEC_Head_of_Household__c, SAFEC_Relationship__c, SAFEC_CIS_ID__c,'+
                                                      'SAFEC_Caregiver__c, SAFEC_At_the_Initial_face_to_facecontact__c, SAFEC_At_the_completion_closure__c,'+
                                                      'SAFEC_When_The_case_Assessor_discovers__c, SAFEC_When_circumstances_suggest__c, SAFEC_Within_7_Working_days_of_case__c,'+
                                                      'SAFEC_Before_Completing_a_case__c, SAFEC_At_time_of_trial_home_visit__c, SAFEC_Within_ten_10_working_days__c,'+
                                                      'SAFEC_Out_HOME_Before_completing_a_case__c, SAFEC_within_7_working_days_prior__c, SAFEC_Within_7_working_days_prior_to__c,'+ 
                                                      'SAFEC_OUT_HOME_When_the_case_assessor__c, SAFEC_When_circumstances_suggest_that__c, SAFEC_Age_0_5_Years_old__c,'+
                                                      'SAFEC_Diminished_Physical_capacity__c, SAFEC_Diminished_mental_capacity__c, SAFEC_School_age_but_not_attending__c,'+
                                                      'SAFEC_Significant_diagnosed_medical_or__c, SAFEC_Child_s_extreme_anxiety_or_fear__c,'+
                                                      'SAFEC_Caregiver_fails_to_protect__c, SAFEC_Caregiver_fails_Comments__c, SAFEC_Caregiver_made_a_plausible_threat__c, SAFEC_Caregiver_made_a_Comments__c,'+
                                                      'SAFEC_There_has_been_current_act__c, SAFEC_There_has_been_current_actComments__c, SAFEC_Child_sexual_abuse_is_suspected__c,'+
                                                      'SAFEC_Child_sexual_abuse_Comments__c, SAFEC_Caregiver_describes_the_child__c, SAFEC_Caregiver_describes_Comments__c,'+
                                                      'SAFEC_Cargiver_s_suspected_or_observed__c, SAFEC_Cargiver_s_suspected_Comments__c, SAFEC_Caregiver_s_emotional_instability__c,'+
                                                      'SAFEC_Caregiver_s_emotional_Comments__c, SAFEC_Caregiver_s_explanation__c, SAFEC_Caregiver_s_explanation_Comments__c, SAFEC_Caregivers_justification_or_denial__c,'+
                                                      'SAFEC_Caregivers_justification_Comments__c, SAFEC_Caregiver_does_not_or_refuse__c, SAFEC_Caregiver_does_not_Comments__c,'+
                                                      'SAFEC_Domestic_violence_exists__c, SAFEC_Domestic_violence_Comments__c, SAFEC_Caregiver_does_not_meet_the_childs__c,'+
                                                      'SAFEC_Caregiver_does_not_meet_Comments__c, SAFEC_The_childs_whereabouts_are_unknown__c, SAFEC_The_childs_whereabouts_Comments__c,'+
                                                      'SAFEC_The_child_has_special_needs__c, SAFEC_The_child_has_special_Comments__c, SAFEC_The_child_is_extremely_anxious__c,'+
                                                      'SAFEC_The_child_is_extremely_Comments__c, SAFEC_The_child_is_unable_to_protect__c, SAFEC_The_child_is_unable_Comments__c,'+
                                                      'SAFEC_Previous_services_to_the_caregiver__c, SAFEC_Previous_services_Comments__c, SAFEC_There_have_been_multiple_reports__c,'+
                                                      'SAFEC_There_have_been_multiple_Comments__c, SAFEC_Child__c, SAFEC_Caregiver_is_able__c, SAFEC_Caregiver_is_able_and_willing__c,'+
                                                      'SAFEC_Caregiver_has_supportive__c, SAFEC_Caregiver_exhibits_self_control__c, SAFEC_There_is_evidence_of_a_healthy__c,'+
                                                      'SAFEC_Caregiver_demonstrated_effective__c, SAFEC_Relevant_community_services__c,'+
                                                      'SAFEC_Any_Influences_1_18_was_checked__c, SAFEC_Caregiver_did_not_agree_to_safety__c,'+
                                                      'SAFEC_Danger_cannot_be_addressed_via__c, SAFEC_LDSS__c, Workers_Name__c, Supervisor_Name__c, Submit_for_Approval__c,'+
                                                      'When_Circumstances_Suggest_That_the_Chil__c, Safety_Assessment_Approval_Date_Time__c,'+
                                                      'SAFEC_Child_is_Conditionally_Safe_17_16__c, SAFEC_Child_is_Safe_Influences_1_18__c,'+
                                                      'SAFEC_Child_is_conditionally_Safe__c, SAFEC_Child_is_UnSafe__c,'+
                                                      'Safety_Assessment_Completion_Date_Time__c','view','Assessment__c', Boolean.valueOf(Label.HasNamespace));
        
        initWrap.assessmentRec = [SELECT Id, Approval_Status__c, SAFEC_Date_Time_Assessment_Initiated__c, SAFEC_Case_Worker_Comments__c, SAFEC_Date_Time_of_Last_Safety_Plan__c, SAFEC_Legal_Guardian_Name__c, 
                                  SAFEC_CPS_Case_ID__c, SAFEC_Head_of_Household__c, SAFEC_Relationship__c, SAFEC_CIS_ID__c,
                                  SAFEC_Caregiver__c, SAFEC_At_the_Initial_face_to_facecontact__c, SAFEC_At_the_completion_closure__c,
                                  SAFEC_When_The_case_Assessor_discovers__c, SAFEC_When_circumstances_suggest__c, SAFEC_Within_7_Working_days_of_case__c,
                                  SAFEC_Before_Completing_a_case__c, SAFEC_At_time_of_trial_home_visit__c, SAFEC_Within_ten_10_working_days__c,
                                  SAFEC_Out_HOME_Before_completing_a_case__c, SAFEC_within_7_working_days_prior__c, SAFEC_Within_7_working_days_prior_to__c, 
                                  SAFEC_OUT_HOME_When_the_case_assessor__c, SAFEC_When_circumstances_suggest_that__c, SAFEC_Age_0_5_Years_old__c,
                                  SAFEC_Diminished_Physical_capacity__c, SAFEC_Diminished_mental_capacity__c, SAFEC_School_age_but_not_attending__c,
                                  SAFEC_Significant_diagnosed_medical_or__c, SAFEC_Child_s_extreme_anxiety_or_fear__c,
                                  SAFEC_Caregiver_fails_to_protect__c, SAFEC_Caregiver_fails_Comments__c, SAFEC_Caregiver_made_a_plausible_threat__c, SAFEC_Caregiver_made_a_Comments__c,
                                  SAFEC_There_has_been_current_act__c, SAFEC_There_has_been_current_actComments__c, SAFEC_Child_sexual_abuse_is_suspected__c,
                                  SAFEC_Child_sexual_abuse_Comments__c, SAFEC_Caregiver_describes_the_child__c, SAFEC_Caregiver_describes_Comments__c,
                                  SAFEC_Cargiver_s_suspected_or_observed__c, SAFEC_Cargiver_s_suspected_Comments__c, SAFEC_Caregiver_s_emotional_instability__c,
                                  SAFEC_Caregiver_s_emotional_Comments__c, SAFEC_Caregiver_s_explanation__c, SAFEC_Caregiver_s_explanation_Comments__c, SAFEC_Caregivers_justification_or_denial__c,
                                  SAFEC_Caregivers_justification_Comments__c, SAFEC_Caregiver_does_not_or_refuse__c, SAFEC_Caregiver_does_not_Comments__c,
                                  SAFEC_Domestic_violence_exists__c, SAFEC_Domestic_violence_Comments__c, SAFEC_Caregiver_does_not_meet_the_childs__c,
                                  SAFEC_Caregiver_does_not_meet_Comments__c, SAFEC_The_childs_whereabouts_are_unknown__c, SAFEC_The_childs_whereabouts_Comments__c,
                                  SAFEC_The_child_has_special_needs__c, SAFEC_The_child_has_special_Comments__c, SAFEC_The_child_is_extremely_anxious__c,
                                  SAFEC_The_child_is_extremely_Comments__c, SAFEC_The_child_is_unable_to_protect__c, SAFEC_The_child_is_unable_Comments__c,
                                  SAFEC_Previous_services_to_the_caregiver__c, SAFEC_Previous_services_Comments__c, SAFEC_There_have_been_multiple_reports__c,
                                  SAFEC_There_have_been_multiple_Comments__c, SAFEC_Child__c, SAFEC_Caregiver_is_able__c, SAFEC_Caregiver_is_able_and_willing__c,
                                  SAFEC_Caregiver_has_supportive__c, SAFEC_Caregiver_exhibits_self_control__c, SAFEC_There_is_evidence_of_a_healthy__c,
                                  SAFEC_Caregiver_demonstrated_effective__c, SAFEC_Relevant_community_services__c,
                                  SAFEC_Any_Influences_1_18_was_checked__c, SAFEC_Caregiver_did_not_agree_to_safety__c,
                                  SAFEC_Danger_cannot_be_addressed_via__c, SAFEC_LDSS__c, Workers_Name__c, Supervisor_Name__c, Submit_for_Approval__c,
                                  When_Circumstances_Suggest_That_the_Chil__c, Safety_Assessment_Approval_Date_Time__c,
                                  Safety_Assessment_Completion_Date_Time__c,Service_Case__c,
                                  SAFEC_Child_is_Conditionally_Safe_17_16__c, SAFEC_Child_is_Safe_Influences_1_18__c, SAFEC_Child_is_conditionally_Safe__c, SAFEC_Child_is_UnSafe__c
                                  FROM Assessment__c WHERE Id = :assessmentRecordId  LIMIT :Utility.queryLimit];
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Specific_Danger_Influence__c, Responsible_Parties__c, Re_evaluation_Date__c,Question_Name__c, Index__c, Date_to_be_Completed__c, Danger_Influence_Qeustion__c, Action_Required__c', 
                                                      'view', 'Assessment_Safety_Plan__c',  Boolean.valueOf(Label.HasNamespace));
        initWrap.assessmentSafetyPlanList = [SELECT Id, Name, Specific_Danger_Influence__c, Responsible_Parties__c, Re_evaluation_Date__c,
                                             Question_Name__c, Index__c, Date_to_be_Completed__c, Danger_Influence_Qeustion__c, Action_Required__c FROM Assessment_Safety_Plan__c WHERE Assessment__c = :assessmentRecordId  LIMIT :Utility.queryLimit];
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static String getSAFECInitialInformation(String recordId) {
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.childInputWarpList = new List<ChildInputWarp>();
        initWrap.assessmentList = new List<safecWarp>();
        
        List<Assessment__c> safecList = new List<Assessment__c> ();        
        
        Id recId = recordId;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        
        if(sObjName == 'Service_Case__c') {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
            initWrap.cpsCaseName  = [SELECT Id,Name FROM Service_Case__c WHERE Id = :recordId  LIMIT :Utility.queryLimit].Name;
            FieldLevelSecurity.checkFieldAccessByCriteria('Status__c','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
            initWrap.statusService = [ SELECT Id, Status__c FROM Service_Case__c WHERE Id = :recordId  LIMIT :Utility.queryLimit];
            
        } else if(sObjName == 'Investigation__c'){
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Investigation__c', Boolean.valueOf(Label.HasNamespace));
            initWrap.cpsCaseName  = [SELECT Id, Name FROM Investigation__c WHERE Id = :recordId  LIMIT :Utility.queryLimit].Name;
        }
        
        initWrap.caregiverDescribesTheChildPicklist =  Utility.getPicklistinfo('Assessment__c','SAFEC_Cargiver_s_suspected_or_observed__c',false);
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Service_Case__c,HEAD_OF_HOUSEHOLD__c,Casevault_PID__c, Investigation__c, Age__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Status__c,Name','view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));  
              
        initWrap.childList = [SELECT Name, Id, Service_Case__c, Service_Case__r.Status__c, HEAD_OF_HOUSEHOLD__c,Service_Case__r.Name, Casevault_PID__c, Investigation__c, Age__c FROM Contact WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId)
                              AND Intake_Person_Role__c includes ('Biological Child','Other Child (Not in Household)','Private Adoptive Child')  LIMIT :Utility.queryLimit
                             ];
                             
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Service_Case__c,Investigation__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Status__c','view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));   
                
        initWrap.caregiverList = [SELECT Name, Id, Service_Case__c, Service_Case__r.Status__c, Investigation__c FROM Contact WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) 
                                  AND  Is_Caregiver__c =true  LIMIT :Utility.queryLimit
                                 ];
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Safety_Assessment_Completion_Date_Time__c, Approval_Status__c,Service_Case__c,Investigation__c','view','Assessment__c', Boolean.valueOf(Label.HasNamespace));
        
        safecList = [SELECT Name, Safety_Assessment_Completion_Date_Time__c, Approval_Status__c FROM Assessment__c 
                     WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) AND Assessment_Type__c = 'SAFE-C' ORDER BY Name  LIMIT :Utility.queryLimit];
        safecWarp safecWarpTableIns;
        for(Assessment__c ass :safecList) {
        
            safecWarpTableIns = new safecWarp();
            Datetime yourDate = ass.Safety_Assessment_Completion_Date_Time__c;
            String dateOutput = yourDate.format('MM/dd/yyyy hh:mm a'); 
            safecWarpTableIns.id = ass.Id;
            safecWarpTableIns.name = ass.Name;
            safecWarpTableIns.completionDate = dateOutput;
            safecWarpTableIns.approvalStatus = ass.Approval_Status__c;
            initWrap.assessmentList.add(safecWarpTableIns);
        }
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Service_Case__c,HEAD_OF_HOUSEHOLD__c, Investigation__c','view','Contact', Boolean.valueOf(Label.HasNamespace)); 
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Investigation__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));     
        List<Contact> headOfHouseHold = [SELECT Name, Id, Service_Case__c,HEAD_OF_HOUSEHOLD__c,Investigation__r.Name, Service_Case__r.Name, Investigation__c FROM Contact
                                        WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) AND HEAD_OF_HOUSEHOLD__c = true ORDER BY LastModifiedDate  DESC LIMIT 1];
        if(headOfHouseHold.size() > 0) {
            initWrap.headofHouseholdName =  headOfHouseHold[0].Name;
        }
        /*initWrap.headofHouseholdName = [SELECT Name, Id, Service_Case__c,HEAD_OF_HOUSEHOLD__c,Investigation__r.Name, Service_Case__r.Name, Investigation__c FROM Contact
                                        WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) ORDER BY LastModifiedDate  DESC LIMIT 1].Name;*/
        List<Utility.pickListWrap> recPickList = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        recPickList.add(intialPick);
        Utility.pickListWrap pick;
        for(Contact contactIns : initWrap.caregiverList) {
        
            pick = new Utility.pickListWrap();
            pick.label = contactIns.Name;
            pick.value = contactIns.Name;
            recPickList.add(pick);
        }
        initWrap.caregiverNames = recPickList;
        initwrap.submitforApprovalPickList =  Utility.getPicklistinfo('Assessment__c','Submit_for_Approval__c',false);
        
        if (initWrap.childList != null && initWrap.childList.size() > 0) {
            
            ChildInputWarp childInputWarpTableIns;
            for (Contact conIns: initWrap.childList) {
                childInputWarpTableIns = new ChildInputWarp();
                childInputWarpTableIns.chidName = conIns.Name;
                childInputWarpTableIns.age = conIns.Age__c;
                childInputWarpTableIns.childId = conIns.Id;
                childInputWarpTableIns.clientId = conIns.Casevault_PID__c;
                initWrap.childInputWarpList.add(childInputWarpTableIns);
            }
        }  
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String createSAFECOHP(String assessmentSAFECOHPDataJSON) {
        
        
        if (String.isNotBlank(assessmentSAFECOHPDataJSON)) {
            Assessment__c createSAFECOHPRec = (Assessment__c) JSON.deserialize(assessmentSAFECOHPDataJSON, Assessment__c.class);
            
            if (String.isBlank(createSAFECOHPRec.Id)) {
                
                Fieldlevelsecurity.checkFieldAccessByCriteria('Current_Placement__c,Potential_Resource__c,Name_of_Placement_Resource__c,OHP_Address_Line_1__c,Address_Line_2__c,'+
                                                              'OHP_Zipcode__c,OHP_Work__c,OHP_Ext__c,OHP_Fax__c,Staff_Member_Interviewed_Comments__c,When_Circumstances_Suggest_That_the_Chil__c,'+
                                                              'Initial_Replacement_Placements__c,SAFEC_Before_Completing_a_case__c,The_child_s_Immediate_health_needs__c,If_the_child_was_on_medication__c,'+
                                                              'If_the_child_had_a_history_of_suicidal__c,If_the_child_had_a_history_of_aggressive__c,If_the_child_had_a_history_of_sexual__c,If_the_child_had_a_history_of_drug__c,'+
                                                              'This_child_s_sleeping_arrangements__c,This_child_s_is_or_will_be_protected__c,This_child_does_not_express_specific__c,'+
                                                              'Provider_appears_competent_coherent__c,Any_injuries_to_the_child__c,This_child_s_whereabouts_are_known__c,OHP_Unsafe_Influences__c,'+
                                                              'OHP_Safety_Decision__c,OHP_Whereabouts_of_Child_Youth__c,OHP_If_Placed_with_Potential_Resource__c,OHP_if_they_remain_with_the_current__c,'+
                                                              'OHP_Child_is_Safe_Influences_1_12_Marked__c,  OHP_Child_is_Unsafe_Any_Influence_1_12__c,'+ 
                                                              'OHP_Comments__c,OHP_Signature_Obtained__c,OHP_Signature_Obtained_Date__c,OHP_Representative_Title__c,OHP_Local_Department__c','create','Assessment__c',  Boolean.valueOf(Label.HasNamespace));
                insert createSAFECOHPRec;                                       
            } else {
                
                Fieldlevelsecurity.checkFieldAccessByCriteria('Current_Placement__c,Potential_Resource__c,Name_of_Placement_Resource__c,OHP_Address_Line_1__c,Address_Line_2__c,'+
                                                              'OHP_Zipcode__c,OHP_Work__c,OHP_Ext__c,OHP_Fax__c,Staff_Member_Interviewed_Comments__c,When_Circumstances_Suggest_That_the_Chil__c,'+
                                                              'Initial_Replacement_Placements__c,SAFEC_Before_Completing_a_case__c,The_child_s_Immediate_health_needs__c,If_the_child_was_on_medication__c,'+
                                                              'If_the_child_had_a_history_of_suicidal__c,If_the_child_had_a_history_of_aggressive__c,If_the_child_had_a_history_of_sexual__c,If_the_child_had_a_history_of_drug__c,'+
                                                              'This_child_s_sleeping_arrangements__c,This_child_s_is_or_will_be_protected__c,This_child_does_not_express_specific__c,'+
                                                              'Provider_appears_competent_coherent__c,Any_injuries_to_the_child__c,This_child_s_whereabouts_are_known__c,OHP_Unsafe_Influences__c,'+
                                                              'OHP_Safety_Decision__c,OHP_Whereabouts_of_Child_Youth__c,OHP_If_Placed_with_Potential_Resource__c,OHP_if_they_remain_with_the_current__c,'+
                                                              'OHP_Child_is_Safe_Influences_1_12_Marked__c,  OHP_Child_is_Unsafe_Any_Influence_1_12__c,'+ 
                                                              'OHP_Comments__c,OHP_Signature_Obtained__c,OHP_Signature_Obtained_Date__c,OHP_Representative_Title__c,OHP_Local_Department__c','update','Assessment__c',  Boolean.valueOf(Label.HasNamespace));
                update createSAFECOHPRec;
            }
            return createSAFECOHPRec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String createSAFEC(String assessmentSAFECDataJSON, String safetyPlanQesDataJSON, String deletingSafetyPlanJSON) {
        
        if (String.isNotBlank(assessmentSAFECDataJSON)) {
            
            Assessment__c createSAFECRec = (Assessment__c) JSON.deserialize(assessmentSAFECDataJSON, Assessment__c.class);
            if (String.isBlank(createSAFECRec.Id)) {
                
                Fieldlevelsecurity.checkFieldAccessByCriteria('SAFEC_Date_Time_Assessment_Initiated__c,SAFEC_Date_Time_of_Last_Safety_Plan__c,SAFEC_Legal_Guardian_Name__c,SAFEC_CPS_Case_ID__c,'+
                                                              'SAFEC_Head_of_Household__c,SAFEC_Relationship__c,SAFEC_CIS_ID__c,SAFEC_Caregiver__c,SAFEC_At_the_Initial_face_to_facecontact__c,SAFEC_At_the_completion_closure__c,'+
                                                              'SAFEC_When_The_case_Assessor_discovers__c,SAFEC_When_circumstances_suggest__c,SAFEC_Within_7_Working_days_of_case__c,SAFEC_Before_Completing_a_case__c,'+
                                                              'SAFEC_At_time_of_trial_home_visit__c,SAFEC_Within_ten_10_working_days__c,SAFEC_Out_HOME_Before_completing_a_case__c,SAFEC_within_7_working_days_prior__c,SAFEC_Within_7_working_days_prior_to__c,'+
                                                              'SAFEC_OUT_HOME_When_the_case_assessor__c,SAFEC_When_circumstances_suggest_that__c,SAFEC_Age_0_5_Years_old__c,SAFEC_Diminished_Physical_capacity__c,SAFEC_School_age_but_not_attending__c,'+
                                                              'SAFEC_Significant_diagnosed_medical_or__c,SAFEC_Child_s_extreme_anxiety_or_fear__c,SAFEC_When_circumstances_suggest_that__c,SAFEC_Caregiver_fails_to_protect__c,'+
                                                              'SAFEC_Caregiver_made_a_plausible_threat__c,SAFEC_There_has_been_current_act__c,SAFEC_Child_sexual_abuse_is_suspected__c,SAFEC_Caregiver_describes_the_child__c,'+
                                                              'SAFEC_Cargiver_s_suspected_or_observed__c,SAFEC_Caregiver_s_emotional_instability__c,SAFEC_Caregiver_s_explanation__c,SAFEC_Caregivers_justification_or_denial__c,SAFEC_Caregiver_does_not_Comments__c,'+
                                                              'SAFEC_Domestic_violence_Comments__c,SAFEC_Caregiver_does_not_meet_Comments__c,SAFEC_The_childs_whereabouts_Comments__c,SAFEC_The_child_has_special_Comments__c,SAFEC_The_child_is_extremely_Comments__c,'+
                                                              'SAFEC_The_child_is_unable_Comments__c,SAFEC_Previous_services_Comments__c,SAFEC_There_have_been_multiple_Comments__c,SAFEC_Child__c,'+
                                                              'SAFEC_Caregiver_is_able__c,SAFEC_Caregiver_is_able_and_willing__c,SAFEC_Caregiver_has_supportive__c,SAFEC_Caregiver_exhibits_self_control__c,SAFEC_There_is_evidence_of_a_healthy__c,SAFEC_Caregiver_demonstrated_effective__c,'+
                                                              'SAFEC_Relevant_community_services__c,SAFEC_Any_Influences_1_18_was_checked__c,SAFEC_Child_currently_has_Out_of_Home__c,SAFEC_Caregiver_did_not_agree_to_safety__c,SAFEC_Danger_cannot_be_addressed_via__c,'+
                                                              'SAFEC_LDSS__c,Workers_Name__c,Supervisor_Name__c,Submit_for_Approval__c,'+
                                                              'SAFEC_Child_is_Conditionally_Safe_17_16__c, SAFEC_Child_is_Safe_Influences_1_18__c,'+
                                                              'SAFEC_Child_is_conditionally_Safe__c, SAFEC_Child_is_UnSafe__c,'+
                                                              'SAFEC_Case_Worker_Comments__c,Safety_Assessment_Approval_Date_Time__c,Safety_Assessment_Completion_Date_Time__c','create','Assessment__c', Boolean.valueOf(Label.HasNamespace));
                insert createSAFECRec;
            } else {
                
                Fieldlevelsecurity.checkFieldAccessByCriteria('SAFEC_Date_Time_Assessment_Initiated__c,SAFEC_Date_Time_of_Last_Safety_Plan__c,SAFEC_Legal_Guardian_Name__c,SAFEC_CPS_Case_ID__c,'+
                                                              'SAFEC_Head_of_Household__c,SAFEC_Relationship__c,SAFEC_CIS_ID__c,SAFEC_Caregiver__c,SAFEC_At_the_Initial_face_to_facecontact__c,SAFEC_At_the_completion_closure__c,'+
                                                              'SAFEC_When_The_case_Assessor_discovers__c,SAFEC_When_circumstances_suggest__c,SAFEC_Within_7_Working_days_of_case__c,SAFEC_Before_Completing_a_case__c,'+
                                                              'SAFEC_At_time_of_trial_home_visit__c,SAFEC_Within_ten_10_working_days__c,SAFEC_Out_HOME_Before_completing_a_case__c,SAFEC_within_7_working_days_prior__c,SAFEC_Within_7_working_days_prior_to__c,'+
                                                              'SAFEC_OUT_HOME_When_the_case_assessor__c,SAFEC_When_circumstances_suggest_that__c,SAFEC_Age_0_5_Years_old__c,SAFEC_Diminished_Physical_capacity__c,SAFEC_School_age_but_not_attending__c,'+
                                                              'SAFEC_Significant_diagnosed_medical_or__c,SAFEC_Child_s_extreme_anxiety_or_fear__c,SAFEC_When_circumstances_suggest_that__c,SAFEC_Caregiver_fails_to_protect__c,'+
                                                              'SAFEC_Caregiver_made_a_plausible_threat__c,SAFEC_There_has_been_current_act__c,SAFEC_Child_sexual_abuse_is_suspected__c,SAFEC_Caregiver_describes_the_child__c,'+
                                                              'SAFEC_Cargiver_s_suspected_or_observed__c,SAFEC_Caregiver_s_emotional_instability__c,SAFEC_Caregiver_s_explanation__c,SAFEC_Caregivers_justification_or_denial__c,SAFEC_Caregiver_does_not_Comments__c,'+
                                                              'SAFEC_Domestic_violence_Comments__c,SAFEC_Caregiver_does_not_meet_Comments__c,SAFEC_The_childs_whereabouts_Comments__c,SAFEC_The_child_has_special_Comments__c,SAFEC_The_child_is_extremely_Comments__c,'+
                                                              'SAFEC_The_child_is_unable_Comments__c,SAFEC_Previous_services_Comments__c,SAFEC_There_have_been_multiple_Comments__c,SAFEC_Child__c,'+
                                                              'SAFEC_Caregiver_is_able__c,SAFEC_Caregiver_is_able_and_willing__c,SAFEC_Caregiver_has_supportive__c,SAFEC_Caregiver_exhibits_self_control__c,SAFEC_There_is_evidence_of_a_healthy__c,SAFEC_Caregiver_demonstrated_effective__c,'+
                                                              'SAFEC_Relevant_community_services__c,SAFEC_Any_Influences_1_18_was_checked__c,SAFEC_Child_currently_has_Out_of_Home__c,SAFEC_Caregiver_did_not_agree_to_safety__c,SAFEC_Danger_cannot_be_addressed_via__c,'+
                                                              'SAFEC_LDSS__c,Workers_Name__c,Supervisor_Name__c,Submit_for_Approval__c,'+
                                                              'SAFEC_Child_is_Conditionally_Safe_17_16__c, SAFEC_Child_is_Safe_Influences_1_18__c,'+
                                                              'SAFEC_Child_is_conditionally_Safe__c, SAFEC_Child_is_UnSafe__c,'+
                                                              'SAFEC_Case_Worker_Comments__c,Safety_Assessment_Approval_Date_Time__c,Safety_Assessment_Completion_Date_Time__c','update','Assessment__c', Boolean.valueOf(Label.HasNamespace));
                update createSAFECRec;
            }
            
            if (String.isNotBlank(safetyPlanQesDataJSON)) {
                
                createSafetyPlan(safetyPlanQesDataJSON, createSAFECRec);
            }
            
            if (String.isNotBlank(deletingSafetyPlanJSON)) {
                
                deleteSafetyPlan(deletingSafetyPlanJSON);
            }
            return createSAFECRec.Id;
        } else {
            return null;
        }
    }
    
    public static void createSafetyPlan(String safetyPlanQesDataJSON, Assessment__c createSAFECRec) {
        
        List<Assessment_Safety_Plan__c> insertingAssSafetyPlanList = new List<Assessment_Safety_Plan__c>();
        List<Assessment_Safety_Plan__c> updatingAssSafetyPlanList = new List<Assessment_Safety_Plan__c>();
        
        List<Assessment_Safety_Plan__c> assessmentSafetyPlanList = (List<Assessment_Safety_Plan__c>) JSON.deserialize(safetyPlanQesDataJSON, List<Assessment_Safety_Plan__c>.class);
        for(Assessment_Safety_Plan__c asp : assessmentSafetyPlanList) {
            asp.Assessment__c = createSAFECRec.Id; 
            if (String.isBlank(asp.Id)) {
                insertingAssSafetyPlanList.add(asp);    
            } else {
                updatingAssSafetyPlanList.add(asp);
            }
            
        }
        if (insertingAssSafetyPlanList != null && insertingAssSafetyPlanList.size() > 0) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Question_Name__c, Specific_Danger_Influence__c,Action_Required__c, Date_to_be_Completed__c, Responsible_Parties__c, Re_evaluation_Date__c', 'create', 'Assessment_Safety_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            insert insertingAssSafetyPlanList;
        }
        if (updatingAssSafetyPlanList != null && updatingAssSafetyPlanList.size() > 0) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Question_Name__c, Specific_Danger_Influence__c,Action_Required__c, Date_to_be_Completed__c, Responsible_Parties__c, Re_evaluation_Date__c', 'update', 'Assessment_Safety_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            update updatingAssSafetyPlanList;
        }
    }
    
    public static void deleteSafetyPlan(String deletingSafetyPlanJSON) {
        
        List<Assessment_Safety_Plan__c> deletingSafetyPlanList = (List<Assessment_Safety_Plan__c>) JSON.deserialize(deletingSafetyPlanJSON, List<Assessment_Safety_Plan__c>.class);
        if (deletingSafetyPlanList != null && deletingSafetyPlanList.size() > 0) {
            
            FieldLevelSecurity.checkObjectAccessByDelete('Assessment_Safety_Plan__c');
            delete deletingSafetyPlanList;
        }
    }
    
    @AuraEnabled
    public static String onSubmitForApproval(String assessmentRecId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(assessmentRecId) && String.isNotBlank(selectedSupervisorUserId)) {
            Assessment__c assessmentRec =  new Assessment__c ();
            assessmentRec.Id = assessmentRecId;
            assessmentRec.Supervisor_Approver__c = selectedSupervisorUserId;
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Approver__c','update','Assessment__c', Boolean.valueOf(Label.HasNamespace));
            update assessmentRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Submit For Approval');        
            req.setObjectId(assessmentRec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
        
    } 
    
    @AuraEnabled
    public static String onSubmitStatus(String assessmentRecId){        
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Approval_Status__c','view','Assessment__c', Boolean.valueOf(Label.HasNamespace));
        Assessment__c assesmentRec = [SELECT Id, Approval_Status__c FROM Assessment__c WHERE Id = :assessmentRecId LIMIT 1];
        return JSON.serialize(assesmentRec); 
    } 
    
    @AuraEnabled
    public static String getFamilyRiskReassessmentInfo(String recordId, String objectApiName){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.RR1options =  Utility.getPicklistinfo('Assessment__c','Household_previously_received_CPS__c',false);
        initwrap.RR2options =  Utility.getPicklistinfo('Assessment__c','Prior_CPS_response_IR_AR__c',false);
        initwrap.RR3options =  Utility.getPicklistinfo('Assessment__c','Primary_caregiver_has_a_history_of_abuse__c',false);
        initwrap.RR4options =  Utility.getPicklistinfo('Assessment__c','Characteristics_of_children_household__c',true);
        initwrap.RR5options =  Utility.getPicklistinfo('Assessment__c','New_CPS_response_of_abuse_or_neglect__c',false);
        initwrap.RR6options =  Utility.getPicklistinfo('Assessment__c','Primary_caregiver_alcohol_or_substance__c',false);
        initwrap.RR7options =  Utility.getPicklistinfo('Assessment__c','Adult_relationships_since_the_MFIRA__c',false);
        initwrap.RR7Yesoptions =  Utility.getPicklistinfo('Assessment__c','Yes_problems_with_adult_r__c',true);
        initwrap.RR8options =  Utility.getPicklistinfo('Assessment__c','Primary_caregiver_mental_health__c',false);
        initwrap.RR9options =  Utility.getPicklistinfo('Assessment__c','Primary_caregiver_provides_physical_care__c',false);
        initwrap.riskLevelOptions =  Utility.getPicklistinfo('Assessment__c','RISK_LEVEL__c',false);
        initwrap.x1options =  Utility.getPicklistinfo('Assessment__c','X1_Sexual_abuse_case_and_the_alleged__c',false);
        initwrap.x2options =  Utility.getPicklistinfo('Assessment__c','X2_Non_accidental_injury_to_a_child__c',false);
        initwrap.x3options =  Utility.getPicklistinfo('Assessment__c','X3_Severe_non_accidental_injury__c',false);
        initwrap.x4options =  Utility.getPicklistinfo('Assessment__c','X4_Caregiver_action_or_inaction_resulted__c',false);
        initwrap.x5options =  Utility.getPicklistinfo('Assessment__c','X5_If_yes_override_risk_level__c',false);
        initwrap.finalriskleveloptions =  Utility.getPicklistinfo('Assessment__c','FINAL_RISK_LEVEL__c',false);
        initwrap.plannedActionOptions =  Utility.getPicklistinfo('Assessment__c','PLANNED_ACTION__c',false);
        initwrap.approvalOptions =  Utility.getPicklistinfo('Assessment__c','Submit_for_Approval__c',false);
        initwrap.routeToSupervisorOptions =  Utility.getPicklistinfo('Assessment__c','Route_to_Supervisor__c',false);
        if(String.isNotBlank(recordId) && String.isNotBlank(objectApiName)) {
            
            if(objectApiName == 'Service_Case__c') {
                FieldLevelSecurity.checkFieldAccessByCriteria('Head_of_Household__c, Name','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
                initWrap.serviceCaseRec = [SELECT Id, Head_of_Household__r.Name, Name FROM Service_Case__c WHERE Id = :recordId  LIMIT :Utility.queryLimit];
            } else if(objectApiName == 'Investigation__c') {
                FieldLevelSecurity.checkFieldAccessByCriteria('Head_of_Household__c, Name','view','Investigation__c', Boolean.valueOf(Label.HasNamespace));
                initWrap.investigationRec = [SELECT Id, Head_of_Household__r.Name, Name FROM Investigation__c WHERE Id = :recordId  LIMIT :Utility.queryLimit];
            }
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,FRRE_Date_Assessment_Initiated__c, Household_previously_received_CPS__c, RR1_Score__c, Prior_CPS_response_IR_AR__c, RR2_Score__c, Primary_caregiver_has_a_history_of_abuse__c, RR3_Score__c,'+
                                                          'Characteristics_of_children_household__c, RR4_Score__c, New_CPS_response_of_abuse_or_neglect__c, RR5_Score__c, Primary_caregiver_alcohol_or_substance__c, RR6_Score__c, Adult_relationships_since_the_MFIRA__c, Yes_problems_with_adult_r__c, RR7_Score__c,'+
                                                          'Primary_caregiver_mental_health__c, RR8_Score__c, Primary_caregiver_provides_physical_care__c, RR9_Score__c, Demonstrate_Primary_Caregiver__c, Does_not_Demonstrate_Primary_Caregiver__c, Demonstarte_SecondaryCaregiver__c, Does_not_Demonstarte_Secondary_Caregiver__c,'+
                                                          'No_Secondary_Caregiver__c, RR10_Score__c, Does_not_demonstrate_Score__c, No_Secondary_Score__c, Total_Score__c, RISK_LEVEL__c, X1_Sexual_abuse_case_and_the_alleged__c, X2_Non_accidental_injury_to_a_child__c, X3_Severe_non_accidental_injury__c, X4_Caregiver_action_or_inaction_resulted__c,'+
                                                          'X5_If_yes_override_risk_level__c, FINAL_RISK_LEVEL__c, FIRA_Discretionary_override_reason__c, PLANNED_ACTION__c, Case_Worker_Name__c, Submit_for_Approval__c, Date__c, Route_to_Supervisor__c, Caseworker_comments__c, Supervisor_Name__c, Approval_Status__c','view','Assessment__c', Boolean.valueOf(Label.HasNamespace));
            initWrap.familyRiskReassessmentRec = [SELECT Id,Name,FRRE_Date_Assessment_Initiated__c, Household_previously_received_CPS__c, RR1_Score__c, Prior_CPS_response_IR_AR__c, RR2_Score__c, Primary_caregiver_has_a_history_of_abuse__c, RR3_Score__c,
                                                  Characteristics_of_children_household__c, RR4_Score__c, New_CPS_response_of_abuse_or_neglect__c, RR5_Score__c, Primary_caregiver_alcohol_or_substance__c, RR6_Score__c, Adult_relationships_since_the_MFIRA__c, Yes_problems_with_adult_r__c, RR7_Score__c,
                                                  Primary_caregiver_mental_health__c, RR8_Score__c, Primary_caregiver_provides_physical_care__c, RR9_Score__c, Demonstrate_Primary_Caregiver__c, Does_not_Demonstrate_Primary_Caregiver__c, Demonstarte_SecondaryCaregiver__c, Does_not_Demonstarte_Secondary_Caregiver__c,
                                                  No_Secondary_Caregiver__c, RR10_Score__c, Does_not_demonstrate_Score__c, No_Secondary_Score__c, Total_Score__c, RISK_LEVEL__c, X1_Sexual_abuse_case_and_the_alleged__c, X2_Non_accidental_injury_to_a_child__c, X3_Severe_non_accidental_injury__c, X4_Caregiver_action_or_inaction_resulted__c,
                                                  X5_If_yes_override_risk_level__c, FINAL_RISK_LEVEL__c, FIRA_Discretionary_override_reason__c, PLANNED_ACTION__c, Case_Worker_Name__c, Submit_for_Approval__c, Date__c, Route_to_Supervisor__c, Caseworker_comments__c, Supervisor_Name__c, Approval_Status__c FROM Assessment__c 
                                                  WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) AND Assessment_Type__c = 'Family risk Reassessment'  LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Age__c, Date_of_Birth__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
            initWrap.conactList = [SELECT Id, Name, Age__c, Date_of_Birth__c FROM Contact WHERE Service_Case__c = :recordId OR Investigation__c = :recordId LIMIT :Utility.queryLimit];
        } 
        return JSON.serialize(initWrap);           
    }
    
    @AuraEnabled
    public static String upsertfamilyRiskReassessment(String familyRiskReassessmentJSON){
        
        if(String.isNotBlank(familyRiskReassessmentJSON)) {
        
            Assessment__c  familyRiskReassessmentRec = (Assessment__c)JSON.deserialize(familyRiskReassessmentJSON, Assessment__c.class);
            if(String.isNotBlank(familyRiskReassessmentRec.FIRA_Case_worker_Signature__c)) {
                familyRiskReassessmentRec.FIRA_Case_worker_Signature__c = familyRiskReassessmentRec.FIRA_Case_worker_Signature__c;
            }
            if(String.isNotBlank(familyRiskReassessmentRec.Supervisor_Signature__c)) {
                familyRiskReassessmentRec.Supervisor_Signature__c = familyRiskReassessmentRec.Supervisor_Signature__c;
            }
            if (String.isBlank(familyRiskReassessmentRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Signature__c, FIRA_Case_worker_Signature__c, FRRE_Date_Assessment_Initiated__c', 'create', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
                familyRiskReassessmentRec.FRRE_Date_Assessment_Initiated__c = System.now();
                insert familyRiskReassessmentRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Signature__c, FIRA_Case_worker_Signature__c, FRRE_Date_Assessment_Initiated__c', 'update', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
                
                update familyRiskReassessmentRec;
            }
            return familyRiskReassessmentRec.Id;
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String upsertfamilyApprovalSign(String familyRiskReassessmentJSON, String parent1Signature, String parent2Signature){
        
        if(String.isNotBlank(familyRiskReassessmentJSON)) {
            Assessment__c  familyRiskReassessmentRec = (Assessment__c)JSON.deserialize(familyRiskReassessmentJSON, Assessment__c.class);
            if(String.isNotBlank(parent1Signature)) {
                familyRiskReassessmentRec.FIRA_Case_worker_Signature__c = parent1Signature;
            }
            if(String.isNotBlank(parent2Signature)) {
                familyRiskReassessmentRec.Supervisor_Signature__c = parent2Signature;
            }
            if (String.isBlank(familyRiskReassessmentRec.Id)) {
                familyRiskReassessmentRec.FRRE_Date_Assessment_Initiated__c = System.now();
                FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Signature__c, FIRA_Case_worker_Signature__c, FRRE_Date_Assessment_Initiated__c', 'create', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
                insert familyRiskReassessmentRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Signature__c, FIRA_Case_worker_Signature__c, FRRE_Date_Assessment_Initiated__c', 'update', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));               
                update familyRiskReassessmentRec;
            }
            return familyRiskReassessmentRec.Id;
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String getFamilyInitialRiskAssessmentStagePicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.stages = Utility.getPicklistinfo('Assessment__c','FamilyInitialRiskAssessmentStage__c',false);
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static String getFamilyInitialRiskAssessmentStageInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if(String.isNotBlank(recordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Department_is_unable_to_locate_child__c, FamilyInitialRiskAssessmentStage__c, FRRE_Date_Assessment_Initiated__c, Actions_Taken__c, Approval_Status__c, Name', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.familyRiskReassessmentRec = [SELECT Id,Name, FRRE_Date_Assessment_Initiated__c,FamilyInitialRiskAssessmentStage__c, Department_is_unable_to_locate_child__c, Actions_Taken__c, Approval_Status__c FROM Assessment__c 
                                                  WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) AND Assessment_Type__c = 'Family Initial Risk Assessment'  LIMIT :Utility.queryLimit];
        } 
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static String getFamilyAndHouseholdCompositionInfo(String serviceCaseId,String assesmentRecId, String objectApiName){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if(assesmentRecId == 'empty') {
            initWrap.assessmentRec = new Assessment__c();
        } else if(assesmentRecId != 'empty' && String.isNotBlank(assesmentRecId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c, Investigation__c,FRRE_Date_Assessment_Initiated__c, Approval_Status__c', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.assessmentRec = [SELECT Id,Service_Case__c,Investigation__c, FRRE_Date_Assessment_Initiated__c, Approval_Status__c FROM Assessment__c WHERE Id = :assesmentRecId  LIMIT :Utility.queryLimit];
        }
        if(String.isNotBlank(serviceCaseId) && String.isNotBlank(objectApiName)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Age__c, Date_of_Birth__c, Intake_Person_Role__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            //FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Head_of_Household__c',  Boolean.valueOf(Label.HasNamespace));
            if(objectApiName == 'Service_Case__c') {
                FieldLevelSecurity.checkFieldAccessByCriteria('Head_of_Household__c, Name', 'view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
                initWrap.serviceCaseRec = [SELECT Id, Head_of_Household__r.Name, Name FROM Service_Case__c WHERE Id = :serviceCaseId  LIMIT :Utility.queryLimit];
            } else if(objectApiName == 'Investigation__c') {
                FieldLevelSecurity.checkFieldAccessByCriteria('Head_of_Household__c, Name', 'view', 'Investigation__c',  Boolean.valueOf(Label.HasNamespace));
                initWrap.investigationRec = [SELECT Id, Head_of_Household__r.Name, Name FROM Investigation__c WHERE Id = :serviceCaseId  LIMIT :Utility.queryLimit];
            }
            initWrap.conactList = [SELECT Id, Name, Age__c, Date_of_Birth__c, Intake_Person_Role__c FROM Contact WHERE Service_Case__c = :serviceCaseId OR Investigation__c = :serviceCaseId  LIMIT :Utility.queryLimit];  
        }
        
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static string getNeglectedAbuseIndexPicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.option1 = Utility.getPicklistinfo('Assessment__c','FIRA_Current_Report_is_for__c',false);
        initWrap.option2 = Utility.getPicklistinfo('Assessment__c','FIRA_Prior_CPS_Response__c',false);
        initWrap.options2a = Utility.getPicklistinfo('Assessment__c','FIRA_Prior_Neglect__c',false);
        initWrap.options2b = Utility.getPicklistinfo('Assessment__c','FIRA_Prior_Abuse__c',false);
        initWrap.options3 = Utility.getPicklistinfo('Assessment__c','FIRA_Household_previously_had_open_IHFS__c',false);
        initWrap.options4 = Utility.getPicklistinfo('Assessment__c','FIRA_Number_of_children_identified__c',false);
        initWrap.options5 = Utility.getPicklistinfo('Assessment__c','FIRA_Prior_non_accidential_injury__c',false);
        initWrap.options6 = Utility.getPicklistinfo('Assessment__c','FIRA_Age_of_youngest_child__c',false);
        initWrap.options7 = Utility.getPicklistinfo('Assessment__c','FIRA_racterisitics_of_children__c',true);
        initWrap.options8 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_assessment__c',true);
        initWrap.options9 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_provides_physical__c',false);
        initWrap.options10 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_characteristics__c',true);
        initWrap.options11 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_has_past_mental__c',false);
        initWrap.options12 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_past_alcohol__c',false);
        initWrap.options13 = Utility.getPicklistinfo('Assessment__c','FIRA_Secondary_Caregiver_has_alcohol__c',false);
        initWrap.options14 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_has_history__c',false);
        initWrap.options15 = Utility.getPicklistinfo('Assessment__c','FIRA_Two_or_more_incidents__c',false);
        initWrap.options16 = Utility.getPicklistinfo('Assessment__c','FIRA_Housing__c',true);
        initWrap.optionsAlcohol = Utility.getPicklistinfo('Assessment__c','FIRA_Alcohol_values__c',false);
        initWrap.optionsDrugs = Utility.getPicklistinfo('Assessment__c','Drugs_value__c',false);
        initWrap.options11y = Utility.getPicklistinfo('Assessment__c','Primary_caregiver_has_past_Yes__c',false);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static string getNeglectedAbuseIndexInfo(String recordId){    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if(String.isNotBlank(recordId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('FIRA_Current_Report_is_for__c, FIRA_Current_Report_Neglect_Score__c, FIRA_Current_Report_Abuse_Score__c, FIRA_Prior_CPS_Response__c, FIRA_Prior_CPS_Neglect_Score__c,' 
                                                          +'FIRA_Prior_Neglect__c, FIRA_Prior_Neglect_Score__c, FIRA_Prior_Abuse__c, FIRA_Prior_Abuse_Score__c, FIRA_Household_previously_had_open_IHFS__c, FIRA_Household_previously_Neglect_Score__c,'
                                                          +'FIRA_Household_previously_Abuse_Score__c,FIRA_Number_of_children_identified__c,'
                                                          +'FIRA_Number_of_children_neglect_score__c, FIRA_Number_of_children_Abuse_Score__c, FIRA_Prior_non_accidential_injury__c, FIRA_Prior_non_accidential_neglect_score__c,'
                                                          +'FIRA_Prior_non_accidential_Abuse_Score__c, FIRA_Age_of_youngest_child__c, FIRA_Age_of_youngest_child_neglect_score__c,'
                                                          +'FIRA_Age_of_youngest_child_Abuse_score__c, FIRA_racterisitics_of_children__c, FIRA_Characteristic_child_neglect_score__c, FIRA_Characteristic_child_Abuse_Score__c,'
                                                          +'FIRA_Primary_caregiver_assessment__c, FIRA_Primary_caregiver_neglect_score__c, FIRA_Primary_caregiver_abuse_score__c,'
                                                          +'FIRA_Primary_caregiver_provides_physical__c, FIRA_Primary_caregiver_provides_neglect__c, FIRA_Primary_caregiver_provides_abuse__c, FIRA_Primary_caregiver_characteristics__c,'
                                                          +'FIRA_Primary_caregiver_charac_neglect__c, FIRA_Primary_caregiver_charac_Abuse__c,FIRA_Prior_CPS_Abuse_Score__c,'
                                                          +'FIRA_Primary_caregiver_has_past_mental__c, FIRA_Primary_caregive_has_mental_neglect__c, FIRA_Primary_caregive_has_mental_abuse__c, FIRA_Primary_caregiver_past_alcohol__c,'
                                                          +'FIRA_Primary_caregiver_alcohol_neglect__c, FIRA_Primary_caregiver_alcohol_abuse__c, FIRA_Secondary_Caregiver_has_alcohol__c,'
                                                          +'FIRA_Secondary_care_has_alcohol_neglect__c, FIRA_Secondary_care_has_alcohol_abuse__c, FIRA_Primary_caregiver_has_history_abuse__c, FIRA_Primary_caregiv_has_history_neglect__c,'
                                                          +'FIRA_Primary_caregiver_has_history__c, FIRA_Two_or_more_incidents__c, FIRA_Two_or_more_incidents_neglect__c, FIRA_Two_or_more_incidents_Abuse__c,'
                                                          +'FIRA_Housing__c,Primary_caregiver_has_past_Yes__c, FIRA_Housing_Neglect_Score__c, Housing_Abuse_Score__c, Total_Neglect_Score__c, Total_Abuse_Score__c, FIRA_Alcohol_Select_one__c,'
                                                          +'FIRA_Alcohol_values__c, FIRA_Drugs_Select_One__c, Drugs_value__c, Alcohol_Select_one__c, FIRA_Secondary_Alcohol_values__c, FIRA_Secondary_Drugs_Select_One__c,'
                                                          +'FIRA_Secondary_Drugs_value__c, Approval_Status__c', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.assessmentRec = [SELECT Id, FIRA_Current_Report_is_for__c, FIRA_Current_Report_Neglect_Score__c, FIRA_Current_Report_Abuse_Score__c, FIRA_Prior_CPS_Response__c, FIRA_Prior_CPS_Neglect_Score__c, FIRA_Prior_CPS_Abuse_Score__c,
                                      FIRA_Prior_Neglect__c, FIRA_Prior_Neglect_Score__c, FIRA_Prior_Abuse__c, FIRA_Prior_Abuse_Score__c, FIRA_Household_previously_had_open_IHFS__c, FIRA_Household_previously_Neglect_Score__c, FIRA_Household_previously_Abuse_Score__c,FIRA_Number_of_children_identified__c,
                                      FIRA_Number_of_children_neglect_score__c, FIRA_Number_of_children_Abuse_Score__c, FIRA_Prior_non_accidential_injury__c, FIRA_Prior_non_accidential_neglect_score__c, FIRA_Prior_non_accidential_Abuse_Score__c, FIRA_Age_of_youngest_child__c, FIRA_Age_of_youngest_child_neglect_score__c,
                                      FIRA_Age_of_youngest_child_Abuse_score__c, FIRA_racterisitics_of_children__c, FIRA_Characteristic_child_neglect_score__c, FIRA_Characteristic_child_Abuse_Score__c, FIRA_Primary_caregiver_assessment__c, FIRA_Primary_caregiver_neglect_score__c, FIRA_Primary_caregiver_abuse_score__c,
                                      FIRA_Primary_caregiver_provides_physical__c, FIRA_Primary_caregiver_provides_neglect__c, FIRA_Primary_caregiver_provides_abuse__c, FIRA_Primary_caregiver_characteristics__c, FIRA_Primary_caregiver_charac_neglect__c, FIRA_Primary_caregiver_charac_Abuse__c, 
                                      FIRA_Primary_caregiver_has_past_mental__c, FIRA_Primary_caregive_has_mental_neglect__c, FIRA_Primary_caregive_has_mental_abuse__c, FIRA_Primary_caregiver_past_alcohol__c, FIRA_Primary_caregiver_alcohol_neglect__c, FIRA_Primary_caregiver_alcohol_abuse__c, FIRA_Secondary_Caregiver_has_alcohol__c,
                                      FIRA_Secondary_care_has_alcohol_neglect__c, FIRA_Secondary_care_has_alcohol_abuse__c, FIRA_Primary_caregiver_has_history_abuse__c, FIRA_Primary_caregiv_has_history_neglect__c, FIRA_Primary_caregiver_has_history__c, FIRA_Two_or_more_incidents__c, FIRA_Two_or_more_incidents_neglect__c, FIRA_Two_or_more_incidents_Abuse__c,
                                      FIRA_Housing__c,Primary_caregiver_has_past_Yes__c, FIRA_Housing_Neglect_Score__c, Housing_Abuse_Score__c, Total_Neglect_Score__c, Total_Abuse_Score__c, FIRA_Alcohol_Select_one__c, FIRA_Alcohol_values__c, FIRA_Drugs_Select_One__c, Drugs_value__c, Alcohol_Select_one__c, FIRA_Secondary_Alcohol_values__c, FIRA_Secondary_Drugs_Select_One__c, FIRA_Secondary_Drugs_value__c, Approval_Status__c
                                      FROM Assessment__c WHERE Id = :recordId  LIMIT :Utility.queryLimit];
        }
        
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static string getScoringOverridesPicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.x1options =  Utility.getPicklistinfo('Assessment__c','X1_Sexual_abuse_case_and_the_alleged__c',false);
        initwrap.x2options =  Utility.getPicklistinfo('Assessment__c','X2_Non_accidental_injury_to_a_child__c',false);
        initwrap.x3options =  Utility.getPicklistinfo('Assessment__c','X3_Severe_non_accidental_injury__c',false);
        initwrap.x4options =  Utility.getPicklistinfo('Assessment__c','X4_Caregiver_action_or_inaction_resulted__c',false);
        initwrap.x5options =  Utility.getPicklistinfo('Assessment__c','X5_If_yes_override_risk_level__c',false);
        initwrap.finalriskleveloptions =  Utility.getPicklistinfo('Assessment__c','FINAL_RISK_LEVEL__c',false);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getScoringOverridesInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if(String.isNotBlank(recordId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('X1_Sexual_abuse_case_and_the_alleged__c, X2_Non_accidental_injury_to_a_child__c, X3_Severe_non_accidental_injury__c, X4_Caregiver_action_or_inaction_resulted__c,'
                                      +'X5_If_yes_override_risk_level__c, FINAL_RISK_LEVEL__c, FIRA_Discretionary_override_reason__c, Approval_Status__c', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));

            initWrap.assessmentRec = [SELECT Id, X1_Sexual_abuse_case_and_the_alleged__c, X2_Non_accidental_injury_to_a_child__c, X3_Severe_non_accidental_injury__c, X4_Caregiver_action_or_inaction_resulted__c,
                                      X5_If_yes_override_risk_level__c, FINAL_RISK_LEVEL__c, FIRA_Discretionary_override_reason__c, Approval_Status__c FROM Assessment__c  WHERE Id = :recordId  LIMIT :Utility.queryLimit];
        }
        
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static string getSupplementalQuestionPicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.optionS1 =  Utility.getPicklistinfo('Assessment__c','FIRA_Does_either_caregiver_have_history__c',false);
        initwrap.primaryOptions =  Utility.getPicklistinfo('Assessment__c','FIRA_Primary__c',true);
        initwrap.secondaryOptions =  Utility.getPicklistinfo('Assessment__c','FIRA_Secondary__c',true);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getSupplementalQuestionInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if(String.isNotBlank(recordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('FIRA_Does_either_caregiver_have_history__c, FIRA_Primary__c, FIRA_Secondary__c,Approval_Status__c', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.assessmentRec = [SELECT Id, FIRA_Does_either_caregiver_have_history__c, FIRA_Primary__c, FIRA_Secondary__c,Approval_Status__c FROM Assessment__c WHERE Id = :recordId  LIMIT :Utility.queryLimit];
        }
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static string getFIRAApprovalPicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.rerouteSupervisorOptions =  Utility.getPicklistinfo('Assessment__c','Route_to_Supervisor__c',false);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getFIRAApprovalInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if(String.isNotBlank(recordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Name__c, Route_to_Supervisor__c, Supervisor_Comments__c, FIRA_Supervisor_Reviewed_Date__c, Case_Worker_Name__c,Caseworker_comments__c,Approval_Status__c,FIRA_Case_worker_Signature__c,Supervisor_Signature__c', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.assessmentRec = [SELECT Id, Supervisor_Name__c, Route_to_Supervisor__c, Supervisor_Comments__c, FIRA_Supervisor_Reviewed_Date__c, Case_Worker_Name__c,Caseworker_comments__c,Approval_Status__c,FIRA_Case_worker_Signature__c,Supervisor_Signature__c
                                      FROM Assessment__c WHERE Id = :recordId  LIMIT :Utility.queryLimit];
        }
        
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static String getActionInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if(recordId != 'empty' && String.isNotBlank(recordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Actions_Taken__c, Department_is_unable_to_locate_child__c, Approval_Status__c', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.assessmentRec = [SELECT Id, Actions_Taken__c, Department_is_unable_to_locate_child__c, Approval_Status__c FROM Assessment__c WHERE  Id = :recordId  LIMIT :Utility.queryLimit];
            
        } else  {
            initWrap.assessmentRec = new Assessment__c();
        }  
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String deleteAssessment(String recordId){
        
        if(String.isNotBlank(recordId)) {
            
            FieldLevelSecurity.checkObjectAccessByDelete('Assessment__c');
            Assessment__c assesmentRec = new Assessment__c();
            assesmentRec.Id = recordId;
            delete assesmentRec;
            return 'Success';
        } else {
            return null;
        }
    }
    
    public Assessment__c assessmentRecord { get; set; }
    public List<Assessment_Safety_Plan__c> safetyListRecords { get; set; }
    public List<Contact> contactRecords{ get; set; }
    public String currentRecordId {get; set;}
    public String safetyListComments {get; set;}
    public String comment1{get; set;}
    public String comment2{get; set;}
    public String comment3{get; set;}
    public String comment4{get; set;}
    public String comment5{get; set;}
    public String comment6{get; set;}
    public String comment7{get; set;}
    public String comment8{get; set;}
    public String comment9{get; set;}
    public String comment10{get; set;}
    public String comment11{get; set;}
    public String comment12{get; set;}
    public String comment13{get; set;}
    public String comment14{get; set;}
    public String comment15{get; set;}
    public String comment16{get; set;}
    public String comment17{get; set;}
    public String comment18{get; set;}
    
    public AssessmentController() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        AssessmentController.GetInitialWrapper result = (AssessmentController.GetInitialWrapper)JSON.deserialize(getAssessment(currentRecordId),AssessmentController.GetInitialWrapper.class);
        assessmentRecord = result.assessmentRec;
        safetyListRecords = result.assessmentSafetyPlanList;
        AssessmentController.GetInitialWrapper contactResult = (AssessmentController.GetInitialWrapper)JSON.deserialize(getSAFECInitialInformation(result.assessmentRec.Service_Case__c),AssessmentController.GetInitialWrapper.class);
        contactRecords = contactResult.childList;
        safetyListComments = safetyListRecords.size() > 0 ? ' ' : 'No existing records found';
        comment1 = result.assessmentRec.SAFEC_Caregiver_fails_to_protect__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_fails_Comments__c : '' ;
        comment2 = result.assessmentRec.SAFEC_Caregiver_made_a_plausible_threat__c =='yes'? 'Comments : '+ result.assessmentRec.SAFEC_Caregiver_made_a_Comments__c : '' ;
        comment3 = result.assessmentRec.SAFEC_There_has_been_current_act__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_There_has_been_current_actComments__c : '' ;
        comment4 = result.assessmentRec.SAFEC_Child_sexual_abuse_is_suspected__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Child_sexual_abuse_Comments__c : '' ;
        comment5 = result.assessmentRec.SAFEC_Caregiver_describes_the_child__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_describes_Comments__c : '' ;
        comment6 = result.assessmentRec.SAFEC_Cargiver_s_suspected_or_observed__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Cargiver_s_suspected_Comments__c : '' ;
        comment7 = result.assessmentRec.SAFEC_Caregiver_s_emotional_instability__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_s_emotional_Comments__c : '' ;
        comment8 = result.assessmentRec.SAFEC_Caregiver_s_explanation__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_s_explanation_Comments__c : '' ;
        comment10 = result.assessmentRec.SAFEC_Caregiver_does_not_or_refuse__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_does_not_Comments__c : '' ;
        comment9 =  result.assessmentRec.SAFEC_Caregivers_justification_or_denial__c =='yes'?'Comments : '+result.assessmentRec.SAFEC_Caregivers_justification_Comments__c : '';
        comment11 = result.assessmentRec.SAFEC_Domestic_violence_exists__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Domestic_violence_Comments__c : '' ;
        comment12 = result.assessmentRec.SAFEC_Caregiver_does_not_meet_the_childs__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_does_not_meet_Comments__c : '' ;
        comment13 = result.assessmentRec.SAFEC_The_childs_whereabouts_are_unknown__c =='yes'?'Comments : '+ result.assessmentRec.SAFEC_The_childs_whereabouts_Comments__c : '' ;
        comment14 = result.assessmentRec.SAFEC_The_child_has_special_needs__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_The_child_has_special_Comments__c : '' ;
        comment15 = result.assessmentRec.SAFEC_The_child_is_extremely_anxious__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_The_child_is_extremely_Comments__c : '' ;
        comment16 = result.assessmentRec.SAFEC_The_child_is_unable_to_protect__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_The_child_is_unable_Comments__c : '' ;
        comment17 = result.assessmentRec.SAFEC_Previous_services_to_the_caregiver__c =='yes'?'Comments : '+ result.assessmentRec.SAFEC_Previous_services_Comments__c : '' ;
        comment18 = result.assessmentRec.SAFEC_There_have_been_multiple_reports__c =='yes'?'Comments : '+ result.assessmentRec.SAFEC_There_have_been_multiple_Comments__c : '' ;
        
        
    }
    
    
    public class GetInitialWrapper {
        
        @AuraEnabled
        public List<Utility.pickListWrap> thechildsImmediatehealthneedsPicklist;
        @AuraEnabled
        public List<contact> conactList;
        @AuraEnabled
        public List<contact> caregiverList;
        @AuraEnabled
        public List<Utility.pickListWrap> cotactsNames;
        @AuraEnabled
        public List<Utility.pickListWrap> caregiverNames;
        @AuraEnabled
        public List<Utility.pickListWrap> caregiverDescribesTheChildPicklist;
        @AuraEnabled
        public List<contact> childList;
        @AuraEnabled
        public List<contact> headOfHouseHoldList;
        @AuraEnabled
        public List<ChildInputWarp> childInputWarpList;
        @AuraEnabled
        public List<Utility.pickListWrap> submitforApprovalPickList;
        @AuraEnabled
        public List<safecWarp> assessmentList;
        @AuraEnabled
        public List<Assessment__c> assessmentOHPList;
        @AuraEnabled
        public List<Assessment_Safety_Plan__c> assessmentSafetyPlanList;
        @AuraEnabled
        public Assessment__c assessmentRec; 
        @AuraEnabled
        public String cpsCaseName;
        @AuraEnabled
        public String headofHouseholdName;
        @AuraEnabled
        public Assessment__c assessmentOHPRec;
        @AuraEnabled
        public Service_Case__c statusService;
        @AuraEnabled
        public List<Utility.pickListWrap> RR1options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR2options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR3options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR4options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR5options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR6options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR7options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR7Yesoptions;
        @AuraEnabled
        public List<Utility.pickListWrap> RR8options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR9options;
        @AuraEnabled
        public List<Utility.pickListWrap> riskLevelOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> x1options;
        @AuraEnabled
        public List<Utility.pickListWrap> x2options;
        @AuraEnabled
        public List<Utility.pickListWrap> x3options;
        @AuraEnabled
        public List<Utility.pickListWrap> x4options;
        @AuraEnabled
        public List<Utility.pickListWrap> x5options;
        @AuraEnabled
        public List<Utility.pickListWrap> finalriskleveloptions;
        @AuraEnabled
        public List<Utility.pickListWrap> plannedActionOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> approvalOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> routeToSupervisorOptions;
        @AuraEnabled
        public Service_Case__c serviceCaseRec;
        @AuraEnabled
        public Investigation__c investigationRec;
        @AuraEnabled
        public List<Assessment__c> familyRiskReassessmentRec;
        @AuraEnabled
        public List<Utility.pickListWrap> stages;
        @AuraEnabled
        public List<Utility.pickListWrap> option1;
        @AuraEnabled
        public List<Utility.pickListWrap> option2;
        @AuraEnabled
        public List<Utility.pickListWrap> options2a;
        @AuraEnabled
        public List<Utility.pickListWrap> options2b;
        @AuraEnabled
        public List<Utility.pickListWrap> options3;
        @AuraEnabled
        public List<Utility.pickListWrap> options4;
        @AuraEnabled
        public List<Utility.pickListWrap> options5;
        @AuraEnabled
        public List<Utility.pickListWrap> options6;
        @AuraEnabled
        public List<Utility.pickListWrap> options7;
        @AuraEnabled
        public List<Utility.pickListWrap> options8;
        @AuraEnabled
        public List<Utility.pickListWrap> options9;
        @AuraEnabled
        public List<Utility.pickListWrap> options10;
        @AuraEnabled
        public List<Utility.pickListWrap> options11;
        @AuraEnabled
        public List<Utility.pickListWrap> options12;
        @AuraEnabled
        public List<Utility.pickListWrap> options13;
        @AuraEnabled
        public List<Utility.pickListWrap> options14;
        @AuraEnabled
        public List<Utility.pickListWrap> options15;
        @AuraEnabled
        public List<Utility.pickListWrap> options16;
        @AuraEnabled
        public List<Utility.pickListWrap> optionS1;
        @AuraEnabled
        public List<Utility.pickListWrap> primaryOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> secondaryOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> rerouteSupervisorOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> optionsAlcohol;
        @AuraEnabled
        public List<Utility.pickListWrap> optionsDrugs;
        @AuraEnabled
        public List<Utility.pickListWrap> options11y;
        
        
        public GetInitialWrapper() {
            
            thechildsImmediatehealthneedsPicklist = new List<Utility.pickListWrap>();
            cotactsNames = new List<Utility.pickListWrap>();
            caregiverNames = new List<Utility.pickListWrap>();
            caregiverDescribesTheChildPicklist = new List<Utility.pickListWrap>();
            submitforApprovalPickList = new List<Utility.pickListWrap>();
            
        }
    }
    public class ChildInputWarp {
        
        @AuraEnabled
        public String chidName;
        @AuraEnabled
        public Decimal age;
        @AuraEnabled
        public String childId;
        @AuraEnabled
        public String clientId;
    }
    
    public class safecWarp {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String completionDate;
        @AuraEnabled
        public String approvalStatus;
    }
}