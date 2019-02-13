({
    doInit : function(component, event, helper) {
        try{
            helper.getColumns(component);
            helper.getObjectDescribes(component);
        } catch(e) {
            console.log(e);
        }
    },
    updateSelectedMission: function(component, event, helper) {
        try{
            var compEvent = component.getEvent("selectMission");

            var selectedRows = event.getParam('selectedRows');
            
            var mission = selectedRows[0];

            console.log(mission);
            
            compEvent.setParams({
                "mission" : mission
            });
            
            compEvent.fire();
        } catch(e) {
            console.log(e);
        }
    }
})
