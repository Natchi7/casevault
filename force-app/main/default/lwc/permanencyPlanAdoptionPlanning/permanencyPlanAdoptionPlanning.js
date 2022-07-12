import { LightningElement, api, track } from 'lwc';
import getAdoptionPlanningInitInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getAdoptionPlanningStageInitialInfos';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class PermanencyPlanAdoptionPlanning extends UtilityBaseElement {
    @api permanencyRecId;
    @track adoptionPlanningPicklist;
    @track adoptionPlanningRec = {};
    @track showAdoptionEfforts = false;
    @track showEmotionalTiles = false;
    @track showNarrtive = false;
    @track showApplicableChildAssessment = false;
    @track showDisclosureChecklist = false;
    @track currentadoptionStage = 'ADOPTION EFFORTS';

    connectedCallback() {
        this.getIntialAdoptionPlanStage();
    }

    getIntialAdoptionPlanStage() {
        getAdoptionPlanningInitInfo({ permanencyPlanId: this.permanencyRecId } )
        .then(result => {
            if (result) {
                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = false;
                this.showNarrtive = false;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = false;
                let res = JSON.parse(result).adoptionPlanningStageRec;
                var adoptionPlanningPick = JSON.parse(result).adoptionPlanningStagePicklist;
                adoptionPlanningPick.splice(0, 1); // for remove new value
                this.adoptionPlanningPicklist = adoptionPlanningPick;
                if(res != null) {
                this.adoptionPlanningRec = this.checkNamespaceApplicable(res, false);
                }
                if(this.adoptionPlanningRec.Adoption_Planning_Stage__c) {
                    this.currentadoptionStage = this.adoptionPlanningRec.Adoption_Planning_Stage__c;
               }
               if(this.currentadoptionStage == 'ADOPTION EFFORTS') {
                    this.showAdoptionEfforts = true;

               } else if(this.currentadoptionStage == 'EMOTIONAL TILES') {
                    this.showEmotionalTiles = true;
               }else if(this.currentadoptionStage == 'NARRATIVE') {
                    this.showNarrtive = true;
               }else if(this.currentadoptionStage == 'APPLICABLE CHILD ASSESSMENT') {
                    this.showApplicableChildAssessment = true;
                }else if(this.currentadoptionStage == 'DISCLOSURE CHECKLIST') {
                    this.showDisclosureChecklist = true;
                }
            }
        }).catch(error => {
             //this.isLoading = false;
            let errorMsg;
            this.title = "Error!";
            this.type = "error";
            if (error) {
                let errors = this.reduceErrors(error);
                errorMsg = errors.join('; ');
            } else {
                errorMsg = 'Unknown Error';
            }
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }

    stageAction(event) {

        var currentOnStageValue = event.target.value;
        //this.currentadoptionStage = currentOnStageValue;

        if(currentOnStageValue == 'ADOPTION EFFORTS') {

            if(this.currentadoptionStage == 'ADOPTION EFFORTS' || this.currentadoptionStage == 'EMOTIONAL TILES' ||  this.currentadoptionStage == 'NARRATIVE' || this.currentadoptionStage == 'APPLICABLE CHILD ASSESSMENT' || this.currentadoptionStage == 'DISCLOSURE CHECKLIST') {

                this.showAdoptionEfforts = true;
                this.showEmotionalTiles = false;
                this.showNarrtive = false;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = false;
            }
            

        } else if(currentOnStageValue == 'EMOTIONAL TILES') {

            if(this.currentadoptionStage == 'EMOTIONAL TILES' ||  this.currentadoptionStage == 'NARRATIVE' || this.currentadoptionStage == 'APPLICABLE CHILD ASSESSMENT' || this.currentadoptionStage == 'DISCLOSURE CHECKLIST') {
                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = true;
                this.showNarrtive = false;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = false;
            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  ADOPTION EFFORTS Stage';
                this.fireToastMsg();
            }

        } else if(currentOnStageValue == 'NARRATIVE') {

            if(this.currentadoptionStage == 'NARRATIVE' || this.currentadoptionStage == 'APPLICABLE CHILD ASSESSMENT' || this.currentadoptionStage == 'DISCLOSURE CHECKLIST') {

                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = false;
                this.showNarrtive = true;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = false;
            }else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  EMOTIONAL TILES Stage';
                this.fireToastMsg();
            }
            

        } else if(currentOnStageValue == 'APPLICABLE CHILD ASSESSMENT') {

            if(this.currentadoptionStage == 'APPLICABLE CHILD ASSESSMENT' || this.currentadoptionStage == 'DISCLOSURE CHECKLIST') {
                
                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = false;
                this.showNarrtive = false;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = true;
            }else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  NARRATIVE Stage';
                this.fireToastMsg();
            }
            

        } else if(currentOnStageValue == 'DISCLOSURE CHECKLIST') {

            if(this.currentadoptionStage == 'DISCLOSURE CHECKLIST') {

                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = false;
                this.showNarrtive = false;
                this.showDisclosureChecklist = true;
                this.showApplicableChildAssessment = false;
            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  APPLICABLE CHILD ASSESSMENT Stage';
                this.fireToastMsg();
            }
            

        } 

    }

    handleadoptionstage(event) {
     
        this.getIntialAdoptionPlanStage();
    }
    
    
    
}