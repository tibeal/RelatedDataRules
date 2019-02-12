({
    getChallengeFields: function(component) {
        try{
            var action = component.get('c.getChallengeFields');
            
            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                try{
                    var state = response.getState();                
                    if (component.isValid() && state === 'SUCCESS') {
                        var result = response.getReturnValue();
                        component.set('v.fieldLabels', result);
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        var errorMsg = response.getError()[0].message;
                        toastEvent.setParams({
                            "title": 'loadCourses: ' + errorMsg,
                            "message": " ",
                            "type": "error"
                        });
                        toastEvent.fire(); 
                    }
                } catch(e) {
                    console.log(e);
                }
            });      
            // Send action off to be executed
            $A.enqueueAction(action);                   
        } catch(e) {
            console.log(e);
        }
    }
})
