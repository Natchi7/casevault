public  with sharing class CasePlanController {
    
    @AuraEnabled
    public static String getPlacementTableRecords(String serviceCaseId) {
        
        CasePlanVersion initialRecord = new CasePlanVersion();
        if (String.isNotBlank(serviceCaseId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name , Begin_Date__c, Service_Case__c, Child__c, Child_Removal__c, Provider__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_PID__c , Date_of_Birth__c, Name, Gender__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Removal_Date__c', 'view', 'Child_Removal__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
            
            initialRecord.placementTableRecord = [SELECT Id, Name ,Begin_Date__c, Child__r.Casevault_PID__c, Child__r.Name, Child__r.Date_of_Birth__c, Child__r.Gender__c, Child_Removal__r.Removal_Date__c, Provider__r.Name FROM Placement__c 
                                                  WHERE Service_Case__c =:serviceCaseId AND Exit_Approval_Status__c !='Approved' LIMIT :Utility.queryLimit];
            return JSON.serialize(initialRecord);
            
        } else {
            
            return null;
        }
    }
    
    @AuraEnabled
    public static String getPlacementRecords(String placementId) {
        
        CasePlanVersion initialRecord = new CasePlanVersion();
        if (String.isNotBlank(placementId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Begin_Date__c, Child__c, Child_Removal__c, Provider__c ', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Removal_Date__c', 'view', 'Child_Removal__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, From_Date__c, To_Date__c, Placement__c ', 'view', 'Case_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            
            initialRecord.placementRecord = [SELECT Id, Name ,Begin_Date__c, Child__r.Name, Child_Removal__r.Removal_Date__c, Provider__r.Name FROM Placement__c WHERE Id =:placementId LIMIT :Utility.queryLimit];
            initialRecord.casePlanRecords = [SELECT Id, Name , From_Date__c, To_Date__c FROM Case_Plan__c WHERE Placement__c =:placementId LIMIT :Utility.queryLimit];
            return JSON.serialize(initialRecord);
            
        } else {
            
            return null;
        }
    }
    
    @AuraEnabled
    public static String getCasePlanVersionRecord(String placementId) {
        
        CasePlanVersion casePlanVersionRecord = new CasePlanVersion();
        if (String.isNotBlank(placementId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Case_Plan_Name__c ,From_Date__c, Period__c, Status__c, To_Date__c', 'view', 'Case_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            
            casePlanVersionRecord.casePlanVersionRecords = [SELECT Id, Case_Plan_Name__c ,From_Date__c, Period__c, Status__c, To_Date__c FROM Case_Plan__c WHERE Placement__c =:placementId LIMIT :Utility.queryLimit];
            return JSON.serialize(casePlanVersionRecord);
            
        } else {
            
            return null;
        }
    }
    
    @AuraEnabled
    public static String createCasePlanVersion(String casePlanVersionDataJSON) {
        
        if (String.isNotBlank(casePlanVersionDataJSON)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c ,From_Date__c, Period__c, Approval_Status__c, To_Date__c', 'create', 'Case_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            Case_Plan__c createCasePlanVersionRec = (Case_Plan__c) JSON.deserialize(casePlanVersionDataJSON, Case_Plan__c.class);
            insert createCasePlanVersionRec;
            return JSON.serialize(createCasePlanVersionRec);
        } else { 
            return null;
        }
    }
    
    @AuraEnabled
    public static String getSocialHistoryRecord(String casePlanVersionId) {
        
        socialHistoryRecord socialHistoryRec = new socialHistoryRecord();
        if (String.isNotBlank(casePlanVersionId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c', 'view', 'Case_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Child__c, Child_Removal__c, Service_Case__c ', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Date_of_Birth__c, Name, Gender__c, Casevault_PID__c, Races__c, Religion__c, SSN__c, Applicant_or_Co_Applicant__c, Applicant_First_Name__c, Applicant_Last_Name__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Removal_Date__c, Reasonable_efforts_made_to_prevent_child__c, Address_Of_Primary_Caregiver__c ', 'view', 'Child_Removal__c',  Boolean.valueOf(Label.HasNamespace));
            
            Case_Plan__c casePlanRec = [SELECT Id, Placement__r.Child__r.Name, Placement__r.Child_Removal__r.Removal_Date__c, Placement__r.Service_Case__c,
                                        Placement__r.Child__r.Date_of_Birth__c, Placement__r.Child__r.Gender__c,Placement__r.Child__r.Casevault_PID__c,
                                        Placement__r.Child_Removal__r.Reasonable_efforts_made_to_prevent_child__c, Placement__r.Child__r.Races__c,
                                        Placement__r.Child__r.Religion__c, Placement__r.Child__r.SSN__c, Placement__r.Child__r.Applicant_or_Co_Applicant__c, Placement__r.Child_Removal__r.Address_Of_Primary_Caregiver__c,
                                        Placement__r.Child__r.Applicant_First_Name__c, Placement__r.Child__r.Applicant_Last_Name__c FROM Case_Plan__c WHERE Id =:casePlanVersionId LIMIT :Utility.queryLimit];
            
            socialHistoryRec.childName = casePlanRec.Placement__r.Child__r.Name;
            socialHistoryRec.removalDate = casePlanRec.Placement__r.Child_Removal__r.Removal_Date__c;
            socialHistoryRec.DOB = casePlanRec.Placement__r.Child__r.Date_of_Birth__c;
            socialHistoryRec.gender = casePlanRec.Placement__r.Child__r.Gender__c;
            socialHistoryRec.clientId = casePlanRec.Placement__r.Child__r.Casevault_PID__c;
            socialHistoryRec.reasonableEffort = casePlanRec.Placement__r.Child_Removal__r.Reasonable_efforts_made_to_prevent_child__c;
            socialHistoryRec.race = casePlanRec.Placement__r.Child__r.Races__c;
            socialHistoryRec.religion = casePlanRec.Placement__r.Child__r.Religion__c;
            socialHistoryRec.ssn = casePlanRec.Placement__r.Child__r.SSN__c;
            socialHistoryRec.addressofPrimaryCaregiver = casePlanRec.Placement__r.Child_Removal__r.Address_Of_Primary_Caregiver__c;
            
            if(casePlanRec.Placement__r.Child__r.Applicant_or_Co_Applicant__c =='Applicant' &&  (casePlanRec.Placement__r.Child__r.Applicant_First_Name__c !=null ||  casePlanRec.Placement__r.Child__r.Applicant_Last_Name__c != null)) {
                socialHistoryRec.applicant = casePlanRec.Placement__r.Child__r.Applicant_First_Name__c+' '+casePlanRec.Placement__r.Child__r.Applicant_Last_Name__c;
            } else if(casePlanRec.Placement__r.Child__r.Applicant_First_Name__c !=null ||  casePlanRec.Placement__r.Child__r.Applicant_Last_Name__c != null) {
                socialHistoryRec.coApplicant = casePlanRec.Placement__r.Child__r.Applicant_First_Name__c+' '+casePlanRec.Placement__r.Child__r.Applicant_Last_Name__c;
            }
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Assessment_Type__c, Approval_Status__c, Service_Case__c ', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
            
            List<Assessment__c> assessmentRecSafeC = [SELECT Id FROM Assessment__c WHERE Assessment_Type__c ='SAFE-C' AND Service_Case__c =:casePlanRec.Placement__r.Service_Case__c AND Approval_Status__c ='Approved' ORDER By CreatedDate DESC LIMIT 1];
            List<Assessment__c> assessmentRecReassessment = [SELECT Id FROM Assessment__c WHERE Assessment_Type__c ='Family risk Reassessment' AND Service_Case__c =:casePlanRec.Placement__r.Service_Case__c AND Approval_Status__c ='Approved' 
                                                             ORDER By CreatedDate DESC LIMIT 1];
            FieldLevelSecurity.checkFieldAccessByCriteria('TargetObjectId,CompletedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
            String assessmentCompletedDateQuery = 'SELECT CompletedDate, TargetObjectId FROM ProcessInstance WHERE';
            
            if((assessmentRecSafeC.size() > 0 && assessmentRecSafeC != null) && (assessmentRecReassessment != null && assessmentRecReassessment.size() > 0)) {
                String safec = assessmentRecSafeC[0].Id;
                String reassessment  = assessmentRecReassessment[0].Id;
                assessmentCompletedDateQuery +=' TargetObjectId =: safec OR TargetObjectId =: reassessment';
            } else if (assessmentRecSafeC.size() > 0 && assessmentRecSafeC != null) {
                String safec = assessmentRecSafeC[0].Id;
                assessmentCompletedDateQuery +=' TargetObjectId =: safec';
            } else if (assessmentRecReassessment.size() > 0 && assessmentRecReassessment != null){
                String reassessment  = assessmentRecReassessment[0].Id;
                assessmentCompletedDateQuery +=' TargetObjectId =: reassessment';
            }
            List<ProcessInstance> assessmentCompletedDate = new List<ProcessInstance>();
            if (assessmentRecSafeC.size() > 0 || assessmentRecReassessment.size() > 0 ) {
                Integer queryLimit = Utility.queryLimit;
                //assessmentCompletedDateQuery += 'LIMIT :queryLimit';
                assessmentCompletedDate = Database.query(assessmentCompletedDateQuery);
            }
            if(assessmentCompletedDate.size() > 0) {
                for(ProcessInstance assementRec : assessmentCompletedDate ){
                    
                    if (assessmentRecSafeC.size() >0 && assementRec.TargetObjectId == assessmentRecSafeC[0].Id) {
                        socialHistoryRec.safecCompletionDate = assementRec.CompletedDate;
                    } else if (assessmentRecReassessment.size() >0 && assementRec.TargetObjectId == assessmentRecReassessment[0].Id) {
                        socialHistoryRec.riskReassessmentCompletionDate = assementRec.CompletedDate;
                    }
                }
            }
            return JSON.serialize(socialHistoryRec);
            
        } else {
            
            return null;
        }
    }
    
    @AuraEnabled
    public static String getPermanencyProgressRecord(String casePlanVersionId) {
        
        CasePlanVersion PermanencyProgressRec = new CasePlanVersion();
        if (String.isNotBlank(casePlanVersionId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c, caseworker_Service_EndDate__c, caseworker_Service_StartDate__c,'
                                                          +'Date_of_last_Progress_Report__c, Describe_the_parent_current_relationship__c,'
                                                          +'Discuss_how_the_worker_is_addressing__c, Discuss_parent_child_interaction__c,'
                                                          +'Discuss_the_visitation_plan__c, Follow_up_information_on_court_orders__c, List_mandates_of_court_order_pertaining__c, Referral_Made_to_Adoptuskids__c,'
                                                          +'What_services_are_being_provided__c,What_services_provided_to_eliminate__c, What_services_have_we_identified__c, Health_Passport__c,'
                                                          +'Day_Care__c, Reimbursement_for_Expenses__c, Transportation__c, Discussion_of_Visitation_Date__c, Financial_Support__c, Emotional_Support_or_Guidance__c,'
                                                          +'Special_Training__c, Other__c, Discussion_of_Childs_Needs__c, If_Other__c, Respite_Care__c, Discuss_each_checked_iteam__c, Is_the_child_co_committed__c,'
                                                          +'Has_youth_experienced_any_episodes__c, Has_the_youth_experienced_Explain__c, Has_youth_had_involvement__c, Parent_Name__c,'
                                                          +'Child_IN_Out_Of_Home_Placement__c, State_Compelling_Reason__c, Date_TPR_Petition_Filed__c,'
                                                          +'Date_of_Voluntary_signature_Mother__c, Date_of_Voluntary_signature_Father__c,'                                                              
                                                          +'Date_TPR_Granted__c, Date_TPR_Denied__c, Date_TPR_Appeal_Filed_Father__c, Date_TPR_Appeal_Filed_Mother__c, TPR_Appeal_Decision_Father__c,'
                                                          +'TPR_Appeal_Decision_Mother__c, Was_the_child_enrolled_in_school__c, Is_this_school_placement__c, Has_the_child_changed_school__c,'
                                                          +'Best_interest_to_change_schools__c, Discuss_the_appropriateness__c, What_Educational_services__c, If_child_is_pre_school_age__c,'
                                                          +'Child_current_report_card__c, Individual_Education_Program__c, Educational_Parent_Name__c, Educational_Parent_Address__c, Educational_Parent_Requested__c,'
                                                          +'At_or_near_age_level__c, Behavioral_problems__c, Problems_with_peers__c, Strengths__c, Weakness__c, Describe_the_child_strengths__c,'
                                                          +'Child_is_between_18_and_21_years_old__c, Does_the_child_have_any_diagnosed__c, Homelessness_during_reporting_period__c, Length_Of_Time_Child_Was_Homeless__c,'
                                                          +'Will_Youth_Require_Supportive_Services__c	, Discuss_Services_Youth_Will_Require__c, Passport_Record_Confirmation__c,'
                                                          +'Dates_Confirmed__c, Notes__c, Child_Support_Referral_Date__c, Child_Support_Order_Been_Established__c ', 'view', 'Case_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Child__c, Provider__c, Service_Case__c, Placement_Structure__c, End_Date__c ', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c', 'view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber, Jurisdiction__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Date_of_Birth__c, Casevault_PID__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            
            PermanencyProgressRec.PermanencyProgressRecord = [SELECT Id, Placement__r.Service_Case__c, Placement__r.Child__r.Name, Placement__r.Child__r.Date_of_Birth__c,
                                                              Placement__r.Child__r.Casevault_PID__c, Placement__r.Service_Case__r.Intake__r.CaseNumber ,
                                                              From_Date__c, To_Date__c, Placement__r.Service_Case__r.Intake__r.Jurisdiction__c, CreatedBy.Name,
                                                              Placement__r.Begin_Date__c, Placement__r.Provider__r.Name, Placement__r.Provider__r.BillingAddress,
                                                              Placement__r.Placement_Structure__c, Placement__r.End_Date__c, caseworker_Service_EndDate__c, caseworker_Service_StartDate__c,
                                                              Date_of_last_Progress_Report__c, Describe_the_parent_current_relationship__c, Discuss_how_the_worker_is_addressing__c, Discuss_parent_child_interaction__c,
                                                              Discuss_the_visitation_plan__c, Follow_up_information_on_court_orders__c, List_mandates_of_court_order_pertaining__c, Referral_Made_to_Adoptuskids__c,
                                                              What_services_are_being_provided__c,What_services_provided_to_eliminate__c, What_services_have_we_identified__c, Health_Passport__c,
                                                              Day_Care__c, Reimbursement_for_Expenses__c, Transportation__c, Discussion_of_Visitation_Date__c, Financial_Support__c, Emotional_Support_or_Guidance__c,
                                                              Special_Training__c, Other__c, Discussion_of_Childs_Needs__c, If_Other__c, Respite_Care__c, Discuss_each_checked_iteam__c, Is_the_child_co_committed__c,
                                                              Has_youth_experienced_any_episodes__c, Has_the_youth_experienced_Explain__c, Has_youth_had_involvement__c, Parent_Name__c,
                                                              Child_IN_Out_Of_Home_Placement__c, State_Compelling_Reason__c, Date_TPR_Petition_Filed__c, Date_of_Voluntary_signature_Mother__c, Date_of_Voluntary_signature_Father__c,
                                                              Date_TPR_Granted__c, Date_TPR_Denied__c, Date_TPR_Appeal_Filed_Father__c, Date_TPR_Appeal_Filed_Mother__c, TPR_Appeal_Decision_Father__c,
                                                              TPR_Appeal_Decision_Mother__c, Was_the_child_enrolled_in_school__c, Is_this_school_placement__c, Has_the_child_changed_school__c,
                                                              Best_interest_to_change_schools__c, Discuss_the_appropriateness__c, What_Educational_services__c, If_child_is_pre_school_age__c,
                                                              Child_current_report_card__c, Individual_Education_Program__c, Educational_Parent_Name__c, Educational_Parent_Address__c, Educational_Parent_Requested__c,
                                                              At_or_near_age_level__c, Behavioral_problems__c, Problems_with_peers__c, Strengths__c, Weakness__c, Describe_the_child_strengths__c,
                                                              Child_is_between_18_and_21_years_old__c, Does_the_child_have_any_diagnosed__c, Homelessness_during_reporting_period__c, Length_Of_Time_Child_Was_Homeless__c,
                                                              Will_Youth_Require_Supportive_Services__c	, Discuss_Services_Youth_Will_Require__c, Passport_Record_Confirmation__c,
                                                              Dates_Confirmed__c, Notes__c, Placement__r.Child__c,
                                                              Child_Support_Referral_Date__c, Child_Support_Order_Been_Established__c 
                                                              FROM Case_Plan__c WHERE Id =:casePlanVersionId AND Placement__r.Child__c != null AND Placement__r.Service_Case__r.Intake__c != null AND Placement__r.Provider__c != null LIMIT :Utility.queryLimit];
            
            
            String childName = PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Child__r.Name;
            List<Medication_Including_Psychotropic__c> medicationRecords = new List<Medication_Including_Psychotropic__c>();
            if(PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Child__c !=null) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Is_Client_Prescribed_Medication__c, Medication_Name__c, Frequency__c, Start_Date__c, End_Date__c, Reason_Prescribed__c','view','Medication_Including_Psychotropic__c', Boolean.valueOf(Label.HasNamespace));
                medicationRecords = [SELECT Id, Is_Client_Prescribed_Medication__c, Medication_Name__c, Frequency__c, Start_Date__c,
                                     End_Date__c, Reason_Prescribed__c FROM Medication_Including_Psychotropic__c WHERE Contact__c =:PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Child__c LIMIT :Utility.queryLimit];
            }
            if(medicationRecords.size()>0) {
                PermanencyProgressRec.medicationRecords = medicationRecords;
            }
            
            if (PermanencyProgressRec.PermanencyProgressRecord.Id != null) {
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Discuss_how_the_caregiver_is_meeting__c, Discuss_and_explain_changes_in_the_child__c,'
                                                              +'If_the_Permanency_plan_is_to_return_home__c, Document_what_steps_have_been_taken__c, Describe_how_the_worker_is_ensuring__c,'
                                                              +'What_efforts_were_made_to_promote__c, Has_a_Lifebook_been_prepared__c, Describe_the_parent_s_compliance__c, Placement__c', 'view', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
                
                List<Permanency_Plan__c> PermanencyPlanRec= [SELECT Id, Discuss_how_the_caregiver_is_meeting__c, Discuss_and_explain_changes_in_the_child__c,
                                                             If_the_Permanency_plan_is_to_return_home__c, Document_what_steps_have_been_taken__c, Describe_how_the_worker_is_ensuring__c,
                                                             What_efforts_were_made_to_promote__c, Has_a_Lifebook_been_prepared__c, Describe_the_parent_s_compliance__c,
                                                             Primary_Permanency_Plan__c, Concurrent_Permanency_Plan__c, Plan_Established_Date__c
                                                             FROM Permanency_Plan__c WHERE Placement__c =:PermanencyProgressRec.PermanencyProgressRecord.Placement__c   ORDER BY CreatedDate DESC LIMIT 1];
                if (PermanencyPlanRec.size() >0) {
                    PermanencyProgressRec.PermanencyPlanRecord = PermanencyPlanRec[0];
                }
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Contact_Date__c, Contact_Type__c, Involved_Persons__c', 'view', 'Notes__c',  Boolean.valueOf(Label.HasNamespace));
                
                List<Notes__c> notesRecords = [SELECT Id, Contact_Date__c FROM Notes__c WHERE Contact_Type__c ='Face to Face' AND Involved_Persons__c  INCLUDES(:childName) LIMIT :Utility.queryLimit];
                if (notesRecords.size() >0) {
                    PermanencyProgressRec.faceToFaceVisitsList = notesRecords;
                }
                FieldLevelSecurity.checkFieldAccessByCriteria('Assessment_Type__c, SAFEC_Child_is_conditionally_Safe__c, SAFEC_Child_is_Conditionally_Safe_17_16__c, FINAL_RISK_LEVEL__c,Approval_Status__c,'
                                                              +'SAFEC_Child_is_Safe_Influences_1_18__c, SAFEC_Child_is_UnSafe__c, OHP_Child_is_Safe_Influences_1_12_Marked__c, Service_Case__c, OHP_Child_is_Unsafe_Any_Influence_1_12__c,'
                                                              +'RISK_LEVEL__c', 'view', 'Assessment__c',  Boolean.valueOf(Label.HasNamespace));
                
                PermanencyProgressRec.assessmentRecordList = [SELECT Id, Assessment_Type__c, SAFEC_Child_is_conditionally_Safe__c, SAFEC_Child_is_Conditionally_Safe_17_16__c, FINAL_RISK_LEVEL__c,
                                                              SAFEC_Child_is_Safe_Influences_1_18__c, SAFEC_Child_is_UnSafe__c, OHP_Child_is_Safe_Influences_1_12_Marked__c, OHP_Child_is_Unsafe_Any_Influence_1_12__c,
                                                              RISK_LEVEL__c FROM Assessment__c WHERE Approval_Status__c ='Approved' AND Service_Case__c =:PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Service_Case__c LIMIT :Utility.queryLimit];
                FieldLevelSecurity.checkFieldAccessByCriteria('TargetObjectId,CompletedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));

                List<ProcessInstance> assessmentCompletedDate = [SELECT CompletedDate, TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN  : PermanencyProgressRec.assessmentRecordList LIMIT :Utility.queryLimit];
                if (assessmentCompletedDate.size() >0) {
                    PermanencyProgressRec.assessmentRecordCompletedDate = assessmentCompletedDate;
                }
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Primary_Caregiver__c,Autism_Spectrum_Disorder__c, Child__c,'
                                                              +'Autism_Start_Diagnosis_Date__c, Autism_End_Resolution_Date__c, Cognitive_Developmental_Delay__c, Cognitive_Start_Diagnosis_Date__c,'
                                                              +'Cognitive_End_Resolution_Date__c, Emotionally_Disturbed__c, Emotionally_Start_Diagnosis_Date__c,Emotionally_End_Resolution_Date__c,'
                                                              +'Hearing_Disability__c, Hearing_Star_Diagnosis_Date__c, Hearing_End_Resolution_Date__c, Intellectual_Disability__c,'
                                                              +'Intellectual_Start_Diagnosis_Date__c, Intellectual_End_Resolution_Date__c, Other_Disability__c, Other_Start_Diagnosis_Date__c,'
                                                              +'Other_End_Resolution_Date__c, Physical_Disability__c, Physical_Start_Diagnosis_Date__c, Physical_End_Resolution_Date__c,'
                                                              +'Visual_Disability__c, Visual_Start_Diagnosis_Date__c, Visual_End_Resolution_Date__c', 'view', 'Child_Removal__c',  Boolean.valueOf(Label.HasNamespace));
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Name, Date_of_Birth__c, SSN__c, Address_Line_1__c,'
                                                              +'Address_Line_2__c , City__c, State__c, Zip_Code__c, County_Address__c' , 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
                
                List<Child_Removal__c> childRemovalRec = [SELECT Id, Primary_Caregiver__r.Name, Primary_Caregiver__r.Date_of_Birth__c, Primary_Caregiver__r.SSN__c,
                                                          Primary_Caregiver__r.Address_Line_1__c, Primary_Caregiver__r.Address_Line_2__c, Primary_Caregiver__r.City__c,
                                                          Primary_Caregiver__r.State__c, Primary_Caregiver__r.Zip_Code__c, Primary_Caregiver__r.County_Address__c, Autism_Spectrum_Disorder__c,
                                                          Autism_Start_Diagnosis_Date__c, Autism_End_Resolution_Date__c, Cognitive_Developmental_Delay__c, Cognitive_Start_Diagnosis_Date__c,
                                                          Cognitive_End_Resolution_Date__c, Emotionally_Disturbed__c, Emotionally_Start_Diagnosis_Date__c,Emotionally_End_Resolution_Date__c	,
                                                          Hearing_Disability__c, Hearing_Star_Diagnosis_Date__c, Hearing_End_Resolution_Date__c, Intellectual_Disability__c,
                                                          Intellectual_Start_Diagnosis_Date__c, Intellectual_End_Resolution_Date__c, Other_Disability__c, Other_Start_Diagnosis_Date__c,
                                                          Other_End_Resolution_Date__c, Physical_Disability__c, Physical_Start_Diagnosis_Date__c, Physical_End_Resolution_Date__c,
                                                          Visual_Disability__c, Visual_Start_Diagnosis_Date__c, Visual_End_Resolution_Date__c FROM Child_Removal__c
                                                          WHERE Child__c=: PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Child__c LIMIT :Utility.queryLimit];
                if (childRemovalRec.size() >0) {
                    PermanencyProgressRec.childRemovalRecord = childRemovalRec[0];
                }
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Income_Source__c, Monthly_Income__c, Entry_Date__c, Contact__c', 'view', 'Person_Incomes__c',  Boolean.valueOf(Label.HasNamespace));                
                List <Person_Incomes__c> incomeRec = [SELECT Id, Income_Source__c, Monthly_Income__c, Entry_Date__c FROM Person_Incomes__c 
                                                      WHERE Contact__c=: PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Child__c ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
                if (incomeRec.size() >0) {
                    PermanencyProgressRec.incomeRecord = incomeRec;
                }
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Asset_Type__c, Market_Value__c, Entry_Date__c , Contact__c', 'view', 'Asset__c',  Boolean.valueOf(Label.HasNamespace));                                
                
                List<Asset__c> assetRec = [SELECT Id, Asset_Type__c, Market_Value__c, Entry_Date__c FROM Asset__c 
                                           WHERE Contact__c=: PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Child__c ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
                if (assetRec.size() >0) {
                    PermanencyProgressRec.assetRecord = assetRec;
                }
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Nature_of_Exam__c, Appointment_Date__c, Physician_Name__c, Address_Line_1__c,'
                                                              +'Address_Line_2__c, City__c, State__c, Country__c, Zip_Code__c, Contact__c', 'view', 'Examination__c',  Boolean.valueOf(Label.HasNamespace));                                                
                
                List<Examination__c> ExamRec = [SELECT Id, Nature_of_Exam__c, Appointment_Date__c, Physician_Name__c, Address_Line_1__c,
                                                Address_Line_2__c, City__c, State__c, Country__c, Zip_Code__c FROM Examination__c 
                                                WHERE Contact__c=: PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Child__c AND (Nature_of_Exam__c ='Initial Health Examination'OR
                                                                                                                                             Nature_of_Exam__c ='Annual Health Examination' OR Nature_of_Exam__c ='Follow-up Health Examination') LIMIT :Utility.queryLimit];
                
                if(ExamRec.size()>0) {
                    for(Examination__c Rec : ExamRec) {
                        if(Rec.Nature_of_Exam__c == 'Initial Health Examination') {
                            PermanencyProgressRec.initialExamList.add(Rec);
                        } else if(Rec.Nature_of_Exam__c == 'Annual Health Examination') {
                            PermanencyProgressRec.finalExamList.add(Rec);
                        } else if(Rec.Nature_of_Exam__c == 'Follow-up Health Examination') {
                            PermanencyProgressRec.followupExamList.add(Rec);
                        }
                    }
                }
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Type_of_Class__c, School_Setting__c, Date_Last_Attended__c, Work_Phone_Number__c, Current_Grade__c,'
                                                              +'Education_End_Date__c, Contact__c', 'view', 'Education__c',  Boolean.valueOf(Label.HasNamespace));                                                
                
                List<Education__c> educationRec = [SELECT Id, Type_of_Class__c, School_Setting__c, Date_Last_Attended__c, Work_Phone_Number__c, Current_Grade__c,
                                                   Education_End_Date__c FROM Education__c WHERE Contact__c=: PermanencyProgressRec.PermanencyProgressRecord.Placement__r.Child__c LIMIT :Utility.queryLimit];
                if (educationRec.size() >0) {
                    PermanencyProgressRec.educationRecords = educationRec;
                }
            }
            return JSON.serialize(PermanencyProgressRec);
            
        } else {
            
            return null;
        }
    }
    
    @AuraEnabled
    public static String updatePermanencyProgressRecord(String permanencyProgressDataJSON) {
        
        if (String.isNotBlank(permanencyProgressDataJSON)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('caseworker_Service_EndDate__c, caseworker_Service_StartDate__c,'
                                                          +'Date_of_last_Progress_Report__c, Describe_the_parent_current_relationship__c,'
                                                          +'Discuss_how_the_worker_is_addressing__c, Discuss_parent_child_interaction__c,'
                                                          +'Discuss_the_visitation_plan__c, Follow_up_information_on_court_orders__c, List_mandates_of_court_order_pertaining__c, Referral_Made_to_Adoptuskids__c,'
                                                          +'What_services_are_being_provided__c,What_services_provided_to_eliminate__c, What_services_have_we_identified__c, Health_Passport__c,'
                                                          +'Day_Care__c, Reimbursement_for_Expenses__c, Transportation__c, Discussion_of_Visitation_Date__c, Financial_Support__c, Emotional_Support_or_Guidance__c,'
                                                          +'Special_Training__c, Other__c, Discussion_of_Childs_Needs__c, If_Other__c, Respite_Care__c, Discuss_each_checked_iteam__c, Is_the_child_co_committed__c,'
                                                          +'Has_youth_experienced_any_episodes__c, Has_the_youth_experienced_Explain__c, Has_youth_had_involvement__c, Parent_Name__c,'
                                                          +'Child_IN_Out_Of_Home_Placement__c, State_Compelling_Reason__c, Date_TPR_Petition_Filed__c,'
                                                          +'Date_of_Voluntary_signature_Mother__c, Date_of_Voluntary_signature_Father__c,'                                                              
                                                          +'Date_TPR_Granted__c, Date_TPR_Denied__c, Date_TPR_Appeal_Filed_Father__c, Date_TPR_Appeal_Filed_Mother__c, TPR_Appeal_Decision_Father__c,'
                                                          +'TPR_Appeal_Decision_Mother__c, Was_the_child_enrolled_in_school__c, Is_this_school_placement__c, Has_the_child_changed_school__c,'
                                                          +'Best_interest_to_change_schools__c, Discuss_the_appropriateness__c, What_Educational_services__c, If_child_is_pre_school_age__c,'
                                                          +'Child_current_report_card__c, Individual_Education_Program__c, Educational_Parent_Name__c, Educational_Parent_Address__c, Educational_Parent_Requested__c,'
                                                          +'At_or_near_age_level__c, Behavioral_problems__c, Problems_with_peers__c, Strengths__c, Weakness__c, Describe_the_child_strengths__c,'
                                                          +'Child_is_between_18_and_21_years_old__c, Does_the_child_have_any_diagnosed__c, Homelessness_during_reporting_period__c, Length_Of_Time_Child_Was_Homeless__c,'
                                                          +'Will_Youth_Require_Supportive_Services__c	, Discuss_Services_Youth_Will_Require__c, Passport_Record_Confirmation__c,'
                                                          +'Dates_Confirmed__c, Notes__c, Child_Support_Referral_Date__c, Child_Support_Order_Been_Established__c ', 'update', 'Case_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            
            Case_Plan__c updatePermanencyProgressRec = (Case_Plan__c) JSON.deserialize(permanencyProgressDataJSON, Case_Plan__c.class);
            update updatePermanencyProgressRec;
            return updatePermanencyProgressRec.Id;
        } else { 
            return null;
        }
    }
    
    
    @AuraEnabled
    public static String getServicePlanRecord(String casePlanId) {
        
        CasePlanVersion servicePlanVersionRec = new CasePlanVersion();
        set<Id> servicePlanId = new set<Id>();
        
        if (String.isNotBlank(casePlanId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c', 'view', 'Case_Plan__c',  Boolean.valueOf(Label.HasNamespace));                
            FieldLevelSecurity.checkFieldAccessByCriteria('Child__c, Service_Case__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));                
            
            Case_Plan__c casePlanRec = [SELECT Id, Placement__r.Child__c, Placement__r.Service_Case__c FROM Case_Plan__c WHERE Id =:casePlanId LIMIT :Utility.queryLimit];
            
            if (casePlanRec.Placement__r.Child__c != null) {
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Child_Name__c, Service_Plan__c, Child_Name__c', 'view', 'Candidacy__c',  Boolean.valueOf(Label.HasNamespace));                
                FieldLevelSecurity.checkFieldAccessByCriteria('Name, Target_End_Date__c, Completion_Date__c, Start_Date__c', 'view', 'Service_Plan__c',  Boolean.valueOf(Label.HasNamespace));                
                
                servicePlanVersionRec.servicePlanRecord  = [SELECT Id, Child_Name__c, Service_Plan__c, Service_Plan__r.Name, Service_Plan__r.Target_End_Date__c, Service_Plan__r.Completion_Date__c, 
                                                            Service_Plan__r.Start_Date__c FROM Candidacy__c 
                                                            WHERE Child_Name__c =:casePlanRec.Placement__r.Child__c AND Service_Plan__r.Service_Case__c =:casePlanRec.Placement__r.Service_Case__c LIMIT :Utility.queryLimit];
            }
            
            for (Candidacy__c Rec : servicePlanVersionRec.servicePlanRecord) {
                
                servicePlanId.add(Rec.Service_Plan__c);
                
            }
            
            if (servicePlanVersionRec.servicePlanRecord.size() >0) {
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Persons_Benefitizing__c, Service_Plan__c, Name', 'view', 'Service_Plan_Version__c',  Boolean.valueOf(Label.HasNamespace));                
                servicePlanVersionRec.servicePlanVersionRecord = [SELECT Id, Persons_Benefitizing__c, Name, Service_Plan__c FROM Service_Plan_Version__c WHERE Service_Plan__c IN : servicePlanId LIMIT :Utility.queryLimit];
            }
            return JSON.serialize(servicePlanVersionRec);
            
        } else {
            
            return null;
        }
    }
    
    @AuraEnabled
    public static String getYouthTransitionPlanRecords(String casePlanId) {
        
        CasePlanVersion youthTransitionPlanRec = new CasePlanVersion();
        if (String.isNotBlank(casePlanId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c', 'view', 'Case_Plan__c',  Boolean.valueOf(Label.HasNamespace));                
            FieldLevelSecurity.checkFieldAccessByCriteria('Child__c, Service_Case__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));                
            
            Case_Plan__c casePlanRec = [SELECT Id, Placement__r.Child__c, Placement__r.Service_Case__c FROM Case_Plan__c WHERE Id =:casePlanId LIMIT :Utility.queryLimit];
            
            if (casePlanRec.Placement__r.Child__c != null) {
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Name , Transition_Plan_Completed_Date__c, Status__c, Contact__c ', 'view', 'Youth_Transition_Plan__c',  Boolean.valueOf(Label.HasNamespace));                
                FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));                
                
                List<Youth_Transition_Plan__c> youthTransitionPlanRecord = new List<Youth_Transition_Plan__c>();
                youthTransitionPlanRecord  = [SELECT Id, Name , Transition_Plan_Completed_Date__c, Contact__r.Name, CreatedDate, Status__c FROM Youth_Transition_Plan__c 
                                              WHERE Contact__c =:casePlanRec.Placement__r.Child__c AND Service_Case__c =:casePlanRec.Placement__r.Service_Case__c LIMIT :Utility.queryLimit];
                
                if(youthTransitionPlanRecord.size()>0) {             
                    youthTransitionPlanRec.youthTransitionPlanList=youthTransitionPlanRecord;
                }
            }
            
            return JSON.serialize(youthTransitionPlanRec);
            
        } else {
            
            return null;
        }
    }
    public class CasePlanVersion { 
        @AuraEnabled
        public List<Placement__c> placementTableRecord;
        @AuraEnabled
        public List<Case_Plan__c> casePlanRecords;
        @AuraEnabled
        public Placement__c placementRecord;
        @AuraEnabled
        public List<Case_Plan__c>casePlanVersionRecords;
        @AuraEnabled
        public Case_Plan__c PermanencyProgressRecord;
        @AuraEnabled
        public Permanency_Plan__c PermanencyPlanRecord;
        @AuraEnabled
        public List<Assessment__c> assessmentRecordList;
        @AuraEnabled
        public Child_Removal__c childRemovalRecord;
        @AuraEnabled
        public List<Person_Incomes__c> incomeRecord;
        @AuraEnabled
        public List<Asset__c> assetRecord;
        @AuraEnabled
        public List<ProcessInstance> assessmentRecordCompletedDate;
        @AuraEnabled 
        public List<Candidacy__c> servicePlanRecord;
        @AuraEnabled
        public List<Service_Plan_Version__c> servicePlanVersionRecord;
        @AuraEnabled
        public List<Youth_Transition_Plan__c> youthTransitionPlanList;
        @AuraEnabled
        public List<Examination__c> initialExamList;
        @AuraEnabled
        public List<Examination__c> finalExamList;
        @AuraEnabled
        public List<Examination__c> followupExamList;
        @AuraEnabled
        public List<Education__c> educationRecords;
        @AuraEnabled
        public List<Notes__c> faceToFaceVisitsList;
        @AuraEnabled
        public List<Medication_Including_Psychotropic__c> medicationRecords;
        
        public CasePlanVersion() {
            PermanencyProgressRecord = new Case_Plan__c();
            PermanencyPlanRecord = new Permanency_Plan__c();
            incomeRecord = new List<Person_Incomes__c>();
            childRemovalRecord = new Child_Removal__c();
            assessmentRecordList = new List<Assessment__c>();
            assetRecord = new List<Asset__c>();
            servicePlanRecord = new List<Candidacy__c>();
            servicePlanVersionRecord = new List<Service_Plan_Version__c>();
            initialExamList = new List<Examination__c>();
            finalExamList = new List<Examination__c>();
            followupExamList = new List<Examination__c>();
            educationRecords = new List<Education__c>();
            faceToFaceVisitsList = new List<Notes__c>();
            youthTransitionPlanList = new List<Youth_Transition_Plan__c>();
            medicationRecords = new List<Medication_Including_Psychotropic__c>();
            
        }
    }    
    
    public class socialHistoryRecord {
        @AuraEnabled
        public String childName;
        @AuraEnabled
        Public Date removalDate;
        @AuraEnabled
        Public Date DOB;
        @AuraEnabled
        Public String gender;
        @AuraEnabled
        Public String clientId;
        @AuraEnabled
        Public String reasonableEffort;
        @AuraEnabled
        Public String race;
        @AuraEnabled
        Public String religion;
        @AuraEnabled
        Public String ssn;
        @AuraEnabled
        Public String applicant = '';
        @AuraEnabled
        Public String coApplicant = '';
        @AuraEnabled
        Public String addressofPrimaryCaregiver;
        @AuraEnabled
        Public Datetime safecCompletionDate;
        @AuraEnabled
        Public Datetime riskReassessmentCompletionDate;
        
    }
}