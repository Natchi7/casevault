public with sharing class CustomLookUpController {

    @AuraEnabled
    public static List <sObject> fetchLookUpValues( String ObjectName, String searchKeyWord, String fieldNames, String fieldCondition ) {
        
        List < sObject > returnList = new List < sObject > ();
        String sQuery =  'SELECT Id, Name ';
        
        if(!String.isEmpty(fieldNames)) {
            
            sQuery = sQuery+', ' + String.escapeSingleQuotes(fieldNames);
        }
        sQuery = sQuery+ ' FROM ' + String.escapeSingleQuotes(ObjectName) + ' WHERE ';
        if(!String.isEmpty(fieldCondition)) {
            
            sQuery = sQuery+ 'Profile.Name ='+ '\''+ String.escapeSingleQuotes(fieldCondition) +'\''+ ' AND ';
        }
        sQuery = sQuery + 'Name LIKE \''+'%'+String.escapeSingleQuotes(searchKeyWord)+'%'+'\' limit 10';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<SObject> findRecords(String searchKey, String objectName, String searchField) {
    
        String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
        String profileName = 'Casevault Supervisor';
        Integer queryLimit = Utility.queryLimit;
        FieldLevelSecurity.checkFieldAccessByCriteria('Id,'+searchField, 'view', objectName, true);
        String QUERY = 'SELECT Id, '+String.escapeSingleQuotes(searchField)+' FROM '+String.escapeSingleQuotes(objectName)+' WHERE '+String.escapeSingleQuotes(searchField)+
            			' LIKE :key AND Profile.Name LIKE :profileName LIMIT :queryLimit';
        List<SObject> sObjectList = Database.query(QUERY);
        return sObjectList;
    }
}