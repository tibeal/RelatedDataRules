({
    doInit : function(component, event, helper) {
        try{
            helper.getChallenges(component);
        } catch(e) {
            console.log(e);
        }
    },
    challengeSelected : function(component, event, helper) {
        try{
            console.log('challengeSelected');

            var challenge = event.getParam('challenge');

            if (challenge.Id) {
                component.set('v.showDetails', true);
            }
            
            var challengeDetails = component.find('challenge-details');

            if ( challengeDetails.length > 0 ) {
                challengeDetails = challengeDetails[0];
            }
            
            challengeDetails.set('v.recordId', challenge.Id);
            challengeDetails.set('v.record', {});
            challengeDetails.set('v.record', challenge);
            challengeDetails.set('v.simpleRecord', challenge);
            
            component.set('v.record', challenge);
            
        } catch(e) {
            console.log(e);
        }
    },
    missionSelected : function(component, event, helper) {
        try{
            console.log('missionSelected');

            var mission = event.getParam('mission');
            
            component.set('v.mission', {});
            component.set('v.mission', mission);
            
        } catch(e) {
            console.log(e);
        }
    }
})
