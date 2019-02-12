({
    getMissionCriteria: function(component) {
        try{
            console.log('getMissionCriteria');
            var action = component.get('c.getMissionCriteria');

            if ( component.get('v.mission') ) {
                var missionId = component.get('v.mission').Id;
    
                action.setParams({'missionId': missionId});
    
                // Add callback behavior for when response is received
                action.setCallback(this, function(response) {
                    try{
                        var state = response.getState();                
                        if (component.isValid() && state === 'SUCCESS') {
                            var result = response.getReturnValue();
                            console.log(result);
                            component.set('v.criteria', result);
                        } else {
                            var errorMsg = response.getError()[0].message;
                            console.log(errorMsg);
                        }
                    } catch(e) {
                        console.log(e);
                    }
                });
                // Send action off to be executed
                $A.enqueueAction(action);
            }
        } catch(e) {
            console.log(e);
        }
    }
})
