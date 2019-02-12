({
    handleChallengeChange : function(component, event, helper) {
        try{
            var compEvent = component.getEvent("selectChallenge");

            var challengeId = '';
            if (component.find('challenge-selector')) {
                challengeId = component.find('challenge-selector').get('v.value');
            }

            var challenges = component.get('v.challenges');

            challenges = challenges.filter(function(c) {
                return c.Id === challengeId;
            });

            compEvent.setParams({
                "challenge" : challenges.length > 0 ? challenges[0] : null
            });

            compEvent.fire();
        } catch(e) {
            console.log(e);
        }
    }
})
