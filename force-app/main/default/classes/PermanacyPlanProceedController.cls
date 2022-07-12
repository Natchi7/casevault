public with sharing class PermanacyPlanProceedController {

    @AuraEnabled
    public static Suspension__c deleteSuspensionRec(String suspensionJSONRec) {
    
        if (String.isNotBlank(suspensionJSONRec)) {
        
            Suspension__c deletesuspensionRec = (Suspension__c) JSON.deserialize(suspensionJSONRec, Suspension__c.class);
            FieldLevelSecurity.checkObjectAccessByDelete('Suspension__c');
            delete deletesuspensionRec;
            return deletesuspensionRec;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getApplicationInitialInformation(String permanencyPlanId) {
    
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.GurdianRelationPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Primary_Guardian_Relationship__c',false);
        if (String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c,'+
                                             'Guardian_One_Name__c, Guardian_Two_Name__c,'+
                                             'Guardian_One_SSN__c, Guardian_Two_SSN__c, Primary_Guardian_Relationship__c,'+ 
                                             'Guardian_Two_DOB__c, Guardian_One_DOB__c, Secondary_Guardian_Relationship__c,'+
                                             'Guardianship_Planing__c, Application_Understands__c, Application_Reunification_has_been_ruled__c,'+
                                             'approved_as_a_resource_home_for_6_Month__c, Caregiver_completed_a_comprehensive__c,'+
                                             'Criminal_Child_Protective_Clearances__c,If_the_Permanency_plan_is_to_return_home__c,'+ 
                                             'Authorization_for_Release_of_Health__c, commitment_Caring_Permanently_for_Child__c,'+
                                             'Is_Willing_to_Provide_Safe_Stable_Home__c, Provide_primary_care_supervision_of_kid__c,'+
                                             'Complete_Annual_Reconsideration__c, Independent_means_of_financial_support__c,'+
                                             'Social_Security_child_support_benefits__c, Application_Receipt_of_Social_Security__c,'+ 
                                             'Change_In_Placement_and_or_Circumstances__c, Continue_the_Guardianship_Assistance_Pay__c,'+ 
                                             'Guardianship_Assistance_can_Suspended__c, Caseworker_Requirement_and_Expectations__c,'+ 
                                             'Date_of_Planning_Meeting__c, Guardian_Two_Date__c, LDSS_Director_Designee__c', 'view', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Provider_Type__c,CPA_Home_Id__c,Provider__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_ProID__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.permanencyPlanRecord = [SELECT Id, Placement__c, Placement__r.Provider_Type__c, Placement__r.CPA_Home_Id__c, Placement__r.Provider__c,
                                             Placement__r.Provider__r.Casevault_ProID__c,
                                             Placement__r.Provider__r.BillingStreet, Placement__r.Provider__r.BillingCity,
                                             Placement__r.Provider__r.BillingState, Placement__r.Provider__r.BillingPostalCode,
                                             Placement__r.Provider__r.BillingCountry, Guardian_One_Name__c, Guardian_Two_Name__c,
                                             Guardian_One_SSN__c, Guardian_Two_SSN__c, Primary_Guardian_Relationship__c, 
                                             Guardian_Two_DOB__c, Guardian_One_DOB__c, Secondary_Guardian_Relationship__c,
                                             Guardianship_Planing__c, Application_Understands__c, Application_Reunification_has_been_ruled__c,
                                             approved_as_a_resource_home_for_6_Month__c, Caregiver_completed_a_comprehensive__c,
                                             Criminal_Child_Protective_Clearances__c,If_the_Permanency_plan_is_to_return_home__c, 
                                             Authorization_for_Release_of_Health__c, commitment_Caring_Permanently_for_Child__c,
                                             Is_Willing_to_Provide_Safe_Stable_Home__c, Provide_primary_care_supervision_of_kid__c,
                                             Complete_Annual_Reconsideration__c, Independent_means_of_financial_support__c, 
                                             Social_Security_child_support_benefits__c, Application_Receipt_of_Social_Security__c, 
                                             Change_In_Placement_and_or_Circumstances__c, Continue_the_Guardianship_Assistance_Pay__c, 
                                             Guardianship_Assistance_can_Suspended__c, Caseworker_Requirement_and_Expectations__c, 
                                             Date_of_Planning_Meeting__c, Guardian_Two_Date__c, LDSS_Director_Designee__c
                                             FROM Permanency_Plan__c WHERE Id = :permanencyPlanId AND Placement__c!= null AND 
                                             Placement__r.Provider__c != null LIMIT 1];
                                
            if(initWrap.permanencyPlanRecord != null && (initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == 'Public_Provider' || initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == '')){
                FieldLevelSecurity.checkFieldAccessByCriteria('Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
                initWrap.applicantCoApplList = [SELECT Id, Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c 
                                                 FROM Contact WHERE AccountId = :initWrap.permanencyPlanRecord.Placement__r.Provider__c LIMIT :Utility.queryLimit
                 ];
            } else {   
                                       
                if(initWrap.permanencyPlanRecord != null && String.isNotBlank(initWrap.permanencyPlanRecord.Placement__r.CPA_Home_Id__c)) {
                
                    FieldLevelSecurity.checkFieldAccessByCriteria('Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
                    initWrap.applicantCoApplList = [SELECT Id, Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c 
                                            FROM Contact WHERE AccountId = :initWrap.permanencyPlanRecord.Placement__r.CPA_Home_Id__c LIMIT :Utility.queryLimit];
                    FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_ProID__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
    
                    Account cpaHomeProvider= [SELECT Id,Casevault_ProID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                                              FROM Account WHERE Id = :initWrap.permanencyPlanRecord.Placement__r.CPA_home_Id__c LIMIT :Utility.queryLimit];
                    initWrap.cpaProviderId = cpaHomeProvider;
                }
            }
        } 
        PermanacyPlanProceedController obj = new PermanacyPlanProceedController();
        initWrap.showApprovalBtn = obj.checkUserProfile();                         
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getDisclosureInitialInformation(String permanencyPlanId) {
    
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.disclosurePicklist = Utility.getPicklistinfo('Permanency_Plan__c','Disclosure_committed_to_the_State__c',false);
        if (String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Guardian_One_Name__c, Guardian_Two_Name__c, Guardian_One_SSN__c,'+
                                             'Guardian_Two_SSN__c,'+
                                             'Primary_Guardian_Relationship__c, Guardian_Two_DOB__c, Guardian_One_DOB__c, Secondary_Guardian_Relationship__c,'+
                                             'Guardianship_Planing__c, Disclosure_committed_to_the_State__c, Disclosure_Provider_is_Approved__c,'+ 
                                             'Disclosure_child_be_under_18_year_of_age__c, Reunification_and_Adoption_have_ruled__c,'+ 
                                             'Disclosure_Adoption_has_been_ruled_out__c, Disclosure_provide_safe_and_stable_home__c,'+ 
                                             'Disclosure_independent_mean_of_financial__c, Disclosure_orientation_meeting_or__c,'+ 
                                             'Disclosure_caseworker_discussed_require__c, Disclosure_participate_in_Guardianship__c,'+ 
                                             'Disclosure_agreement_prior_to_the_award__c, Disclosure_authorization_mental_health__c,'+ 
                                             'Disclosure_provide_aftercare_service__c, Disclosure_services_will_be_closed_after__c,'+ 
                                             'Disclosure_Annual_Reconsideration__c, Disclosure_Assistance_will_Immediately__c,'+ 
                                             'Disclosure_Age_Appropriate_Consultation__c, Disclosure_Attachment_primary_guardian__c,'+
                                             'Disclosure_to_the_secondary_guardian__c', 'view', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('CPA_Home_Id__c, Provider_Type__c', 'view', 'Placement__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry', 'view', 'Account', Boolean.valueOf(Label.HasNamespace));
    
            initWrap.permanencyPlanRecord = [SELECT Id, Placement__r.Provider__r.Casevault_ProID__c, Placement__r.CPA_Home_Id__c,
                                             Placement__r.Provider_Type__c, Guardian_One_Name__c, Guardian_Two_Name__c, Guardian_One_SSN__c,
                                             Guardian_Two_SSN__c, Placement__r.Provider__r.BillingStreet, Placement__r.Provider__r.BillingCity,
                                             Placement__r.Provider__r.BillingState, Placement__r.Provider__r.BillingPostalCode,
                                             Placement__r.Provider__r.BillingCountry,
                                             Primary_Guardian_Relationship__c, Guardian_Two_DOB__c, Guardian_One_DOB__c, Secondary_Guardian_Relationship__c,
                                             Guardianship_Planing__c, Disclosure_committed_to_the_State__c, Disclosure_Provider_is_Approved__c, 
                                             Disclosure_child_be_under_18_year_of_age__c, Reunification_and_Adoption_have_ruled__c, 
                                             Disclosure_Adoption_has_been_ruled_out__c, Disclosure_provide_safe_and_stable_home__c, 
                                             Disclosure_independent_mean_of_financial__c, Disclosure_orientation_meeting_or__c, 
                                             Disclosure_caseworker_discussed_require__c, Disclosure_participate_in_Guardianship__c, 
                                             Disclosure_agreement_prior_to_the_award__c, Disclosure_authorization_mental_health__c, 
                                             Disclosure_provide_aftercare_service__c, Disclosure_services_will_be_closed_after__c, 
                                             Disclosure_Annual_Reconsideration__c, Disclosure_Assistance_will_Immediately__c, 
                                             Disclosure_Age_Appropriate_Consultation__c, Disclosure_Attachment_primary_guardian__c, 
                                             Disclosure_to_the_secondary_guardian__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId
                                             AND Placement__c != null AND Placement__r.Provider__c != null LIMIT 1];
            if(initWrap.permanencyPlanRecord != null && (initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == 'Public_Provider' || initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == '')){
                 FieldLevelSecurity.checkFieldAccessByCriteria('Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
                initWrap.applicantCoApplList = [SELECT Id, Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c 
                 FROM Contact WHERE AccountId = :initWrap.permanencyPlanRecord.Placement__r.Provider__c LIMIT :Utility.queryLimit
                 ];
            } else {                          
                if(initWrap.permanencyPlanRecord != null && String.isNotBlank(initWrap.permanencyPlanRecord.Placement__r.CPA_Home_Id__c)) {
                    FieldLevelSecurity.checkFieldAccessByCriteria('Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
    
                    initWrap.applicantCoApplList = [SELECT Id, Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c 
                                            FROM Contact WHERE AccountId = :initWrap.permanencyPlanRecord.Placement__r.CPA_Home_Id__c LIMIT :Utility.queryLimit];
                    FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_ProID__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
    
                    Account cpaHomeProvider= [SELECT Id,Casevault_ProID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                                              FROM Account WHERE Id = :initWrap.permanencyPlanRecord.Placement__r.CPA_home_Id__c LIMIT :Utility.queryLimit];
                    initWrap.cpaProviderId = cpaHomeProvider;
                }
                
            }
        }
        PermanacyPlanProceedController obj = new PermanacyPlanProceedController();
        initWrap.showApprovalBtn = obj.checkUserProfile(); 
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getAgreementInitialInformation(String permanencyPlanId) {
    
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.rateTypePicklist = Utility.getPicklistinfo('Rate__c','Rate_Type__c',false);
        initWrap.hasNotificationPicklist = Utility.getPicklistinfo('Rate__c', 'Has_notification_been_sent_to_TCA__c',false);
        initWrap.childsupportPicklist = Utility.getPicklistinfo('Rate__c', 'Child_support_has_been_notified__c',false);
        initWrap.isChildreceivingTCAPicklist = Utility.getPicklistinfo('Rate__c', 'Is_Child_receiving_TCA__c',false);
        if (String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Guardian_One_Name__c, Guardian_Two_Name__c, Guardian_One_SSN__c, Guardian_Two_SSN__c, Primary_Guardian_Relationship__c, Guardian_Two_DOB__c, Guardian_One_DOB__c, Secondary_Guardian_Relationship__c, Guardianship_Planing__c, Agreement_Start_Date__c, Agreement_End_Date__c, Agreement_Caregiver_completed__c,'+
                                            'The_caregiver_awarded_custody__c, All_Placements_and_Removal_have_been_End__c,'+
                                            'Agrrement_Guardian_One_Date__c, Guardian_Two_Date__c, Agreement_LDSS_Director_Designee__c, Is_Child_receiving_TCA__c, TCA_Amount__c, Has_notification_been_sent_to_TCA__c, Child_support_has_been_notified__c', 'view', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Provider__c,End_Date__c,Provider_Type__c,CPA_Home_Id__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_ProID__c', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.permanencyPlanRecord = [SELECT Id, Placement__r.Provider__c,Placement__r.End_Date__c, Placement__r.Provider__r.Casevault_ProID__c, Guardian_One_Name__c, Guardian_Two_Name__c, Guardian_One_SSN__c, Guardian_Two_SSN__c, Primary_Guardian_Relationship__c, Guardian_Two_DOB__c, Guardian_One_DOB__c, Secondary_Guardian_Relationship__c, Guardianship_Planing__c, Agreement_Start_Date__c, Agreement_End_Date__c, Agreement_Caregiver_completed__c, 
                                            Placement__r.Provider_Type__c, Placement__r.CPA_Home_Id__c, The_caregiver_awarded_custody__c, All_Placements_and_Removal_have_been_End__c,
                                            Agrrement_Guardian_One_Date__c, Guardian_Two_Date__c, Agreement_LDSS_Director_Designee__c, Is_Child_receiving_TCA__c, TCA_Amount__c, Has_notification_been_sent_to_TCA__c, Child_support_has_been_notified__c FROM Permanency_Plan__c
                                            WHERE Id = :permanencyPlanId AND Placement__c != null AND Placement__r.Provider__c != null LIMIT 1];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Provider_Id__c, Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c,'+ 
                                'Negotiated_Amount__c, Negotiated_Date__c, Notes__c, Is_Child_receiving_TCA__c,Permanency_Plan__c,'+
                                'TCA_Amount__c, Has_notification_been_sent_to_TCA__c, Child_support_has_been_notified__c, Approval_Status__c', 'view', 'Rate__c',  Boolean.valueOf(Label.HasNamespace));
            
            initWrap.rateRecList = [SELECT Id, Provider_Id__c, Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c, 
                                Negotiated_Amount__c, Negotiated_Date__c, Notes__c, Is_Child_receiving_TCA__c,Permanency_Plan__c,
                                TCA_Amount__c, Has_notification_been_sent_to_TCA__c, Child_support_has_been_notified__c, Approval_Status__c FROM Rate__c 
                                WHERE Permanency_Plan__c = :permanencyPlanId ORDER BY LastModifiedDate DESC LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c,'+ 
                                'Negotiated_Amount__c, Negotiated_Date__c, Notes__c, Is_Child_receiving_TCA__c,Permanency_Plan__c,'+
                                'TCA_Amount__c, Has_notification_been_sent_to_TCA__c, Child_support_has_been_notified__c, Approval_Status__c', 'view', 'Rate__c',  Boolean.valueOf(Label.HasNamespace));
           
            initWrap.existingRateRec = [SELECT Id, Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c, 
                                Negotiated_Amount__c, Negotiated_Date__c, Notes__c, Is_Child_receiving_TCA__c,Permanency_Plan__c,
                                TCA_Amount__c, Has_notification_been_sent_to_TCA__c, Child_support_has_been_notified__c, Approval_Status__c FROM Rate__c 
                                WHERE Permanency_Plan__c = :permanencyPlanId AND Approval_Status__c != 'Approved' ORDER BY LastModifiedDate DESC LIMIT 1];                    
            
            if(initWrap.permanencyPlanRecord != null && (initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == 'Public_Provider' || initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == '')){
                FieldLevelSecurity.checkFieldAccessByCriteria('Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c ', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace)); 
                initWrap.applicantCoApplList = [SELECT Id, Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c 
                 FROM Contact WHERE AccountId = :initWrap.permanencyPlanRecord.Placement__r.Provider__c LIMIT :Utility.queryLimit
                 ];
            } else {                          
                if(initWrap.permanencyPlanRecord != null && String.isNotBlank(initWrap.permanencyPlanRecord.Placement__r.CPA_Home_Id__c)) {
                    FieldLevelSecurity.checkFieldAccessByCriteria('Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c ', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace)); 
    
                    initWrap.applicantCoApplList = [SELECT Id, Name, Date_of_Birth__c, SSN__c, Applicant_or_Co_Applicant__c,No_Co_Applicant__c 
                                            FROM Contact WHERE AccountId = :initWrap.permanencyPlanRecord.Placement__r.CPA_Home_Id__c LIMIT :Utility.queryLimit];
                    FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_ProID__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
    
                    Account cpaHomeProvider= [SELECT Id,Casevault_ProID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                                              FROM Account WHERE Id = :initWrap.permanencyPlanRecord.Placement__r.CPA_home_Id__c LIMIT :Utility.queryLimit];
                    initWrap.cpaProviderId = cpaHomeProvider;
                }
                
            }
        }
        PermanacyPlanProceedController obj = new PermanacyPlanProceedController();
        initWrap.showApprovalBtn = obj.checkUserProfile();         
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getAnnuvalReviewsInitialInformation(String permanencyPlanId) {
    
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.annualReviewsPicklist = Utility.getPicklistinfo('Annual_Review__c','Guardian_is_legally_responsible__c',false);
        if (String.isNotBlank(permanencyPlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Guardianship_Planing__c', 'view', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            initWrap.permanencyPlanRecord = [SELECT Id, Guardianship_Planing__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Review_Date__c, Approval_Status__c', 'view','Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
            initWrap.annualReviewsList = [SELECT Id, Review_Date__c, Approval_Status__c FROM Annual_Review__c WHERE Permanency_Plan__c = :permanencyPlanId ORDER BY LastModifiedDate DESC LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Review_Date__c, Guardian_is_legally_responsible__c, Guardian_provides_financial_support__c, Child_currently_resides_with_guardian__c, Child_is_currently_attending_school__c, Is_the_requried_document__c, Will_the_child_reach_18th_birthday__c, Child_has_a_mental_or_physical__c, Child_is_enrolled_in_educational__c, Child_is_participating_in_a_program__c, Provide_a_field_to_indicate__c, Completed__c, Primary_Caregiver_Sign_Date__c, Secondary_Caregiver_Sign_Date__c, Director_Sign_Date__c, Approval_Status__c', 'view', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
            initWrap.existingAnnualReviewRec = [SELECT Id, Review_Date__c, Guardian_is_legally_responsible__c, Guardian_provides_financial_support__c, Child_currently_resides_with_guardian__c, Child_is_currently_attending_school__c, Is_the_requried_document__c, Will_the_child_reach_18th_birthday__c, Child_has_a_mental_or_physical__c, Child_is_enrolled_in_educational__c, Child_is_participating_in_a_program__c, Provide_a_field_to_indicate__c, Completed__c, Primary_Caregiver_Sign_Date__c, Secondary_Caregiver_Sign_Date__c, Director_Sign_Date__c, Approval_Status__c FROM Annual_Review__c WHERE Permanency_Plan__c = :permanencyPlanId AND Approval_Status__c != 'Approved' ORDER BY LastModifiedDate DESC LIMIT 1];
        }
        PermanacyPlanProceedController obj = new PermanacyPlanProceedController();
        initWrap.showApprovalBtn = obj.checkUserProfile(); 
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getSuspensionInitialInformation(String permanencyPlanId) {
    
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.suspensionReasonPicklist = Utility.getPicklistinfo('Suspension__c','Suspension_Reason__c',false);
        if (String.isNotBlank(permanencyPlanId)) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Suspension_Reason__c, Start_Date__c, End_Date__c, Notes__c, Permanency_Plan__c,Name, Approval_Status__c', 'view', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
            initWrap.suspensionList = [SELECT Suspension_Reason__c, Start_Date__c, End_Date__c, Notes__c, Permanency_Plan__c, Id, 
                     Name, Approval_Status__c FROM Suspension__c  WHERE Permanency_Plan__c = :permanencyPlanId ORDER By CreatedDate DESC LIMIT :Utility.queryLimit];
           
            FieldLevelSecurity.checkFieldAccessByCriteria('Guardianship_Planing__c', 'view', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            initWrap.permanencyPlanRecord = [SELECT Id, Guardianship_Planing__c FROM Permanency_Plan__c WHERE Id = :permanencyPlanId LIMIT :Utility.queryLimit];
           
            FieldLevelSecurity.checkFieldAccessByCriteria('Suspension_Reason__c, Start_Date__c, End_Date__c, Notes__c, Permanency_Plan__c,Name, Approval_Status__c', 'view', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
    
            initWrap.existingSuspensionRec = [SELECT Id, Suspension_Reason__c, Start_Date__c, End_Date__c, Notes__c, Permanency_Plan__c,
                                              Name, Approval_Status__c FROM Suspension__c WHERE Permanency_Plan__c = :permanencyPlanId AND Approval_Status__c != 'Approved' ORDER BY LastModifiedDate DESC LIMIT 1];
        } 
        PermanacyPlanProceedController obj = new PermanacyPlanProceedController();
        initWrap.showApprovalBtn = obj.checkUserProfile();                
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String addRateAnnualRec(String permanencyPlanId) {
    
        if (String.isNotBlank(permanencyPlanId)) {
            RateAnnualWrapper rateAnnualWrapperIns = new RateAnnualWrapper();
            FieldLevelSecurity.checkFieldAccessByCriteria('Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c, Approval_Status__c', 'view', 'Rate__c',  Boolean.valueOf(Label.HasNamespace));
            rateAnnualWrapperIns.rateRec = [SELECT Id, Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c, Approval_Status__c FROM Rate__c 
                                WHERE Permanency_Plan__c = :permanencyPlanId ORDER By LastmodifiedDate DESC LIMIT 1 ];
            if (rateAnnualWrapperIns.rateRec != null && rateAnnualWrapperIns.rateRec.size() > 0 ) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Review_Date__c, Approval_Status__c', 'view', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
                rateAnnualWrapperIns.annualReviewRec = [SELECT Id, Review_Date__c, Approval_Status__c FROM Annual_Review__c WHERE Permanency_Plan__c = :permanencyPlanId AND Review_Date__c = :rateAnnualWrapperIns.rateRec[0].Rate_End_Date__c ORDER By LastmodifiedDate DESC LIMIT 1];
            }
            return JSON.serialize(rateAnnualWrapperIns);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String addSuspensionRec(String permanencyPlanId) {
    
        if (String.isNotBlank(permanencyPlanId)) {
        
            List<Suspension__c> exstingSuspensionRec = new List<Suspension__c>();
            FieldLevelSecurity.checkFieldAccessByCriteria('End_Date__c, Suspension_Reason__c, Start_Date__c, Notes__c, Permanency_Plan__c, Name, Approval_Status__c', 'view', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
            exstingSuspensionRec = [SELECT Id, End_Date__c, Suspension_Reason__c, Start_Date__c, Notes__c, Permanency_Plan__c, Name, Approval_Status__c FROM Suspension__c WHERE Permanency_Plan__c = :permanencyPlanId ORDER BY LastModifiedDate DESC LIMIT 1];
            return JSON.serialize(exstingSuspensionRec);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String upsertSuspension(String suspensionDataJSON) {
    
        if (String.isNotBlank(suspensionDataJSON)) {
        
            Suspension__c createuspensionRec = (Suspension__c) JSON.deserialize(suspensionDataJSON, Suspension__c.class);
            if (String.isBlank(createuspensionRec.Id)) {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('Suspension_Reason__c,Start_Date__c,End_Date__c,Notes__c', 'create', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
                insert createuspensionRec;
            } else {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('Suspension_Reason__c,Start_Date__c,End_Date__c,Notes__c', 'update', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
                update createuspensionRec;
            }
            return createuspensionRec.Id;
        } else {
            return null;
        }        
    }
    
    @AuraEnabled
    public static String upsertApplication(String applicationDataJSON) {
    
        if (String.isNotBlank(applicationDataJSON)) { 
        
            Permanency_Plan__c createApplicationRec = (Permanency_Plan__c) JSON.deserialize(applicationDataJSON, Permanency_Plan__c.class);
            if (String.isBlank(createApplicationRec.Id)) {
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Guardian_One_DOB__c,Guardian_One_SSN__c,Guardian_One_Name__c,Primary_Guardian_Relationship__c,Guardian_Two_DOB__c,Guardian_Two_SSN__c,'+
                                                          'Guardian_Two_Name__c,Secondary_Guardian_Relationship__c,Application_Understands__c,Application_Reunification_has_been_ruled__c,approved_as_a_resource_home_for_6_Month__c,'+
                                                          'Caregiver_completed_a_comprehensive__c,Criminal_Child_Protective_Clearances__c,If_the_Permanency_plan_is_to_return_home__c,Authorization_for_Release_of_Health__c,commitment_Caring_Permanently_for_Child__c,'+
                                                          'Is_Willing_to_Provide_Safe_Stable_Home__c,Provide_primary_care_supervision_of_kid__c,Complete_Annual_Reconsideration__c,Independent_means_of_financial_support__c,'+
                                                          'Social_Security_child_support_benefits__c,Application_Receipt_of_Social_Security__c,Change_In_Placement_and_or_Circumstances__c,Continue_the_Guardianship_Assistance_Pay__c,'+
                                                          'Guardianship_Assistance_can_Suspended__c,Caseworker_Requirement_and_Expectations__c,Date_of_Planning_Meeting__c,Guardian_Two_Date__c,LDSS_Director_Designee__c', 'create', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
                FieldLevelSecurity.checkFieldAccessByCriteria('Guardian_One_Name__c,Primary_Guardian_Relationship__c,Guardian_Two_Name__c,Secondary_Guardian_Relationship__c,Disclosure_committed_to_the_State__c,Disclosure_Provider_is_Approved__c,Disclosure_child_be_under_18_year_of_age__c,'+
                                                          'Reunification_and_Adoption_have_ruled__c,Disclosure_Adoption_has_been_ruled_out__c,Disclosure_provide_safe_and_stable_home__c,Disclosure_independent_mean_of_financial__c,Disclosure_orientation_meeting_or__c,Disclosure_caseworker_discussed_require__c,'+
                                                          'Disclosure_participate_in_Guardianship__c,Disclosure_agreement_prior_to_the_award__c,Disclosure_authorization_mental_health__c,Disclosure_provide_aftercare_service__c,Disclosure_services_will_be_closed_after__c,Disclosure_Annual_Reconsideration__c,'+
                                                          'Disclosure_Assistance_will_Immediately__c,Disclosure_Age_Appropriate_Consultation__c,Disclosure_Attachment_primary_guardian__c,Disclosure_to_the_secondary_guardian__c', 'create', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
                                                          
                                                          
                insert createApplicationRec;
            } else {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('Guardian_One_DOB__c,Guardian_One_SSN__c,Guardian_One_Name__c,Primary_Guardian_Relationship__c,Guardian_Two_DOB__c,Guardian_Two_SSN__c,'+
                                                          'Guardian_Two_Name__c,Secondary_Guardian_Relationship__c,Application_Understands__c,Application_Reunification_has_been_ruled__c,approved_as_a_resource_home_for_6_Month__c,'+
                                                          'Caregiver_completed_a_comprehensive__c,Criminal_Child_Protective_Clearances__c,If_the_Permanency_plan_is_to_return_home__c,Authorization_for_Release_of_Health__c,commitment_Caring_Permanently_for_Child__c,'+
                                                          'Is_Willing_to_Provide_Safe_Stable_Home__c,Provide_primary_care_supervision_of_kid__c,Complete_Annual_Reconsideration__c,Independent_means_of_financial_support__c,'+
                                                          'Social_Security_child_support_benefits__c,Application_Receipt_of_Social_Security__c,Change_In_Placement_and_or_Circumstances__c,Continue_the_Guardianship_Assistance_Pay__c,'+
                                                          'Guardianship_Assistance_can_Suspended__c,Caseworker_Requirement_and_Expectations__c,Date_of_Planning_Meeting__c,Guardian_Two_Date__c,LDSS_Director_Designee__c', 'update', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
            
                FieldLevelSecurity.checkFieldAccessByCriteria('Guardian_One_Name__c,Primary_Guardian_Relationship__c,Guardian_Two_Name__c,Secondary_Guardian_Relationship__c,Disclosure_committed_to_the_State__c,Disclosure_Provider_is_Approved__c,Disclosure_child_be_under_18_year_of_age__c,'+
                                                          'Reunification_and_Adoption_have_ruled__c,Disclosure_Adoption_has_been_ruled_out__c,Disclosure_provide_safe_and_stable_home__c,Disclosure_independent_mean_of_financial__c,Disclosure_orientation_meeting_or__c,Disclosure_caseworker_discussed_require__c,'+
                                                          'Disclosure_participate_in_Guardianship__c,Disclosure_agreement_prior_to_the_award__c,Disclosure_authorization_mental_health__c,Disclosure_provide_aftercare_service__c,Disclosure_services_will_be_closed_after__c,Disclosure_Annual_Reconsideration__c,'+
                                                          'Disclosure_Assistance_will_Immediately__c,Disclosure_Age_Appropriate_Consultation__c,Disclosure_Attachment_primary_guardian__c,Disclosure_to_the_secondary_guardian__c', 'update', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
                                                          
                update createApplicationRec;
            }
            return createApplicationRec.Id;
        } else {
            return null;
        }
    }
        
    @AuraEnabled
    public static String upsertAnnualReviews(String annualReviewsDataJSON) {
    
        if (String.isNotBlank(annualReviewsDataJSON)) { 
        
            Annual_Review__c createAnnualReviewRec = (Annual_Review__c) JSON.deserialize(annualReviewsDataJSON, Annual_Review__c.class);
            if (String.isBlank(createAnnualReviewRec.Id)) {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('Review_Date__c, Guardian_is_legally_responsible__c, Guardian_provides_financial_support__c, Child_currently_resides_with_guardian__c, Child_is_currently_attending_school__c, Is_the_requried_document__c, Will_the_child_reach_18th_birthday__c, Child_has_a_mental_or_physical__c, Child_is_enrolled_in_educational__c, Child_is_participating_in_a_program__c, Provide_a_field_to_indicate__c, Completed__c, Primary_Caregiver_Sign_Date__c, Secondary_Caregiver_Sign_Date__c, Director_Sign_Date__c', 'create', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
                insert createAnnualReviewRec;
            } else {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('Review_Date__c, Guardian_is_legally_responsible__c, Guardian_provides_financial_support__c, Child_currently_resides_with_guardian__c, Child_is_currently_attending_school__c, Is_the_requried_document__c, Will_the_child_reach_18th_birthday__c, Child_has_a_mental_or_physical__c, Child_is_enrolled_in_educational__c, Child_is_participating_in_a_program__c, Provide_a_field_to_indicate__c, Completed__c, Primary_Caregiver_Sign_Date__c, Secondary_Caregiver_Sign_Date__c, Director_Sign_Date__c', 'update', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
                update createAnnualReviewRec;
            }
            return createAnnualReviewRec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String upsertAgreement(String permanencyPlanDataJSON, String rateDataJSON, Boolean isApproved) {
    
        
        //FieldLevelSecurity.checkFieldAccessByCriteria('Provider_Type__c,Provider__c', 'update', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        //FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_ProID__c', 'update', 'Account',  Boolean.valueOf(Label.HasNamespace));
        
        //FieldLevelSecurity.checkFieldAccessByCriteria('Provider_Type__c,Provider__c', 'create', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        //FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_ProID__c', 'create', 'Account',  Boolean.valueOf(Label.HasNamespace));
        
        if (!isApproved && String.isNotBlank(permanencyPlanDataJSON)) {
            Permanency_Plan__c createPermanencyPlanRec = (Permanency_Plan__c) JSON.deserialize(permanencyPlanDataJSON, Permanency_Plan__c.class);
            if (String.isBlank(createPermanencyPlanRec.Id)) {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c,Guardian_One_Name__c, Primary_Guardian_Relationship__c, Guardian_Two_Name__c, Secondary_Guardian_Relationship__c, Agreement_Start_Date__c, Agreement_End_Date__c, Agreement_Caregiver_completed__c, The_caregiver_awarded_custody__c, Agreement_Caregiver_completed__c,All_Placements_and_Removal_have_been_End__c, Agrrement_Guardian_One_Date__c, Agreement_LDSS_Director_Designee__c, Is_Child_receiving_TCA__c, TCA_Amount__c, Has_notification_been_sent_to_TCA__c, Child_support_has_been_notified__c', 'create', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
                insert createPermanencyPlanRec;
            } else {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('Placement__c,Guardian_One_Name__c, Primary_Guardian_Relationship__c, Guardian_Two_Name__c, Secondary_Guardian_Relationship__c, Agreement_Start_Date__c, Agreement_End_Date__c, Agreement_Caregiver_completed__c, The_caregiver_awarded_custody__c, Agreement_Caregiver_completed__c,All_Placements_and_Removal_have_been_End__c, Agrrement_Guardian_One_Date__c, Agreement_LDSS_Director_Designee__c, Is_Child_receiving_TCA__c, TCA_Amount__c, Has_notification_been_sent_to_TCA__c, Child_support_has_been_notified__c', 'update', 'Permanency_Plan__c',  Boolean.valueOf(Label.HasNamespace));
                update createPermanencyPlanRec;
            }
        }
        if (String.isNotBlank(rateDataJSON)) {
        Rate__c createRateRec = (Rate__c) JSON.deserialize(rateDataJSON , Rate__c.class);
            if (String.isBlank(createRateRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c, Negotiated_Amount__c, Negotiated_Date__c, Rate_Override__c, Notes__c', 'create', 'Rate__c',  Boolean.valueOf(Label.HasNamespace));
                insert createRateRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c, Negotiated_Amount__c, Negotiated_Date__c, Rate_Override__c, Notes__c', 'update', 'Rate__c',  Boolean.valueOf(Label.HasNamespace));
                update createRateRec;    
            }
            return createRateRec.Id;
        } else {
            return null;
        }
    }

    public Boolean checkUserProfile() {

        Id profileId = UserInfo.getProfileId();
        String profileName=[SELECT Id, Name FROM Profile WHERE Id=:profileId].Name;
        if(profileName == 'Casevault Supervisor') {
            return false;
        } else {
            return true;
        }
    }
    
    public class getInitialWrapper {
    
        @AuraEnabled
        public List<Utility.pickListWrap> GurdianRelationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> suspensionReasonPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> disclosurePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> annualReviewsPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> rateTypePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> hasNotificationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childsupportPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> isChildreceivingTCAPicklist;
        @AuraEnabled
        public Permanency_Plan__c permanencyPlanRecord;
        @AuraEnabled
        public List<Rate__c> rateRecList;
        @AuraEnabled
        public List<Rate__c> existingRateRec;
        @AuraEnabled
        public List<Annual_Review__c> annualReviewsList;
        @AuraEnabled
        public List<Annual_Review__c> existingAnnualReviewRec;
        @AuraEnabled
        public List<Contact> applicantCoApplList;
        @AuraEnabled
        public Account cpaProviderId;
        @AuraEnabled
        public List<Suspension__c> suspensionList;
        @AuraEnabled
        public List<Suspension__c> existingSuspensionRec;
        @AuraEnabled
        public Boolean showApprovalBtn;
     }
    
     public class RateAnnualWrapper {
         
        @AuraEnabled
        public List<Rate__c> rateRec;
        @AuraEnabled
        public List<Annual_Review__c> annualReviewRec;
        
        public RateAnnualWrapper() {
        
          rateRec = new List<Rate__c> ();
          annualReviewRec = new List<Annual_Review__c>();
        }
    }

}