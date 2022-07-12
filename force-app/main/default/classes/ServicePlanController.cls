public  with sharing class ServicePlanController {

    @AuraEnabled
    public static String getIntiVisitationInfo (String servicePlanId) {
    
        ServicePlanWrapper servicePlanWrap = new ServicePlanWrapper();
        servicePlanWrap.conditionsPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Conditions__c',false);
        servicePlanWrap.frequencyPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Frequency__c',false);
        servicePlanWrap.visitorTransportationPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Visitor_Transportation__c',false);
        servicePlanWrap.childTransportationPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Child_Transportation__c',false);
        servicePlanWrap.visitDurationPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Visit_Duration__c',false);
        if(String.isNotBlank(servicePlanId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c', 'view', 'Service_Plan__c', Boolean.valueOf(Label.HasNamespace));
            Service_Plan__c servicePlanRec = [SELECT Id, Service_Case__c
                                                          FROM Service_Plan__c WHERE Id= :servicePlanId LIMIT :Utility.queryLimit]; 
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));

                List<Contact> clientList = [SELECT Id, Name FROM Contact 
                                            WHERE Service_Case__c = :servicePlanRec.Service_Case__c LIMIT :Utility.queryLimit];
                List<Utility.pickListWrap> clientRecPickList = new List<Utility.pickListWrap>();
                Utility.pickListWrap intialPick = new Utility.pickListWrap();
                intialPick.label = '--None--';
                intialPick.value = '';
                clientRecPickList.add(intialPick);
            	Utility.pickListWrap pick ;
                for(Contact con : clientList) {
                
                    if (String.isNotBlank(con.Id)) {
                        
                        pick = new Utility.pickListWrap();
                        pick.label = con.Name;
                        pick.value = con.Id;
                        clientRecPickList.add(pick);
                    }
                }  
               servicePlanWrap.clientPicklist = clientRecPickList;
               FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
               List<Contact> personInvolveds = [SELECT Name FROM Contact WHERE 
                                                Service_Case__c =:servicePlanRec.Service_Case__c
                                                AND Intake_Person_Role__c
                                                INCLUDES('Biological Child','Child','Other Child',
                                                'Other Child (Not in Household)','Private Adoptive Child') LIMIT :Utility.queryLimit];
               List<Utility.pickListWrap> personInvolvedsPickList = new List<Utility.pickListWrap>();
                Utility.pickListWrap intialPick1 = new Utility.pickListWrap();
                intialPick1.label = '--None--';
                intialPick1.value = '';
                personInvolvedsPickList.add(intialPick1);
                for(Contact con : personInvolveds) {
                
                    if (String.isNotBlank(con.Id)) {
                        
                        pick = new Utility.pickListWrap();
                        pick.label = con.Name;
                        pick.value = con.Name;
                        personInvolvedsPickList.add(pick);
                    }
                }
                servicePlanWrap.personInvolvedPicklist = personInvolvedsPickList;
            //}
            FieldLevelSecurity.checkFieldAccessByCriteria('Client__c, Established_Date__c, End_Date__c, Court_Ordered__c,Explain_Visitor__c,'+
            'No_visits_allowed__c, Conditions__c, Comments__c, Explain_Visit_Plan__c, Frequency__c, Explain__c,Person_involved__c,'+
            'Visit_Duration__c, Location__c, Child_Transportation__c, ExplainChild__c, Visitor_Transportation__c', 'view', 'Visitation_Plan__c', Boolean.valueOf(Label.HasNamespace));
            servicePlanWrap.visitationPlanList = [SELECT Id, Client__c, Client__r.Name, Established_Date__c, End_Date__c, Court_Ordered__c,Explain_Visitor__c,
                                                  No_visits_allowed__c, Conditions__c, Comments__c, Explain_Visit_Plan__c, Frequency__c, Explain__c,Person_involved__c,
                                                  Visit_Duration__c, Location__c, Child_Transportation__c, ExplainChild__c, Visitor_Transportation__c                        
                                                  FROM Visitation_Plan__c WHERE Service_Plan__c =:servicePlanId LIMIT :Utility.queryLimit
                                                 ];
        }
        return JSON.serialize(servicePlanWrap);
    }
    
    @AuraEnabled
    public static String createVisitationPlanRecord(String visitionPlanJSON) {
    
        if(String.isNotBlank(visitionPlanJSON)) {
            Visitation_Plan__c visitationRec = (Visitation_Plan__c)JSON.deserialize(visitionPlanJSON, Visitation_Plan__c.class);
            if (String.isBlank(visitationRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Client__c, Established_Date__c, End_Date__c, Court_Ordered__c,Explain_Visitor__c,'+
                'No_visits_allowed__c, Conditions__c, Comments__c, Explain_Visit_Plan__c, Frequency__c, Explain__c,Person_involved__c,'+
                'Visit_Duration__c, Location__c, Child_Transportation__c, ExplainChild__c, Visitor_Transportation__c', 'create', 'Visitation_Plan__c', Boolean.valueOf(Label.HasNamespace));
                insert visitationRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Client__c, Established_Date__c, End_Date__c, Court_Ordered__c,Explain_Visitor__c,'+
            'No_visits_allowed__c, Conditions__c, Comments__c, Explain_Visit_Plan__c, Frequency__c, Explain__c,Person_involved__c,'+
            'Visit_Duration__c, Location__c, Child_Transportation__c, ExplainChild__c, Visitor_Transportation__c', 'update', 'Visitation_Plan__c', Boolean.valueOf(Label.HasNamespace));
                update visitationRec;
            }
            return visitationRec.Id;
        } else {
            return null;
        }
        
    }
 
    @AuraEnabled
    public static String getVisitationPlanRec(String visitionId) {
    
        ServicePlanWrapper servicePlanWrap = new ServicePlanWrapper();
        FieldLevelSecurity.checkFieldAccessByCriteria('Client__c, Established_Date__c, End_Date__c, Person_involved__c, Court_Ordered__c,'+
        'No_visits_allowed__c, Conditions__c, Comments__c, Explain_Visit_Plan__c, Frequency__c, Explain__c,'+
        'Location__c, Child_Transportation__c, ExplainChild__c, Visitor_Transportation__c,Explain_Visitor__c', 'view', 'Visitation_Plan__c', Boolean.valueOf(Label.HasNamespace));
        servicePlanWrap.visitationPlanRec  = [SELECT Id, Client__c, Established_Date__c, End_Date__c, Person_involved__c, Court_Ordered__c,
                                           No_visits_allowed__c, Conditions__c, Comments__c, Explain_Visit_Plan__c, Frequency__c, Explain__c,
                                           Location__c, Child_Transportation__c, ExplainChild__c, Visitor_Transportation__c,Explain_Visitor__c
                                           FROM Visitation_Plan__c WHERE Id=:visitionId LIMIT :Utility.queryLimit
                                          ];
        return JSON.serialize(servicePlanWrap);
    }
    
    @AuraEnabled
    public static void deleteVisitationPlanRec(String visitionPlanRec) {
        
        if (String.isNotBlank(visitionPlanRec)) {
            Visitation_Plan__c  visitationPlanRecord= (Visitation_Plan__c )JSON.deserialize(visitionPlanRec, Visitation_Plan__c.class);
            FieldLevelSecurity.checkObjectAccessByDelete('Visitation_Plan__c');            
            delete visitationPlanRecord;
        }
        
    }

    @AuraEnabled
    public static String getActionsInitialInfo(String recordId) {
        
        ServicePlanWrapper servicePlanWrap = new ServicePlanWrapper();

        servicePlanWrap.statusPicklist = Utility.getPicklistinfo('Goal_Action__c','Status__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Goal__c', 'view', 'Objective__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Service_Plan__c', 'view', 'Goal__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
        
        Objective__c objectiveRec = [SELECT Id, Goal__r.Service_Plan__r.Service_Case__c FROM Objective__c WHERE Id = :recordId LIMIT :Utility.queryLimit];
        
        List<Contact> personBenefiting = [SELECT Id, Name FROM Contact WHERE Service_Case__c = :objectiveRec.Goal__r.Service_Plan__r.Service_Case__c AND
                                        Intake_Person_Role__c INCLUDES ('Biological Child','Child','Other Child','Other Child (Not in Household)','Private Adoptive Child','Legal Guardian') LIMIT :Utility.queryLimit];
        
        List<Contact> personResponsible = [SELECT Id, Name FROM Contact WHERE Service_Case__c = :objectiveRec.Goal__r.Service_Plan__r.Service_Case__c LIMIT :Utility.queryLimit];
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, First_Name__c, Middle_Name__c, Last_Name__c', 'view', 'Collateral__c', Boolean.valueOf(Label.HasNamespace));
        
        List<Collateral__c> collaterals = [SELECT Id, Name, First_Name__c, Middle_Name__c, Last_Name__c FROM Collateral__c WHERE Service_Case__c = :objectiveRec.Goal__r.Service_Plan__r.Service_Case__c LIMIT :Utility.queryLimit];
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Person_Benefitizing__c, Person_Responsible__c, Start_Date__c, End_Date__c, Status__c, Comments__c ', 'view', 'Goal_Action__c', Boolean.valueOf(Label.HasNamespace));
        
        servicePlanWrap.goalActionRecords = [SELECT Id, Name, Person_Benefitizing__c, Person_Responsible__c, Start_Date__c, End_Date__c, Status__c, Comments__c FROM Goal_Action__c WHERE Goal_Objective__c = :recordId LIMIT :Utility.queryLimit];
        
        List<Utility.pickListWrap> personBenefitingPicklist = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick1 = new Utility.pickListWrap();
        intialPick1.label = '--None--';
        intialPick1.value = '';
        personBenefitingPicklist.add(intialPick1);
        Utility.pickListWrap pick;
        for(Contact con : personBenefiting) {
        
            if (String.isNotBlank(con.Id)) {
                
                pick = new Utility.pickListWrap();
                pick.label = con.Name;
                pick.value = con.Name;
                personBenefitingPicklist.add(pick);
            }
        }
        servicePlanWrap.personBenefitingPicklist = personBenefitingPicklist;
        
        List<Utility.pickListWrap> personResponsiblePicklist = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        personResponsiblePicklist.add(intialPick);
        for(Contact con : personResponsible) {
        
            if (String.isNotBlank(con.Id)) {
                
                pick = new Utility.pickListWrap();
                pick.label = con.Name;
                pick.value = con.Name;
                personResponsiblePicklist.add(pick);
            }
        }
        for(Collateral__c collateralRec : collaterals) {
        
            if (String.isNotBlank(collateralRec.Id)) {
                String collateralName = '';
                if(collateralRec.First_Name__c != null) {
                    collateralName = collateralName + collateralRec.First_Name__c + ' ' ;
                }
                if(collateralRec.Middle_Name__c != null) {
                    collateralName = collateralName + collateralRec.Middle_Name__c + ' ' ;
                }
                if(collateralRec.Last_Name__c != null) {
                    collateralName = collateralName + collateralRec.Last_Name__c ;
                }
                pick = new Utility.pickListWrap();
                pick.label = collateralName;
                //pick.value = collateralRec.Name;
                pick.value = collateralName;
                personResponsiblePicklist.add(pick);
            }
        }
        servicePlanWrap.personResponsiblePicklist = personResponsiblePicklist;
        return JSON.serialize(servicePlanWrap);
    }

    @AuraEnabled
    public static String upsertGoalActions(String goalActionJSON) {

        if(String.isNotBlank(goalActionJSON)) {
            Goal_Action__c goalActionRec = (Goal_Action__c)JSON.deserialize(goalActionJSON, Goal_Action__c.class);
           if (String.isBlank(goalActionRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Name, Person_Benefitizing__c, Person_Responsible__c, Start_Date__c, End_Date__c, Status__c, Comments__c ', 'create', 'Goal_Action__c', Boolean.valueOf(Label.HasNamespace));
               insert goalActionRec;
           } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Name, Person_Benefitizing__c, Person_Responsible__c, Start_Date__c, End_Date__c, Status__c, Comments__c ', 'update', 'Goal_Action__c', Boolean.valueOf(Label.HasNamespace));
                update goalActionRec;
           }
           return goalActionRec.Id;
       } else {
           return null;
       }
       
    }

    @AuraEnabled
    public static String getServicePlanVersionsInitInfo(String recordId) {
       
        ServicePlanWrapper servicePlanWrap = new ServicePlanWrapper();
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Persons_Benefitizing__c, Start_Date__c, End_Date__c', 'view', 'Service_Plan_Version__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c', 'view', 'Service_Plan__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
        servicePlanWrap.servicePlanVersionList = [SELECT Id, Name, Persons_Benefitizing__c, Start_Date__c, End_Date__c FROM Service_Plan_Version__c WHERE Service_Plan__c = :recordId];
        Service_Plan__c servicePlanRec = [SELECT Id,Service_Case__c FROM Service_Plan__c WHERE Id = :recordId];
        
        List<Contact> personBenefiting = [SELECT Id, Name FROM Contact WHERE Service_Case__c = :servicePlanRec.Service_Case__c AND
                                        Intake_Person_Role__c INCLUDES ('Biological Child','Child','Other Child','Other Child (Not in Household)','Private Adoptive Child','Legal Guardian') LIMIT :Utility.queryLimit];

        List<Utility.pickListWrap> personBenefitingPicklist = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick1 = new Utility.pickListWrap();
        intialPick1.label = '--None--';
        intialPick1.value = '';
        personBenefitingPicklist.add(intialPick1);
        Utility.pickListWrap pick;
        for(Contact con : personBenefiting) {
        
            if (String.isNotBlank(con.Id)) {
                
                pick = new Utility.pickListWrap();
                pick.label = con.Name;
                pick.value = con.Name;
                personBenefitingPicklist.add(pick);
            }
        }
        servicePlanWrap.personBenefitingPicklist = personBenefitingPicklist;
        return JSON.serialize(servicePlanWrap);
        
    }

    @AuraEnabled
    public static String upsertServicePlanVersions(String servicePlanVersionJSON) {

        if(String.isNotBlank(servicePlanVersionJSON)) {
            Service_Plan_Version__c servicePlanVersionRec = (Service_Plan_Version__c)JSON.deserialize(servicePlanVersionJSON, Service_Plan_Version__c.class);
           if (String.isBlank(servicePlanVersionRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Persons_Benefitizing__c, Start_Date__c, End_Date__c', 'create', 'Service_Plan_Version__c', Boolean.valueOf(Label.HasNamespace));
               insert servicePlanVersionRec;
           } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Persons_Benefitizing__c, Start_Date__c, End_Date__c', 'update', 'Service_Plan_Version__c', Boolean.valueOf(Label.HasNamespace));
               update servicePlanVersionRec;
           }
           return servicePlanVersionRec.Id;
       } else {
           return null;
       }
       
    }

    public class ServicePlanWrapper {
    
        @AuraEnabled
        public List<Utility.pickListWrap> clientPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> personInvolvedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> conditionsPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> frequencyPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> visitorTransportationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childTransportationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> visitDurationPicklist;
        @AuraEnabled
        public List<Visitation_Plan__c> visitationPlanList;
        @AuraEnabled
        public Visitation_Plan__c visitationPlanRec;

        @AuraEnabled
        public List<Utility.pickListWrap> statusPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> personBenefitingPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> personResponsiblePicklist;
        @AuraEnabled
        public List<Goal_Action__c> goalActionRecords;

        @AuraEnabled
        public List<Service_Plan_Version__c> servicePlanVersionList;      
    }
}