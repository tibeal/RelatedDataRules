({
    doInit : function(component, event, helper) {
        try{
            helper.getMissionCriteria(component);
        } catch(e) {
            console.log(e);
        }
    }
})
