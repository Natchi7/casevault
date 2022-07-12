trigger ProviderTrigger on Account (before insert, before update, before delete, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        
        Casevault_Unique_Id__c  cvUniqueLstSettingIns = Casevault_Unique_Id__c.getValues('Provider');
        Decimal casevaultPIDValue = 0;
        if (cvUniqueLstSettingIns == null) {
            cvUniqueLstSettingIns = new Casevault_Unique_Id__c( Name = 'Provider');
        } else {
            casevaultPIDValue = cvUniqueLstSettingIns.Auto_Number__c ;
        }
        for(Account provider : Trigger.New) {
            
            casevaultPIDValue++;
            provider.Casevault_ProID__c = 'PR-'+Integer.valueOf(casevaultPIDValue);
        }         
        cvUniqueLstSettingIns.Auto_Number__c = casevaultPIDValue;
        upsert cvUniqueLstSettingIns;
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
    
        List<Referral__c> updatingReferralList = new List<Referral__c>();
        Id referralRecordTypeId = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Referral Record Type').getRecordTypeId();
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : Trigger.new) {
            
            if (acc.Provider_Status__c == 'Suspended') {
            
                accIdSet.add(acc.Id);    
            }
        }
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Referal_status__c, RecordTypeId', 'view', 'Referral__c',  Boolean.valueOf(Label.HasNamespace));
        for (Referral__c referralIns : [SELECT Id, Referal_status__c, RecordTypeId FROM Referral__c WHERE Converted_Account_Id__c IN :accIdSet]) {
            referralIns .Referal_status__c = 'ReOpened';
            //referralIns .RecordTypeId = referralRecordTypeId;
            updatingReferralList.add(referralIns);
        }
        
        if (updatingReferralList != null && updatingReferralList.size() > 0)
            FieldLevelSecurity.checkFieldAccessByCriteria('Referal_status__c, RecordTypeId', 'update', 'Referral__c',  Boolean.valueOf(Label.HasNamespace));    
            update updatingReferralList;
    }
    
    if(trigger.isBefore && trigger.isDelete) {
        for(Account acc: Trigger.old) {
            if(acc.Casevault_ProID__c != NULL ){
                acc.addError('You cannot delete this Account '); 
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) { 
        
        for(Account acc : Trigger.new) {
            
            Account oldAccount =  Trigger.oldMap.get(acc.Id);
            
            if(oldAccount.Type__c == 'Local Department Home' && oldAccount.Type__c != acc.Type__c) {
                acc.Indicator__c = null;
            } 
        }         
    }
        
}