public  with sharing class FindingPersonController {

    @AuraEnabled
    public static String getInitialInformation() {
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.genderPicklist =  Utility.getPicklistinfo('Contact','Gender__c',false);
        initwrap.statePicklist =  Utility.getPicklistinfo('Contact','Address_State__c',false);
        initwrap.countryPicklist =  Utility.getPicklistinfo('Contact','County_Address__c',false);
        return JSON.serialize(initWrap);
    }
    @AuraEnabled
    public static String getPersons(String searchJSON) {
        if(String.isNotBlank(searchJSON)){
            SearchInputWrapper inputWrap = (SearchInputWrapper) JSON.deserialize(searchJSON, SearchInputWrapper.class);
            List<contact> contactList = new List<contact> ();
            FieldLevelSecurity.checkFieldAccessByCriteria(' Name, FirstName, LastName, Casevault_PID__c, SSN__c, Date_of_Birth__c, Gender__c, Age__c,'+
            'Address_Line_1__c , Address_Line_2__c, Address_ZipCode__c, Address_State__c, County_Address__c, Address_City__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            String contactJSON = 'SELECT Id, Name, FirstName, LastName, Casevault_PID__c, SSN__c, Date_of_Birth__c, Gender__c, Age__c, '; 
            contactJSON += 'Address_Line_1__c , Address_Line_2__c, Address_ZipCode__c, Address_State__c, County_Address__c, Address_City__c FROM Contact';
            contactJSON += ' WHERE LastName != null AND Home_Approval__r.Home_Approval_Status__c != \'Approved\' AND Service_Case__c = NULL AND Intake__c = NULL AND Investigation__c = NULL';
            Date DOB = inputWrap.dob;
            Decimal age = inputWrap.approxAge;
            if(String.isNotBlank(inputWrap.firstName)){
                contactJSON +=  ' AND FirstName LIKE \''+ String.escapeSingleQuotes(inputWrap.firstName) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.lastName)){
                contactJSON +=  ' AND LastName LIKE \''+ String.escapeSingleQuotes(inputWrap.lastName) +'%'+'\'';
            }
            if(inputWrap.dob != Null){
                contactJSON +=  ' AND Date_of_Birth__c =:DOB';
            }
            if(String.isNotBlank(inputWrap.casevaultPId)){
                contactJSON +=  ' AND Casevault_PID__c LIKE \''+ String.escapeSingleQuotes(inputWrap.casevaultPId) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.ssn)){
                contactJSON +=  ' AND SSN__c LIKE \''+ String.escapeSingleQuotes(inputWrap.ssn) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.stateId)){
                contactJSON +=  ' AND State_Id_Drivers_License__c LIKE \''+ String.escapeSingleQuotes(inputWrap.stateId) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.gender)) {
                contactJSON +=  ' AND Gender__c  LIKE \''+ String.escapeSingleQuotes(inputWrap.gender) +'%'+'\'';
            }
            if(inputWrap.approxAge != Null){
                contactJSON += ' AND Age__c	=:age';
            }
            if(String.isNotBlank(inputWrap.addLine1)){
                contactJSON += ' AND Address_Line_1__c LIKE	\''+ String.escapeSingleQuotes(inputWrap.addLine1) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.addLine2)){
                contactJSON += ' AND Address_Line_2__c LIKE	\''+ String.escapeSingleQuotes(inputWrap.addLine2) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.zipCode)){
                contactJSON += ' AND Address_ZipCode__c LIKE \''+ String.escapeSingleQuotes(inputWrap.zipCode) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.state)){
                contactJSON += ' AND Address_State__c LIKE \''+ String.escapeSingleQuotes(inputWrap.state) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.city)){
                contactJSON += ' AND Address_City__c LIKE \''+ String.escapeSingleQuotes(inputWrap.city) +'%'+'\'';
            }
            if(String.isNotBlank(inputWrap.country)){
                contactJSON += ' AND County_Address__c  LIKE\''+ String.escapeSingleQuotes(inputWrap.country) +'%'+'\'';            
            }
            Integer queryLimit = Utility.queryLimit;
            contactJSON +=' LIMIT :queryLimit ';
            contactList = Database.query(contactJSON);
            inputWrap.contactList = contactList;
            return JSON.serialize(inputWrap.contactList);
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String updatePerson(String contactJSON) {
       
        if (String.isNotBlank(contactJSON)) {
            Contact updatePerson = (Contact) JSON.deserialize(contactJSON, Contact.class);
            if (String.isNotBlank(updatePerson.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c,Intake__c,Investigation__c', 'update', 'Contact',  Boolean.valueOf(Label.HasNamespace));
                update updatePerson;
            } 
        return updatePerson.Id;
        } else {
            return null;
        }
    }
    public class SearchInputWrapper {
        
        Public String firstName; 
        Public String ssn;
        Public String middleName;
        Public String lastName;
        Public String stateId;
        Public String aliasName;
        Public Date dob;
        Public String fein;
        Public String socialMediaName;
        Public Decimal approxAge;
        Public String gender;
        Public String complaint;
        Public String addLine1;
        Public String addLine2;
        Public String email;
        Public String casevaultPId;
        Public String cisId;
        Public String phone;
        Public String mdmId;
        Public String zipCode;
        Public String state;
        Public String occupation;
        Public String petition;
        Public String city;
        Public String country;
        Public String old;
        @AuraEnabled
        public List<Contact> contactList;
    }
     public class GetInitialWrapper {
        @AuraEnabled
        public List<Utility.pickListWrap> genderPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> statePicklist;
         @AuraEnabled
        public List<Utility.pickListWrap> countryPicklist;
     }
}