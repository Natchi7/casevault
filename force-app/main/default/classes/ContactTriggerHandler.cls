public class ContactTriggerHandler {

    public static void onBeforeInsert(List<Contact> contacts) {
        
        Set<Id> homeApprovalIds = new Set<Id>();
   		Map<Id, Contact> conHomeApprovalMap = new Map<Id, Contact>(); 
        
        Casevault_Unique_Id__c  cvUniqueLstSettingIns = Casevault_Unique_Id__c.getValues('Person');
        Decimal casevaultPIDValue = 0;
        if (cvUniqueLstSettingIns == null) {
            cvUniqueLstSettingIns = new Casevault_Unique_Id__c( Name = 'Person');
        } else {
            casevaultPIDValue = cvUniqueLstSettingIns.Auto_Number__c ;
        }
        
        for(Contact con : contacts) {
            
            if(con.Home_Approval__c != null) {
                
               homeApprovalIds.add(con.Home_Approval__c);
               conHomeApprovalMap.put(con.Home_Approval__c, con);                 
            }
                
            casevaultPIDValue++;
            con.Casevault_PID__c = 'PE-'+Integer.valueOf(casevaultPIDValue);            
        } 
        
        cvUniqueLstSettingIns.Auto_Number__c = casevaultPIDValue;
    	upsert cvUniqueLstSettingIns;
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval_Status__c,','view','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
        for(Home_Approval__c home : [SELECT Id, Home_Approval_Status__c FROM Home_Approval__c WHERE Id IN :homeApprovalIds 
                                AND Home_Approval_Status__c = 'Approved']) {
            
            if(conHomeApprovalMap != null && conHomeApprovalMap.containsKey(home.Id) && conHomeApprovalMap.get(home.Id) != null) {
                
                Contact con = conHomeApprovalMap.get(home.Id);
                
                if(con != null) {
                    con.addError('Not allowed to create or change the value once approved the home approval.');
                }             
            }
        }
    }
    
    public static void onBeforeUpdate(List<Contact> contacts) {

		Set<Id> homeApprovalIds = new Set<Id>();
   		Map<Id, Contact> conHomeApprovalMap = new Map<Id, Contact>();        
        for(Contact con : contacts) {
            
            if(con.Home_Approval__c != null) {
                
               homeApprovalIds.add(con.Home_Approval__c);
               conHomeApprovalMap.put(con.Home_Approval__c, con);                 
            }                                 
        } 
        FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval_Status__c,','view','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
        for(Home_Approval__c home : [SELECT Id, Home_Approval_Status__c FROM Home_Approval__c WHERE Id IN :homeApprovalIds 
                                AND Home_Approval_Status__c = 'Approved']) {
            
            if(conHomeApprovalMap != null && conHomeApprovalMap.containsKey(home.Id) && conHomeApprovalMap.get(home.Id) != null) {
                
                Contact con = conHomeApprovalMap.get(home.Id);
                
                if(con != null) {
                    con.addError('Not allowed to create or change the value once approved the home approval.');
                }             
            }
        }
    }
}