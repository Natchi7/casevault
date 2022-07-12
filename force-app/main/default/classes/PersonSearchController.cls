public with sharing class PersonSearchController {
    
    @AuraEnabled
    public static String getContacts(String searchJSON) {
        
        if(String.isNotBlank(searchJSON)) {
            
            List<Contact> contactList = new List<Contact> ();
            SearchInputWrapper inputWrap = (SearchInputWrapper) JSON.deserialize(searchJSON, SearchInputWrapper.class);
            Date personDOB = inputWrap.dob;
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, FirstName, LastName, Casevault_PID__c, SSN__c, Date_of_Birth__c, Gender__c,Intake_Person_Role__c,'
                                                          +'State_Id_Drivers_License__c, Intake__c, Investigation__c, Service_Case__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            
            
            String contactJSON = 'SELECT Id, Name, Casevault_PID__c, SSN__c,Date_of_Birth__c, Gender__c, State_Id_Drivers_License__c,Intake_Person_Role__c, Intake__c, Investigation__c, Service_Case__c FROM Contact'; 
            contactJSON += ' WHERE LastName != null';

            if( String.isNotBlank(inputWrap.firstName) ) {

                contactJSON +=  ' AND FirstName LIKE \''+ String.escapeSingleQuotes(inputWrap.firstName) +'%'+'\'';
            }
            if( String.isNotBlank(inputWrap.lastName) ) {

                contactJSON +=  ' AND LastName LIKE \''+ String.escapeSingleQuotes(inputWrap.lastName) +'%'+'\'';
            }
            if( inputWrap.dob != NULL ) {

                contactJSON +=  ' AND Date_of_Birth__c = :personDOB';
            }
            if( String.isNotBlank(inputWrap.casevaultPid) ) {

                contactJSON +=  ' AND Casevault_PID__c LIKE \''+ String.escapeSingleQuotes(inputWrap.casevaultPid) +'%'+'\'';
            }
            if( String.isNotBlank(inputWrap.ssn) ) {
                contactJSON +=  ' AND SSN__c LIKE \''+ String.escapeSingleQuotes(inputWrap.ssn) +'%'+'\'';
            }
            if( String.isNotBlank(inputWrap.dlNo) ) {

                contactJSON +=  ' AND State_Id_Drivers_License__c LIKE \''+ String.escapeSingleQuotes(inputWrap.dlNo) +'%'+'\'';
            }
            contactJSON +=' LIMIT 500 ';

            contactList = Database.query(contactJSON);
            
            return JSON.serialize(contactList);
            
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String personsIntakeInvSC(String selectedPersonJSON) {
       
        if(String.isNotBlank(selectedPersonJSON)) {

            Contact selectedPerson = (Contact)JSON.deserialize(selectedPersonJSON, Contact.class);
            PersonsWrapper wrapperIns = new PersonsWrapper();
            if(String.isNotBlank(selectedPerson.Intake__c)) {

                FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber, Origin, Jurisdiction__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
                wrapperIns.intake = [SELECT Id, CaseNumber, Origin, Jurisdiction__c FROM Case WHERE Id = :selectedPerson.Intake__c]; 
            }
            if(String.isNotBlank(selectedPerson.Investigation__c)) {

                FieldLevelSecurity.checkFieldAccessByCriteria('Name, CPS_Response_Type__c', 'view', 'Investigation__c',  Boolean.valueOf(Label.HasNamespace));
                wrapperIns.investigation = [SELECT Id, Name, CPS_Response_Type__c FROM Investigation__c WHERE Id = :selectedPerson.Investigation__c];
            }
            if(String.isNotBlank(selectedPerson.Service_Case__c)) {

                FieldLevelSecurity.checkFieldAccessByCriteria('Name, Status__c, Number_of_days__c', 'view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
                wrapperIns.serviceCase = [SELECT Id, Name, Status__c, Number_of_days__c FROM Service_Case__c WHERE Id = :selectedPerson.Service_Case__c];
            }
            return JSON.serialize(wrapperIns);
        } else {
            return null;
        }
    }
    
    public class SearchInputWrapper {
        
        public String firstName; 
        public String lastName;
        public Date dob;
        public String ssn;
        public String casevaultPid;
        public String dlNo;       
    }

    public class PersonsWrapper {

        public Case intake;
        public Investigation__c investigation;
        public Service_Case__c serviceCase;
    }
}