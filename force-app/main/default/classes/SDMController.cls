public with sharing class SDMController {

    @AuraEnabled
    public static String getExpenses(Id caseId) {
    
        SDMWrapper SDMWrapperIns = new SDMWrapper();
        FieldLevelSecurity.checkFieldAccessByCriteria('Response_Id__c, Response__c, CPS_Response_Type__c ', 'view', 'CPS_Response__c',  Boolean.valueOf(Label.HasNamespace));
        for (CPS_Response__c cpsResponse : [SELECT Id, Response_Id__c, Response__c, CPS_Response_Type__c  FROM CPS_Response__c LIMIT 2000]) {
        
            SDMWrapperIns.CPSResponseMap.put(cpsResponse.Response_Id__c, JSON.Serialize(cpsResponse));
        }
        List<SDM__c> sdmRecord = [SELECT Id FROM SDM__c WHERE Intake__c = :caseId OR Investigation__c = :caseId OR Service_case__c = :caseId LIMIT 1];
        if(sdmRecord.size() > 0) {
            SDMWrapperIns.sdmId = sdmRecord[0].Id;
        }
        return JSON.Serialize(SDMWrapperIns);
    }
    
    @AuraEnabled
    public static String getCPSResponse(String SDMId, Map<Decimal, String> responseIdMap) {
    
        Integer queryLimit = Utility.queryLimit;
        if (String.isNotBlank(SDMId)) {
            String queryString;
            SDM__c sdmRecordIns = new SDM__c();
            ResponseWrapperObj ResponseWrapperObjIns = new ResponseWrapperObj();
            List<ResponseWrapper> responseWrapperList = new List<ResponseWrapper>();
            String sdmQueryString = 'SELECT Id';
            String flsSDMFields = '';
            for(Schema.FieldSetMember fld :SObjectType.SDM__c.FieldSets.AbuseFields.getFields()) {
                sdmQueryString += ', ' + fld.getFieldPath();
                flsSDMFields += String.isNotBlank(flsSDMFields) ? ', ' + fld.getFieldPath() : fld.getFieldPath();
            }
            for(Schema.FieldSetMember fld :SObjectType.SDM__c.FieldSets.CPSResponseFields.getFields()) {
                sdmQueryString += ', ' + fld.getFieldPath();
                flsSDMFields += String.isNotBlank(flsSDMFields) ? ', ' + fld.getFieldPath() : fld.getFieldPath();
            }
            sdmQueryString += ' FROM SDM__c WHERE Id = \''+ String.escapeSingleQuotes(SDMId) +'\'';
            
            FieldLevelSecurity.checkFieldAccessByCriteria(flsSDMFields, 'view', 'SDM__c',  Boolean.valueOf(Label.HasNamespace));
            //sdmQueryString += 'LIMIT 50000';
            if(Database.query(sdmQueryString) != null) {
                sdmRecordIns = Database.query(sdmQueryString);
            }
            
            List<String> abuseNameList = new List<String>();
            for(Schema.FieldSetMember fld : SObjectType.SDM__c.FieldSets.AbuseFields.getFields()) {
                
                if (Boolean.valueof(sdmRecordIns.get(fld.getFieldPath()))) {
                    abuseNameList.add(fld.getLabel());
                }    
            }    
            
            if (abuseNameList.size() > 0) {
                queryString = 'SELECT Id';
                String flsSDMRuleFields = '';
                for(Schema.FieldSetMember fld :SObjectType.SDM_Rule__c.FieldSets.SDMRuleFields.getFields()) {
                    queryString += ', ' + fld.getFieldPath();
                    flsSDMRuleFields += String.isNotBlank(flsSDMRuleFields) ? ', ' + fld.getFieldPath() : fld.getFieldPath();
                }
                queryString += ', CPS_Response_Type__c from SDM_Rule__c WHERE Abuse_Name__c = :abuseNameList';
                flsSDMRuleFields += String.isNotBlank(flsSDMRuleFields) ? ', CPS_Response_Type__c, Abuse_Name__c': 'CPS_Response_Type__c, Abuse_Name__c'; 
                FieldLevelSecurity.checkFieldAccessByCriteria(flsSDMRuleFields, 'view', 'SDM_Rule__c',  Boolean.valueOf(Label.HasNamespace));
                //queryString += 'LIMIT 50000';
                List<SDM_Rule__c> sdmRuleIns = Database.query(queryString);
                String responseType = 'CPS-AR';
                
                for (SDM_Rule__c sdmIns : sdmRuleIns) {
                    if (sdmIns.CPS_Response_Type__c == 'CPS-IR') {
                        responseType = 'CPS-IR';
                        break;
                    }
                }
                SDM__c updateSdm = new SDM__c();
                updateSdm.Id=SDMId;
                updateSdm.CPS_Response_Type__c = responseType;
                update updateSdm;
                ResponseWrapperObjIns.CPSResponseType = responseType;
                
                ResponseWrapper responseWrapperIns;
                CPS_Response__c cpsRes;
                    for(Schema.FieldSetMember fld : SObjectType.SDM_Rule__c.FieldSets.SDMRuleFields.getFields()) {
                        
                        responseWrapperIns = new ResponseWrapper();
                        for (SDM_Rule__c sdmIns : sdmRuleIns) {
                        responseWrapperIns.SDMRuleId = sdmIns.Id;
                        responseWrapperIns.fieldAPIName = fld.getFieldPath();
                        cpsRes = new CPS_Response__c();
                        cpsRes = (CPS_Response__c)JSON.deserialize(responseIdMap.get(Integer.valueof(fld.getLabel())),CPS_Response__c.class);
                        responseWrapperIns.Name = cpsRes.Response__c;
                        responseWrapperIns.type = cpsRes.CPS_Response_Type__c ;
                        if (sdmIns.get(fld.getFieldPath()) == 'YES') {
                            responseWrapperIns.checked = true;
                            responseWrapperIns.disabled = true;
                        } else if (sdmIns.get(fld.getFieldPath()) == 'NO') {
                            if (!(responseWrapperIns.checked)) {
                                responseWrapperIns.checked = false;
                            }
                            responseWrapperIns.disabled = true;
                        } else if (sdmIns.get(fld.getFieldPath()) == 'EDITABLE') {
                            if (Boolean.valueof(sdmRecordIns.get(fld.getFieldPath()))) {
                                responseWrapperIns.checked = true;    
                            } else {
                                responseWrapperIns.checked = false;
                            }
                            responseWrapperIns.disabled = false;
                        } else if (sdmIns.get(fld.getFieldPath()) == 'CLICK&EDIT') {
                            responseWrapperIns.checked = true;
                            responseWrapperIns.disabled = false;
                        }
                        
                    }    
                    ResponseWrapperObjIns.responseWrapperList.add(responseWrapperIns);           
                }
                
            } else {
                return null;
            }
            
            return JSON.Serialize(ResponseWrapperObjIns);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static void saveSDMRuleRecord(String SDMId, Map<String, Boolean> checkboxValueMap) {
    
        if (String.isNotBlank(SDMId) && checkboxValueMap != Null) {
        
            String flsSDMFields = '';
            SDM__c updatingSDMIns = new SDM__c();
            updatingSDMIns.Id = SDMId;
            
            for (String fieldAPIName : checkboxValueMap.keySet()) {
                flsSDMFields += String.isNotBlank(flsSDMFields) ? ', ' + fieldAPIName : fieldAPIName;
                updatingSDMIns.put(fieldAPIName, checkboxValueMap.get(fieldAPIName));  
            }
            FieldLevelSecurity.checkFieldAccessByCriteria(flsSDMFields, 'update', 'SDM__c',  Boolean.valueOf(Label.HasNamespace));
            update updatingSDMIns;
        }
        
    }
    
    @AuraEnabled
    public static String getSDMRecords(Id recordId, String module) {
        
        List<SDM__c> sdmRecord = new List<SDM__c>();
        if (String.isNotBlank(recordId) && module =='investigation') {
            sdmRecord = [SELECT Id, Name  FROM SDM__c WHERE Investigation__c =: recordId LIMIT :Utility.queryLimit];
            
        } else if (String.isNotBlank(recordId) && module =='servicecase') {
            sdmRecord = [SELECT Id, Name  FROM SDM__c WHERE Service_Case__c =: recordId LIMIT :Utility.queryLimit];

        } else if (String.isNotBlank(recordId) && module =='intake') {
            sdmRecord = [SELECT Id, Name  FROM SDM__c WHERE Intake__c =: recordId LIMIT :Utility.queryLimit];
        }
        return JSON.Serialize(sdmRecord);
    }
    
    public class SDMWrapper {
    
        public Map<Decimal, String> CPSResponseMap;
        public String sdmId;
        public SDMWrapper() {
            CPSResponseMap = new Map<Decimal, String>();
        }
    }
    
    public class ResponseWrapperObj {
    
        public String CPSResponseType;
        public List<ResponseWrapper> responseWrapperList;
        
        public ResponseWrapperObj() {
            CPSResponseType = '';
            responseWrapperList = new List<ResponseWrapper>();
        }
    }
    
    public class ResponseWrapper {
    
        public String Name;
        public String SDMRuleId;
        public String fieldAPIName;
        public boolean checked;
        public boolean disabled;
        Public String type;
        
        public ResponseWrapper() {
        
            Name = '';
            SDMRuleId = '';
            fieldAPIName = '';
            checked = false;
            disabled = false;
        }
    }
}