({
    doInit : function(component, event, helper) {
        try{
            helper.getMissionCriteria(component);
            helper.getColumns(component);
        } catch(e) {
            console.log(e);
        }
    }
})
