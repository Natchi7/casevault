trigger referralTrigger on Referral__c (before insert, before update) {   
    
    Set<String> privateProviders = new Set<String>{'CPA Office', 'ICPC Home Study', 'Private Organization', 'RCC Facility'}; 

    for(Referral__c ref : Trigger.new) {
    
        Referral__c oldReferral = new Referral__c();
    
        if(Trigger.oldMap != null) {
            
            oldReferral = Trigger.oldMap.get(ref.Id);
        }
        
        if(Trigger.isBefore && Trigger.isInsert) { 
        
            ref.Referal_status__c = 'Open';
        }
        
        if(Trigger.isBefore && Trigger.isUpdate) {
            
            /*if(ref.Converted__c) {
                
                ref.Referal_status__c = 'Referral Converted';
            }*/
            
            if(oldReferral != null && oldReferral.Type__c == 'CPA Home' && ref.Type__c != oldReferral.Type__c) {
            
                ref.CPA_Office_ID__c = null;
            }
            
            if(ref.Tax_Id_Type__c == null && ref.Tax_Id__c != null) {
                
                ref.Tax_Id__c = null;
            }
            
            if(oldReferral != null && ref.Tax_Id_Type__c != null && ref.Tax_Id_Type__c != oldReferral.Tax_Id_Type__c && ref.Tax_Id__c == oldReferral.Tax_Id__c) {
                
                ref.addError('Provide valid Tax Id');
            }  
            
            if((privateProviders.contains(oldReferral.Type__c) &&  ref.Type__c == 'Local Department Home') 
                || (oldReferral.Type__c == 'Local Department Home' && privateProviders.contains(ref.Type__c))) {
                
                ref.Tax_Id_Type__c = null;
                ref.Tax_Id__c = null;
            }        
        }
    }
}