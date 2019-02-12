({
    doInit : function(component, event, helper) {
        try{
            helper.getChallengeFields(component);
        } catch(e) {
            console.log(e);
        }
    }
})
