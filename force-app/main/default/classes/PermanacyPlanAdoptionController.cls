public with sharing class PermanacyPlanAdoptionController {

    @AuraEnabled
    public static String getAdoptionInitialInfos(String permanencyPlanId) {
    
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        adoptionWrap.adoptionPlanPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Adoption_Planning__c',false);
        if (String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Contact__c,Placement__c,Service_Case__c,Adoption_Planning__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Date_of_Birth__c,Gender__c', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.permanencyPlanRec = [SELECT Id, Placement__c, Service_Case__c, Contact__r.Name, Contact__r.Date_of_Birth__c, Contact__r.Gender__c, Adoption_Planning__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Child_Name__c', 'view', 'Legal_Custody__c', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.legalCustody = [SELECT Id, Child_Name__c  FROM Legal_Custody__c WHERE Legal_Custody__c = 'Guardianship to DSS' AND Child_Name__r.Service_Case__c = :adoptionWrap.permanencyPlanRec.Service_Case__c LIMIT :Utility.queryLimit];
            
            adoptionWrap.placementRec = [SELECT Id FROM Placement__c WHERE Id = :adoptionWrap.permanencyPlanRec.Placement__c AND Placement_Structure__c = 'Pre-Finalized Adoptive Home' LIMIT :Utility.queryLimit];              
        	
            adoptionWrap.tpRList = [SELECT Id FROM TPR__c WHERE Permanency_Plan__c = :permanencyPlanId LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Rate_Approval_Status__c', 'view', 'Subsidy_Rate__c', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.subSidyRecList = [SELECT Id,Rate_Approval_Status__c FROM Subsidy_Rate__c WHERE Permanency_Plan__c =:permanencyPlanId LIMIT :Utility.queryLimit];
        }
        return JSON.serialize(adoptionWrap);
    }
    
    @AuraEnabled(cacheable=true)
    public static String getTPRRecommendationInitialInfos(String permanencyPlanId) {
        FieldLevelSecurity.checkFieldAccessByCriteria('Reason_for_Recommendation__c','view','Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        
        adoptionWrap.reasonForRecommendationPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Reason_for_Recommendation__c',false);
        if (String.isNotBlank(permanencyPlanId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Contact__c, Child_in_care_15_out_of_last_22_months__c, Court_hearing_occurs__c, Information_for_either_parent_is_unknown__c, Reason_for_Recommendation__c,'+
                                                          'Court_order_of_TPR_for_parents__c, Petition_for_TPR_sent_to_court__c, Primary_Permanacy_Plan_is_adoption__c','view','Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            
            adoptionWrap.permanencyPlanRec = [SELECT Id, Contact__c, Child_in_care_15_out_of_last_22_months__c, Court_hearing_occurs__c, Information_for_either_parent_is_unknown__c, Reason_for_Recommendation__c,
                                              Court_order_of_TPR_for_parents__c, Petition_for_TPR_sent_to_court__c, Primary_Permanacy_Plan_is_adoption__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Court__c', 'view', 'Court_Petition_Hearing__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Type_of_Petition__c, Scheduled_Hearing_Type__c, Hearing_Outcome__c,Petition_for_Child__c ', 'view', 'Court__c', Boolean.valueOf(Label.HasNamespace));
            
            adoptionWrap.courtHearingRec = [SELECT Id FROM Court_Petition_Hearing__c WHERE (Court__r.Type_of_Petition__c = 'TPR' OR Court__r.Type_of_Petition__c = 'Adoption')  AND
                                            Scheduled_Hearing_Type__c INCLUDES ('Adoption;TPR/Guardianship- Contested') AND Court__r.Hearing_Outcome__c INCLUDES('Adoption Granted','TPR Granted') 
                                            AND Court__r.Petition_for_Child__c = :adoptionWrap.permanencyPlanRec.Contact__c LIMIT :Utility.queryLimit];
        }
        
        return JSON.serialize(adoptionWrap);    
    }
    
    @AuraEnabled
    public static String getAdoptionPlanningStageInitialInfos(String permanencyPlanId) {
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        adoptionWrap.adoptionPlanningStagePicklist = Utility.getPicklistinfo('Permanency_Plan__c','Adoption_Planning_Stage__c',false);
        adoptionWrap.hasTheChildBeenInCarePicklist = Utility.getPicklistinfo('Permanency_Plan__c','Has_the_child_been_in_care__c',false);
        adoptionWrap.checkTheAgeOfChildTheChildPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Check_the_age_of_the_child__c',false);
        adoptionWrap.specialNeedsPicklist = Utility.getPicklistinfo('Permanency_Plan__c','One_of_following_special_needs_factors__c', false);
       
        FieldLevelSecurity.checkFieldAccessByCriteria('Adoption_Planning_Stage__c, Has_the_child_been_in_care__c, Check_the_age_of_the_child__c, One_of_following_special_needs_factors__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
        if (String.isNotBlank(permanencyPlanId)) {
           adoptionWrap.adoptionPlanningStageRec = [SELECT Id, Adoption_Planning_Stage__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit
                                                    ];
            FieldLevelSecurity.checkFieldAccessByCriteria('Child_Birth_Date__c, Federal_Fiscal_Year_Adoption_Date__c, Check_the_age_of_the_child__c, Has_the_child_been_in_care__c, Is_the_child_a_sibling_to_a_child__c,'+
            'An_involuntary_removal_in_accordance__c, Date_of_removal__c, Date_of_first_court_order_CTW__c, A_voluntary_placement_agreement__c,'+
            'Child_Removal_Date_VPA__c, Voluntary_relinquishment__c, Date_of_relinquishment__c, medical_or_disability_requirements__c,'+
            'child_residing_in_a_foster_family_home__c, All_medical_disability_requirements_SSI__c, One_of_following_special_needs_factors__c,'+
            'Reasonable_but_unsuccessful_efforts__c, Reasonable_unsuccessful_effort_comments__c, If_instead_the_child_is_being_adopted_b__c, If_instead_child_being_adopted_comments__c,'+
            'Was_the_child_eligible_for_adoption__c, Document_explanation_in_case_record__c, Previous_Adoptive_Parent_s_TPR__c,'+
            'Previous_Adoptive_Parent_s_Death_date__c, Is_the_child_currently_Title_1V_E_foster__c, Is_the_child_currently_SSI_eligibile__c,Resubmission_Signature__c, Caseworker_Signature__c,'+
            'Applicable_Child_Approval_Status__c, child_be_returned_to_the_home_of_parent__c, Caseworker_Name__c, Caseworker_Date__c, Resubmission_Case_Worker_Name__c, Resubmission_Request_Date__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));

           adoptionWrap.applicableChildAssRec = [SELECT Id, Child_Birth_Date__c, Federal_Fiscal_Year_Adoption_Date__c, Check_the_age_of_the_child__c, Has_the_child_been_in_care__c, Is_the_child_a_sibling_to_a_child__c,
                                                 An_involuntary_removal_in_accordance__c, Date_of_removal__c, Date_of_first_court_order_CTW__c, A_voluntary_placement_agreement__c,
                                                Child_Removal_Date_VPA__c, Voluntary_relinquishment__c, Date_of_relinquishment__c, medical_or_disability_requirements__c,
                                                child_residing_in_a_foster_family_home__c, All_medical_disability_requirements_SSI__c, One_of_following_special_needs_factors__c, 
                                                Reasonable_but_unsuccessful_efforts__c, Reasonable_unsuccessful_effort_comments__c, If_instead_the_child_is_being_adopted_b__c, If_instead_child_being_adopted_comments__c,
                                                Was_the_child_eligible_for_adoption__c, Document_explanation_in_case_record__c, Previous_Adoptive_Parent_s_TPR__c,
                                                Previous_Adoptive_Parent_s_Death_date__c, Is_the_child_currently_Title_1V_E_foster__c, Is_the_child_currently_SSI_eligibile__c,Resubmission_Signature__c, Caseworker_Signature__c,
                                                Applicable_Child_Approval_Status__c, child_be_returned_to_the_home_of_parent__c, Caseworker_Name__c, Caseworker_Date__c, Resubmission_Case_Worker_Name__c, Resubmission_Request_Date__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit                
                                              ];
        }
        return JSON.serialize(adoptionWrap);
    }
    
    @AuraEnabled
    public static String getAdoptionPlanningEmotionalInitialInfos(String permanencyPlanId) {
    
        if (String.isNotBlank(permanencyPlanId)) {
            PermanencyPlanAdoptionWrapper permanencyPlanWrapper = new PermanencyPlanAdoptionWrapper();
            FieldLevelSecurity.checkFieldAccessByCriteria('Child_is_living_with_LDSS_holds_custody__c, Prospective_adoptive_family_committed__c, Notes_for_Emotional_ties__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            permanencyPlanWrapper.permanencyPlanRec = [SELECT Id, Child_is_living_with_LDSS_holds_custody__c, Prospective_adoptive_family_committed__c, Notes_for_Emotional_ties__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId Limit 1];
            return JSON.serialize(permanencyPlanWrapper);
        }
        return null;
    }
    
    @AuraEnabled
    public static String getAdoptionPlanningNarrativeInitialInfos(String permanencyPlanId) {
    
        if (String.isNotBlank(permanencyPlanId)) {
            PermanencyPlanAdoptionWrapper permanencyPlanWrapper = new PermanencyPlanAdoptionWrapper();
            FieldLevelSecurity.checkFieldAccessByCriteria('Adoption_Plan_Begin_Date__c, Notes_for_narrative__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            permanencyPlanWrapper.permanencyPlanRec = [SELECT Id, Adoption_Plan_Begin_Date__c, Notes_for_narrative__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId Limit 1];
            return JSON.serialize(permanencyPlanWrapper);
        }
        return null;
    }
    
    @AuraEnabled
    public static String getTPRInitialInfos(String permanencyPlanId) {
    
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        adoptionWrap.TPRStatusPicklist = Utility.getPicklistinfo('TPR__c','TPR_Status__c',false);
        adoptionWrap.MethodofServicePicklist = Utility.getPicklistinfo('TPR__c','Method_of_Service__c',false);
        adoptionWrap.RelationshipPicklist = Utility.getPicklistinfo('TPR__c','Relationship__c',false);
        adoptionWrap.TerminationPicklist = Utility.getPicklistinfo('TPR__c','Termination__c',false);
        if (String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Intake_Person_Role__c', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('ParentName__c, Permanency_Plan__c, Date_Parent_Served__c, Method_of_Service__c, TPR_Status__c, TPR_Decision_Date__c, Relationship__c,'+
            'Termination__c, Termination_Appealed__c, Reason__c ', 'view', 'TPR__c', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.tpRList = [SELECT Id, ParentName__c, ParentName__r.Name, ParentName__r.Intake_Person_Role__c, Permanency_Plan__c, Permanency_Plan__r.Service_Case__c, Date_Parent_Served__c, Method_of_Service__c, TPR_Status__c, TPR_Decision_Date__c, Relationship__c,
                                    Termination__c, Termination_Appealed__c, Reason__c FROM TPR__c WHERE Permanency_Plan__c = :permanencyPlanId ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
        }
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        adoptionWrap.contactPicklist.add(intialPick);
        FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
        Permanency_Plan__c rec = [SELECT Id, Service_Case__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit];
        Utility.pickListWrap childPick ;
        for (Contact contactIns : [SELECT Id, Name FROM Contact WHERE Service_Case__c = :rec.Service_Case__c AND Intake_Person_Role__c EXCLUDES ('Biological Child') LIMIT :Utility.queryLimit]) {
            
            childPick = new Utility.pickListWrap();
            childPick.label = contactIns.Name;
            childPick.value = contactIns.Id;
            adoptionWrap.contactPicklist.add(childPick);
        }
      
        return JSON.serialize(adoptionWrap);
    }
    
    @AuraEnabled
    public static String updateAdoptionPlanning(String adoptionPlanningJSON) {
        
        if (String.isNotBlank(adoptionPlanningJSON)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Notes__c,Reasonable_but_unsuccessful_efforts__c, Exception_granted_in_child_s_interest__c, Date_Exception_granted_child_interests__c', 'update', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Disclosure_Creation_Date__c, Person_s_information_Disclosed_To__c, Worker__c,Local_department__c, Non_staff_member__c,'+
            'child_placed_undiagnosed_mental_physical__c, medication_history_of_the_child__c, physical_abuse_experiences_child_victim__c,'+
            'children_born_to_child_biological_parent__c, known_out_of_home_placements__c, unable_to_return_his_her_family_origin__c,'+
            'sexual_abuse_experience_child_was_victim__c, child_s_relationship_with_his_her_birth__c, neglect_experiences_child_was_victim__c,'+
            'adoptive_search_and_reunion_service__c, physical_abuse_perpetrated_by_the_child__c, Provide_available_Lifebook_information__c,'+
            'alcohol_drug_addiction_child_s_parent__c, sexual_abuse_perpetrated_by_child__c, family_pertaining_to_child_s_schooling__c,'+
            'Complete_child_assessment_request_form__c, non_identifying_information_on_child__c, reasons_and_date_child_came_DDS_custody__c,'+
            'physical_mental_health_hospitalization__c, physical_mental_hospitalization_child__c, Number_of_siblings__c, Information_Name_Age__c,'+
            'Write_the_file_names__c,Disclosure_Approval_Status__c, Applicable_Child_Approval_Status__c, Disclosure_Submitted_by__c, Disclosure_Submitted_Date__c, Disclosure_Approved_by__c,Disclosure_Approved_Date__c', 'update', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Child_is_living_with_LDSS_holds_custody__c, Prospective_adoptive_family_committed__c, Notes_for_Emotional_ties__c', 'update', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Adoption_Plan_Begin_Date__c, Notes_for_narrative__c', 'update', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Contact__c, Child_in_care_15_out_of_last_22_months__c, Court_hearing_occurs__c, Information_for_either_parent_is_unknown__c, Reason_for_Recommendation__c,'+
                                                          'Court_order_of_TPR_for_parents__c, Petition_for_TPR_sent_to_court__c, Primary_Permanacy_Plan_is_adoption__c','update','Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            Permanency_Plan__c permanencyRec = (Permanency_Plan__c)JSON.deserialize(adoptionPlanningJSON, Permanency_Plan__c.class);
            update permanencyRec;
            return permanencyRec.Id;
            
        } else {
            return null;
        }
            
    }
    
    @AuraEnabled
    public static String updateTPR(String tprJSON) {
        
        if (String.isNotBlank(tprJSON)) {
            
            TPR__c tprRec = (TPR__c)JSON.deserialize(tprJSON, TPR__c.class);
            if (String.isBlank(tprRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('ParentName__c, Permanency_Plan__c, Date_Parent_Served__c, Method_of_Service__c, TPR_Status__c, TPR_Decision_Date__c, Relationship__c,'+
                'Termination__c, Termination_Appealed__c, Reason__c ', 'create', 'TPR__c', Boolean.valueOf(Label.HasNamespace));
                insert tprRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('ParentName__c, Permanency_Plan__c, Date_Parent_Served__c, Method_of_Service__c, TPR_Status__c, TPR_Decision_Date__c, Relationship__c,'+
                'Termination__c, Termination_Appealed__c, Reason__c ', 'update', 'TPR__c', Boolean.valueOf(Label.HasNamespace));
                update tprRec;
            }
            return tprRec.Id;
            
        } else {
            return null;
        }
            
    }
    
    @AuraEnabled
    public static String deleteTPR(Id tprId) {
        
        if (String.isNotBlank(tprId)) {
            FieldLevelSecurity.checkObjectAccessByDelete('TPR__c');            
            TPR__c tprRec = new TPR__c();
            tprRec.Id = tprId;
            delete tprRec;
            return 'Success';
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String getAdoptionEffortsInfo(String permanencyPlanId) {
        
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        if (String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Permanency_Plan__c, Effort_Date__c, Type_of_Effort__c, Notes__c', 'view', 'Adoption_Efforts__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Notes__c,Reasonable_but_unsuccessful_efforts__c, Exception_granted_in_child_s_interest__c, Date_Exception_granted_child_interests__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.adoptionEfforts = [SELECT Id, Permanency_Plan__c, Effort_Date__c, Type_of_Effort__c, Notes__c
                                            FROM Adoption_Efforts__c WHERE Permanency_Plan__c = :permanencyPlanId LIMIT :Utility.queryLimit];
            adoptionWrap.permanencyPlanRec = [SELECT Id, Reasonable_but_unsuccessful_efforts__c, Exception_granted_in_child_s_interest__c, Date_Exception_granted_child_interests__c,
                                             Notes__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit];
        }
        return JSON.serialize(adoptionWrap);
    }
    
    @AuraEnabled
    public static String upsertEffortsRecord(String effortsRecordJSON) {
        
        if(String.isNotBlank(effortsRecordJSON)) {
            
            Adoption_Efforts__c effortsRecords = (Adoption_Efforts__c)JSON.deserialize(effortsRecordJSON, Adoption_Efforts__c.class);
            if (String.isBlank(effortsRecords.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Permanency_Plan__c, Effort_Date__c, Type_of_Effort__c, Notes__c', 'create', 'Adoption_Efforts__c', Boolean.valueOf(Label.HasNamespace));
                insert effortsRecords;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Permanency_Plan__c, Effort_Date__c, Type_of_Effort__c, Notes__c', 'update', 'Adoption_Efforts__c', Boolean.valueOf(Label.HasNamespace));
                update effortsRecords;
            }
            return effortsRecords.Id;
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String deleteEffortsRecord(Id effortRecordId) {
        
        if(String.isNotBlank(effortRecordId)) {
            FieldLevelSecurity.checkObjectAccessByDelete('Adoption_Efforts__c');            
            Adoption_Efforts__c effortsRecords = new Adoption_Efforts__c();
            effortsRecords.Id = effortRecordId;
            delete effortsRecords;
            return 'Success';
        } else {
            return null;
        }
    }
    @AuraEnabled
    public static String updateApplicableChildAssessmentRec (String applicableChildAssessmentRecJSON, String resubmissionsign, String caseworkerSign) {
        
        if (String.isNotBlank(applicableChildAssessmentRecJSON)) {
            
            Permanency_Plan__c applicableChildAssessmentRec = (Permanency_Plan__c)JSON.deserialize(applicableChildAssessmentRecJSON, Permanency_Plan__c.class);
            if (String.isNotBlank(resubmissionsign)){
            	applicableChildAssessmentRec.Resubmission_Signature__c = resubmissionsign;
            }
            if (String.isNotBlank(caseworkerSign)) {
            	applicableChildAssessmentRec.Caseworker_Signature__c = caseworkerSign;
            }
            FieldLevelSecurity.checkFieldAccessByCriteria('Child_Birth_Date__c, Federal_Fiscal_Year_Adoption_Date__c, Check_the_age_of_the_child__c, Has_the_child_been_in_care__c, Is_the_child_a_sibling_to_a_child__c,'+
            'An_involuntary_removal_in_accordance__c, Date_of_removal__c, Date_of_first_court_order_CTW__c, A_voluntary_placement_agreement__c,'+
            'Child_Removal_Date_VPA__c, Voluntary_relinquishment__c, Date_of_relinquishment__c, medical_or_disability_requirements__c,'+
            'child_residing_in_a_foster_family_home__c, All_medical_disability_requirements_SSI__c, One_of_following_special_needs_factors__c,'+
            'Reasonable_but_unsuccessful_efforts__c, Reasonable_unsuccessful_effort_comments__c, If_instead_the_child_is_being_adopted_b__c, If_instead_child_being_adopted_comments__c,'+
            'Was_the_child_eligible_for_adoption__c, Document_explanation_in_case_record__c, Previous_Adoptive_Parent_s_TPR__c,'+
            'Previous_Adoptive_Parent_s_Death_date__c, Is_the_child_currently_Title_1V_E_foster__c, Is_the_child_currently_SSI_eligibile__c,Resubmission_Signature__c, Caseworker_Signature__c,'+
            'Applicable_Child_Approval_Status__c, child_be_returned_to_the_home_of_parent__c, Caseworker_Name__c, Caseworker_Date__c, Resubmission_Case_Worker_Name__c, Resubmission_Request_Date__c', 'update', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            update applicableChildAssessmentRec;
            return applicableChildAssessmentRec.Id;
            
        } else {
            return null;
        }
            
    }
    
    @AuraEnabled
    public static String upsertRateRecord(String raterecord) {
        
        if(String.isNotBlank(raterecord)) {

            Subsidy_Rate__c updateRateRecords = (Subsidy_Rate__c)JSON.deserialize(raterecord, Subsidy_Rate__c.class);
            if (String.isBlank(updateRateRecords.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Transaction_Date__c, Rate_Begin_Date__c,Rate_End_Date__c, SSA_Approval__c, Does_the_child_have_special_needs__c, SSA_Approval_Date__c, Primary_Basics_for_Special_Needs__c,'+
                'Adoptive_Family_s_Relationship_to_Child__c, Note__c, Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c,Rate_Approval_Status__c', 'create', 'Subsidy_Rate__c', Boolean.valueOf(Label.HasNamespace));
                insert updateRateRecords;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Transaction_Date__c, Rate_Begin_Date__c,Rate_End_Date__c, SSA_Approval__c, Does_the_child_have_special_needs__c, SSA_Approval_Date__c, Primary_Basics_for_Special_Needs__c,'+
                'Adoptive_Family_s_Relationship_to_Child__c, Note__c, Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c,Rate_Approval_Status__c', 'update', 'Subsidy_Rate__c', Boolean.valueOf(Label.HasNamespace));
                update updateRateRecords;
            }
            return updateRateRecords.Id;
        }
        else {
            return null;
        }
    }
    
     @AuraEnabled
    public static String getRateRecordInfo(String PermanacyPlanId) {
        
         PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
         if (String.isNotBlank(PermanacyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Approval_Status__c,Adoptive_Parent_1__c,Adoptive_Parent_2__c,Subsidy_Provider_Id__c,Subsidy_Agreement_Start_Date__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Transaction_Date__c, Rate_Begin_Date__c, Rate_End_Date__c, SSA_Approval__c, Does_the_child_have_special_needs__c, SSA_Approval_Date__c, Primary_Basics_for_Special_Needs__c,'+
            'Adoptive_Family_s_Relationship_to_Child__c, Note__c, Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c,'+
            'Rate_Approval_Status__c', 'view', 'Subsidy_Rate__c', Boolean.valueOf(Label.HasNamespace));
             adoptionWrap.primaryBasisPicklist = Utility.getPicklistinfo('Subsidy_Rate__c','Primary_Basics_for_Special_Needs__c', false);
             adoptionWrap.rateRecord = [SELECT Id,Transaction_Date__c, Rate_Begin_Date__c, Rate_End_Date__c, SSA_Approval__c, Does_the_child_have_special_needs__c, SSA_Approval_Date__c, Primary_Basics_for_Special_Needs__c,
                                        Adoptive_Family_s_Relationship_to_Child__c, Note__c, Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c, 
                                        Permanency_Plan__r.Subsidy_Approval_Status__c, Rate_Approval_Status__c, Permanency_Plan__r.Adoptive_Parent_1__c, Permanency_Plan__r.Adoptive_Parent_2__c, Permanency_Plan__r.Subsidy_Provider_Id__c,
                                        Permanency_Plan__r.Subsidy_Agreement_Start_Date__c
                                        FROM Subsidy_Rate__c WHERE Permanency_Plan__c =:PermanacyPlanId LIMIT :Utility.queryLimit];
            adoptionWrap.permanencyPlanRec = [SELECT Id, Adoptive_Parent_1__c, Adoptive_Parent_2__c, Subsidy_Provider_Id__c, Subsidy_Agreement_Start_Date__c FROM Permanency_Plan__c WHERE Id = :PermanacyPlanId LIMIT :Utility.queryLimit];
         }
        return JSON.serialize(adoptionWrap);
    }
    
     @AuraEnabled
    public static String getRateRecord(String rateRecordId) {
        
         Subsidy_Rate__c rateRecord = new Subsidy_Rate__c();
         if (String.isNotBlank(rateRecordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Approval_Status__c,Adoptive_Parent_1__c,Adoptive_Parent_2__c,Subsidy_Provider_Id__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Transaction_Date__c, Rate_Begin_Date__c,Rate_End_Date__c, SSA_Approval__c, Does_the_child_have_special_needs__c, SSA_Approval_Date__c, Primary_Basics_for_Special_Needs__c,'+
            'Adoptive_Family_s_Relationship_to_Child__c, Note__c, Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c,Rate_Approval_Status__c', 'view', 'Subsidy_Rate__c', Boolean.valueOf(Label.HasNamespace));
              rateRecord = [SELECT Id,Transaction_Date__c, Rate_Begin_Date__c,Rate_End_Date__c, SSA_Approval__c, Does_the_child_have_special_needs__c, SSA_Approval_Date__c, Primary_Basics_for_Special_Needs__c,
                            Adoptive_Family_s_Relationship_to_Child__c, Note__c, Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c,
                            Permanency_Plan__r.Subsidy_Approval_Status__c, Rate_Approval_Status__c, Permanency_Plan__r.Adoptive_Parent_1__c, Permanency_Plan__r.Adoptive_Parent_2__c, Permanency_Plan__r.Subsidy_Provider_Id__c
                            FROM Subsidy_Rate__c WHERE Id =:rateRecordId LIMIT :Utility.queryLimit];
         }
         return JSON.serialize(rateRecord);
        
    }
    
    @AuraEnabled
    public static String getSubsidyAgreementIntiInfos(String permanencyPlanId) {
        
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        	adoptionWrap.adoptiveSubsidyIsPaidPicklist = Utility.getPicklistinfo('Permanency_Plan__c', 'adopt_if_a_subsidy_is_paid__c', false);
            adoptionWrap.childPlacedFromPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Child_Placed_From__c', false);
            adoptionWrap.childPlacedByPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Child_Placed_By__c', false);
        	adoptionWrap.placementStructurePicklist = Utility.getPicklistinfo('Account','Placement_Structure__c',false);
        	adoptionWrap.childCharPicklist = Utility.getPicklistinfo('Account','Child_Characteristics_Willing_To_Accept__c',true);
        	adoptionWrap.localDeptPicklist = Utility.getPicklistinfo('Account','Local_Department__c',false);
     	    
        if (String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Agreement_Start_Date__c, Subsidy_Agreement_End_Date__c, Subsidy_Agreement_Under_Appeal__c,'+
            'Offered_Adoption_subsidy__c, Offer_Accepted_Date__c, Single_Parent_Adoption_Check__c, Adoptive_Parent_1_signature_date__c,'+
            'Adoptive_Parent_2_Signature_Date__c, LDSS_Director_Designee_Signature_Date__c, Adoptive_Parent_1_Signature__c,'+
            'Adoptive_Parent_2_Signature__c, LDSS_Director_DESIGNEE_SIGNATURE__c, adopt_if_a_subsidy_is_paid__c,Medical_Assistance_only__c,'+
            'Subsidy_Agreement_Comments__c, Child_Placed_From__c, Child_Placed_By__c, Adoptive_Parent_1__c, Adoptive_Parent_2__c, Subsidy_Provider_Id__c,'+
            'Subsidy_Approval_Status__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.subsidyAgreementRec = [SELECT Id, Subsidy_Agreement_Start_Date__c, Subsidy_Agreement_End_Date__c, Subsidy_Agreement_Under_Appeal__c, 
                                               	Offered_Adoption_subsidy__c, Offer_Accepted_Date__c, Single_Parent_Adoption_Check__c, Adoptive_Parent_1_signature_date__c,
                                                Adoptive_Parent_2_Signature_Date__c, LDSS_Director_Designee_Signature_Date__c, Adoptive_Parent_1_Signature__c, 
                                                Adoptive_Parent_2_Signature__c, LDSS_Director_DESIGNEE_SIGNATURE__c, adopt_if_a_subsidy_is_paid__c,Medical_Assistance_only__c,
                                                Subsidy_Agreement_Comments__c, Child_Placed_From__c, Child_Placed_By__c, Adoptive_Parent_1__c, Adoptive_Parent_2__c, Subsidy_Provider_Id__c,
                                                Subsidy_Approval_Status__c FROM Permanency_Plan__c
                                                WHERE Id=:permanencyPlanId LIMIT :Utility.queryLimit
                                               ];
            return JSON.serialize(adoptionWrap);
            
         } else{
             return null;
         }
    }
    
    @AuraEnabled
    public static String getEmotionalTiesInitInfo(String permanencyPlanId) {
        
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        if (String.isNotBlank(permanencyPlanId)) {
            adoptionWrap.typePicklist = Utility.getPicklistinfo('Emotional_tie__c', 'Type__c', false);
            adoptionWrap.prefixList = Utility.getPicklistinfo('Emotional_tie__c', 'Prefix__c', false);
            adoptionWrap.suffixList = Utility.getPicklistinfo('Emotional_tie__c', 'Suffix__c', false);
            adoptionWrap.placementStructurePicklist = Utility.getPicklistinfo('Placement__c','Placement_Structure__c',false);
        	adoptionWrap.childCharPicklist = Utility.getPicklistinfo('Account','Child_Characteristics_Willing_To_Accept__c',true);
        	adoptionWrap.localDeptPicklist = Utility.getPicklistinfo('Account','Local_Department__c',false);
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Casevault_ProID__c,Number_of_Beds__c,Placement_Structure__c,Type__c', 'view', 'Account', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('First_Name__c, Importance_to_Child__c,Provider__c,Last_Name__c, Middle_Name__c, Prefix__c, Relationship_to_Child__c, Suffix__c, Type__c', 'view', 'Emotional_tie__c', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.emotionalTieList = [SELECT Id, First_Name__c, Importance_to_Child__c, Provider__c, Provider__r.Name, Provider__r.Casevault_ProID__c,
                                             Last_Name__c, Middle_Name__c, Prefix__c, Relationship_to_Child__c, Suffix__c, Type__c, Provider__r.Number_of_Beds__c,
                                             Provider__r.Placement_Structure__c, Provider__r.Type__c FROM Emotional_tie__c WHERE Permanency_Plan__c = :permanencyPlanId LIMIT :Utility.queryLimit];
            return JSON.serialize(adoptionWrap);
        }else{
             return null;
        }
        
    }
    
    @AuraEnabled
    public static String upsertEmotionalTies(String emotionalTiesJSON) {
        
        if(String.isNotBlank(emotionalTiesJSON)) {

            Emotional_tie__c emotionalTieRec = (Emotional_tie__c)JSON.deserialize(emotionalTiesJSON, Emotional_tie__c.class);
            if (String.isBlank(emotionalTieRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('First_Name__c, Importance_to_Child__c,Provider__c,Last_Name__c, Middle_Name__c, Prefix__c, Relationship_to_Child__c, Suffix__c, Type__c', 'create', 'Emotional_tie__c', Boolean.valueOf(Label.HasNamespace));
                insert emotionalTieRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('First_Name__c, Importance_to_Child__c,Provider__c,Last_Name__c, Middle_Name__c, Prefix__c, Relationship_to_Child__c, Suffix__c, Type__c', 'update', 'Emotional_tie__c', Boolean.valueOf(Label.HasNamespace));
                update emotionalTieRec;
            }
            return emotionalTieRec.Id;
        }
        else {
            return null;
        } 
        
    }
    @AuraEnabled
    public static String getSelectProviderDetail(String providerId) {
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        if(String.isNotBlank(providerId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Provider_Id__c, Name, Applicant_or_Co_Applicant__c', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.providerList = [SELECT Id, Provider_Id__c, AccountId, Name, Applicant_or_Co_Applicant__c 
                                         FROM Contact WHERE  AccountId =: providerId LIMIT :Utility.queryLimit];
          return JSON.serialize(adoptionWrap.providerList);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getDisclosureChecklistRecord(String permanencyRecordId) {
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        if(String.isNotBlank(permanencyRecordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Disclosure_Creation_Date__c, Person_s_information_Disclosed_To__c, Worker__c,Local_department__c, Non_staff_member__c,'+
            'child_placed_undiagnosed_mental_physical__c, medication_history_of_the_child__c, physical_abuse_experiences_child_victim__c,'+
            'children_born_to_child_biological_parent__c, known_out_of_home_placements__c, unable_to_return_his_her_family_origin__c,'+
            'sexual_abuse_experience_child_was_victim__c, child_s_relationship_with_his_her_birth__c, neglect_experiences_child_was_victim__c,'+
            'adoptive_search_and_reunion_service__c, physical_abuse_perpetrated_by_the_child__c, Provide_available_Lifebook_information__c,'+
            'alcohol_drug_addiction_child_s_parent__c, sexual_abuse_perpetrated_by_child__c, family_pertaining_to_child_s_schooling__c,'+
            'Complete_child_assessment_request_form__c, non_identifying_information_on_child__c, reasons_and_date_child_came_DDS_custody__c,'+
            'physical_mental_health_hospitalization__c, physical_mental_hospitalization_child__c, Number_of_siblings__c, Information_Name_Age__c,'+
            'Write_the_file_names__c,Disclosure_Approval_Status__c, Applicable_Child_Approval_Status__c, Disclosure_Submitted_by__c, Disclosure_Submitted_Date__c, Disclosure_Approved_by__c,Disclosure_Approved_Date__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.disclosureChecklistRecord = [SELECT Id,Disclosure_Creation_Date__c, Person_s_information_Disclosed_To__c, Worker__c,Local_department__c, Non_staff_member__c,
                                                      child_placed_undiagnosed_mental_physical__c, medication_history_of_the_child__c, physical_abuse_experiences_child_victim__c,
                                                      children_born_to_child_biological_parent__c, known_out_of_home_placements__c, unable_to_return_his_her_family_origin__c,
                                                      sexual_abuse_experience_child_was_victim__c, child_s_relationship_with_his_her_birth__c, neglect_experiences_child_was_victim__c,
                                                      adoptive_search_and_reunion_service__c, physical_abuse_perpetrated_by_the_child__c, Provide_available_Lifebook_information__c,
                                                      alcohol_drug_addiction_child_s_parent__c, sexual_abuse_perpetrated_by_child__c, family_pertaining_to_child_s_schooling__c,
                                                      Complete_child_assessment_request_form__c, non_identifying_information_on_child__c, reasons_and_date_child_came_DDS_custody__c, 
                                                      physical_mental_health_hospitalization__c, physical_mental_hospitalization_child__c, Number_of_siblings__c, Information_Name_Age__c,
                                                      Write_the_file_names__c,Disclosure_Approval_Status__c, Applicable_Child_Approval_Status__c, Disclosure_Submitted_by__c, Disclosure_Submitted_Date__c, Disclosure_Approved_by__c,Disclosure_Approved_Date__c
                                                      FROM Permanency_Plan__c WHERE  Id =: permanencyRecordId LIMIT :Utility.queryLimit];
                                         
          return JSON.serialize(adoptionWrap);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String updateBreaktheLinkRec(String breakthelinkRecord) {
        
        if(String.isNotBlank(breakthelinkRecord)) {

            Permanency_Plan__c updateBreakthelinkRec = (Permanency_Plan__c)JSON.deserialize(breakthelinkRecord, Permanency_Plan__c.class);
            if (String.isNotBlank(updateBreakthelinkRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c, Contact__c, Adoption_Plan_Begin_Date__c,Disclosure_Approval_Status__c, Break_Line_Approval_Status__c, Child_is_Legally_free__c, Child_was_in_an_Approved_Pre_Adoptive__c, Adoptive_Placement_Agreement_signed__c,Date_Agreement_signed__c,Case_Creation_Date__c', 'create', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
                update updateBreakthelinkRec;
            } 
            return updateBreakthelinkRec.Id;
        }
        else {
            return null;
        }
    }
   
    @AuraEnabled
    public static String updateSubsidyAgreement(String updateSubsidyAgreementJSON, String parent1Signature, String parent2Signature, String lDSSDirectorSignature) {
        if (String.isNotBlank(updateSubsidyAgreementJSON)) {
            
            Permanency_Plan__c updateSubsidyAgreementRec = (Permanency_Plan__c)JSON.deserialize(updateSubsidyAgreementJSON, Permanency_Plan__c.class);
            if(String.isNotBlank(updateSubsidyAgreementRec.Id)) {
                if(String.isNotBlank(parent1Signature)) {
                	updateSubsidyAgreementRec.Adoptive_Parent_1_Signature__c = parent1Signature;
                }
                if(String.isNotBlank(parent2Signature)) {
                    updateSubsidyAgreementRec.Adoptive_Parent_2_Signature__c = parent2Signature;
                }
                if(String.isNotBlank(lDSSDirectorSignature)) {
                    updateSubsidyAgreementRec.LDSS_Director_DESIGNEE_SIGNATURE__c = lDSSDirectorSignature;
                } 
                FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Agreement_Start_Date__c, Subsidy_Agreement_End_Date__c, Subsidy_Agreement_Under_Appeal__c,'+
                'Offered_Adoption_subsidy__c, Offer_Accepted_Date__c, Single_Parent_Adoption_Check__c, Adoptive_Parent_1_signature_date__c,'+
                'Adoptive_Parent_2_Signature_Date__c, LDSS_Director_Designee_Signature_Date__c, Adoptive_Parent_1_Signature__c,'+
                'Adoptive_Parent_2_Signature__c, LDSS_Director_DESIGNEE_SIGNATURE__c, adopt_if_a_subsidy_is_paid__c,Medical_Assistance_only__c,'+
                'Subsidy_Agreement_Comments__c, Child_Placed_From__c, Child_Placed_By__c, Adoptive_Parent_1__c, Adoptive_Parent_2__c, Subsidy_Provider_Id__c,'+
                'Subsidy_Approval_Status__c', 'update', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
                update updateSubsidyAgreementRec;
            }
           return updateSubsidyAgreementRec.Id;
        } else {
            return null;
        }
    }
   
    
    @AuraEnabled
    public static String getBreakthelinkRecord(String permanencyPlanId) {
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        
        if(String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c, Contact__c, Adoption_Plan_Begin_Date__c,Disclosure_Approval_Status__c, Break_Line_Approval_Status__c, Child_is_Legally_free__c, Child_was_in_an_Approved_Pre_Adoptive__c, Adoptive_Placement_Agreement_signed__c,Date_Agreement_signed__c,Case_Creation_Date__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Permanency_Plan__c, TPR_Decision_Date__c', 'view', 'TPR__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement_Structure__c, Provider__c,Begin_Date__c, End_Date__c, Placement_Approval_Status__c ', 'view', 'Placement__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Permanency_Plan__c, Rate_Approval_Status__c ', 'view', 'Subsidy_Rate__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Account', Boolean.valueOf(Label.HasNamespace));

            adoptionWrap.breaktheLinkRecord = [SELECT Id, Placement__c, Contact__c, Adoption_Plan_Begin_Date__c,Disclosure_Approval_Status__c, Break_Line_Approval_Status__c, Child_is_Legally_free__c, Child_was_in_an_Approved_Pre_Adoptive__c, Adoptive_Placement_Agreement_signed__c,Date_Agreement_signed__c,Case_Creation_Date__c
                                             FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit];
            adoptionWrap.tpRList = [SELECT Id,  Permanency_Plan__c, TPR_Decision_Date__c
                                    FROM TPR__c WHERE Permanency_Plan__c = :permanencyPlanId LIMIT :Utility.queryLimit];
            adoptionWrap.placementRec = [SELECT Id, Placement_Structure__c, Provider__c, Provider__r.Name, Begin_Date__c, End_Date__c, Placement_Approval_Status__c 
                                         FROM Placement__c WHERE Id = :adoptionWrap.breaktheLinkRecord.Placement__c LIMIT :Utility.queryLimit];
            adoptionWrap.courtHearingRec = [SELECT Id, Court__r.Court_Order_Date__c FROM Court_Petition_Hearing__c WHERE (Court__r.Type_of_Petition__c = 'TPR' OR Court__r.Type_of_Petition__c = 'Adoption') AND
											Scheduled_Hearing_Type__c INCLUDES ('Adoption;TPR/Guardianship- Contested') AND Court__r.Hearing_Outcome__c INCLUDES('Adoption Granted','TPR Granted')
											AND Court__r.Petition_for_Child__c = :adoptionWrap.breaktheLinkRecord.Contact__c ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
            adoptionWrap.subSidyRecList = [SELECT Id, Permanency_Plan__c, Rate_Approval_Status__c  FROM Subsidy_Rate__c WHERE Permanency_Plan__c = :permanencyPlanId AND Rate_Approval_Status__c = 'Approved' LIMIT :Utility.queryLimit];
            
            return JSON.serialize(adoptionWrap);
        } else {
            
            return null;
        }
    }

	@AuraEnabled
    public static String onSubmitForApproval(String permanencyRecId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(permanencyRecId) && String.isNotBlank(selectedSupervisorUserId)) {
            Permanency_Plan__c permanencyRec =  new Permanency_Plan__c ();
            permanencyRec.Id = permanencyRecId;
            permanencyRec.Supervisor_Approval__c  = selectedSupervisorUserId;
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Approval__c','update','Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
            update permanencyRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Adoption Planning Record Submit For Approval');        
            req.setObjectId(permanencyRec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
         
    } 
    
    @AuraEnabled
    public static String subsidySubmitForApproval(String subsidyRateRecId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(subsidyRateRecId) && String.isNotBlank(selectedSupervisorUserId)) {
            Subsidy_Rate__c subsidyRateRec =  new Subsidy_Rate__c ();
            subsidyRateRec.Id = subsidyRateRecId;
            subsidyRateRec.Supervisor_Approval__c  = selectedSupervisorUserId;
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Approval__c','update','Subsidy_Rate__c', Boolean.valueOf(Label.HasNamespace));
            update subsidyRateRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Subsidy Rate Record Submit For Approval');        
            req.setObjectId(subsidyRateRec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
         
    }  
    
    @AuraEnabled
    public static String getActiveTab(String permanencyRecId) {

        Permanency_Plan__c  activetab = new Permanency_Plan__c();
        if(String.isNotBlank(permanencyRecId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Approval_Status__c', 'view', 'Permanency_Plan__c', Boolean.valueOf(Label.HasNamespace));
              activetab = [SELECT Subsidy_Approval_Status__c FROM Permanency_Plan__c WHERE Id =:permanencyRecId LIMIT :Utility.queryLimit];
        }
        return JSON.serialize(activetab);
    }
    
     public class PermanencyPlanAdoptionWrapper {
    
        @AuraEnabled
        public List<Utility.pickListWrap> adoptionPlanPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> reasonForRecommendationPicklist;
        @AuraEnabled
        public Permanency_Plan__c permanencyPlanRec;
        @AuraEnabled
        public List<Court_Petition_Hearing__c> courtHearingRec; 
        @AuraEnabled
        public List<Utility.pickListWrap> adoptionPlanningStagePicklist;
        @AuraEnabled
        public Permanency_Plan__c adoptionPlanningStageRec;
        @AuraEnabled
        public List<Utility.pickListWrap> TPRStatusPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> MethodofServicePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> RelationshipPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> TerminationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactPicklist;
        @AuraEnabled
        public List<TPR__c> tpRList;
        @AuraEnabled
        public List<Utility.pickListWrap> hasTheChildBeenInCarePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> checkTheAgeOfChildTheChildPicklist;
        @AuraEnabled
        public List<Adoption_Efforts__c> adoptionEfforts;
        @AuraEnabled
        Public Permanency_Plan__c applicableChildAssRec;
        @AuraEnabled
        Public Permanency_Plan__c disclosureChecklistRecord;
        @AuraEnabled
        public List<Utility.pickListWrap> specialNeedsPicklist;
        @AuraEnabled
        public List<Legal_Custody__c> legalCustody;
        @AuraEnabled
        public List<Placement__c> placementRec;
        @AuraEnabled
        public List<Utility.pickListWrap> adoptiveSubsidyIsPaidPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childPlacedFromPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childPlacedByPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> placementStructurePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childCharPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> localDeptPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> typePicklist;
        @AuraEnabled
        public List<Emotional_tie__c> emotionalTieList;
        @AuraEnabled
        public List<Utility.pickListWrap> prefixList;
        @AuraEnabled
        public List<Utility.pickListWrap> suffixList;
        @AuraEnabled
        public List<Contact> providerList;
        @AuraEnabled
        public Permanency_Plan__c breaktheLinkRecord;
        @AuraEnabled
        public Permanency_Plan__c subsidyAgreementRec;
        public PermanencyPlanAdoptionWrapper() {
        
            contactPicklist = new List<Utility.pickListWrap>();
            placementRec = new List<Placement__c>();
            emotionalTieList = new List<Emotional_tie__c>();
        }
        @AuraEnabled
        public List<Utility.pickListWrap> primaryBasisPicklist;
        @AuraEnabled
        Public List<Subsidy_Rate__c> rateRecord;
       	@AuraEnabled
        Public List<Subsidy_Rate__c> subSidyRecList;
     }   
    
}