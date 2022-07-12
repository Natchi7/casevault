trigger HomeApprovalTrigger on Home_Approval__c (before insert, before update, before delete) {   

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {                
        for (Home_Approval__c approval: Trigger.new) {
            
            approval.Home_Approval_Type__c = approval.Set_Recommendation__c == 'This home should be Approved' ? 'Activate' : '';
        }
    }

    if(trigger.isBefore && trigger.isDelete) {
    
        for(Home_Approval__c  app: Trigger.old) {
           if (app.Home_Approval_Status__c == 'Approved') {
                    app.addError('You cannot delete the approved record');
            }
        }
    }
}