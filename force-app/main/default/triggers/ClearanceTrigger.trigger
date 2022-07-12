trigger ClearanceTrigger on Clearance__c (before insert, before update) {
    
    Map<Id, Boolean> homeApprovalMap = new Map<Id, Boolean>();
    Set<Id> approvalIds = new Set<Id>();
    
    for(Clearance__c rec : Trigger.new){
        
        if(rec.Federal_Result__c != 'Fail' && rec.State_Result__c != 'Fail') {
            
            approvalIds.add(rec.Home_Approval__c);
            homeApprovalMap.put(rec.Home_Approval__c, true);
        }
    }
    
    List<Home_Approval__c> updateHomeApprovalList = new List<Home_Approval__c>();
    
    for(Id approvalId :approvalIds) {
        
        if(homeApprovalMap != null && homeApprovalMap.containsKey(approvalId)) {
        
            Home_Approval__c  approval = new Home_Approval__c();
            approval.Id = approvalId;
            approval.Isfilled_Clearance__c = true;
            updateHomeApprovalList.add(approval);
        } 
    } 
    
    if(updateHomeApprovalList != null) {
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Isfilled_Clearance__c','update','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
        update updateHomeApprovalList;
    }
}