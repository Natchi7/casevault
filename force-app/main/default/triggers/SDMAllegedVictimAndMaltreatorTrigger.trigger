trigger SDMAllegedVictimAndMaltreatorTrigger on SDM_Alleged_Victim_and_Maltreator__c (after delete) {

     if(trigger.isDelete && trigger.isAfter)
       {
          SDMAllegedVictimAndMaltreatorHandler.deleteMaltreatmentandAllegation(trigger.old);
         }

}