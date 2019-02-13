({
    getMissions: function(component) {
        try{
            var action = component.get('c.getMissions');
            var challengeId = component.get('v.record').Id;

            action.setParams({'challengeId': challengeId});

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                try{
                    var state = response.getState();                
                    if (component.isValid() && state === 'SUCCESS') {
                        var result = response.getReturnValue();
                        console.log(result);
                        
                        component.set('v.missions', result);

                        this.getData(component);
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
    },
    getObjectDescribes: function(component) {
        try{
            var action = component.get('c.getChallengeObjects');
            var challengeId = component.get('v.record').Id;

            action.setParams({'challengeId': challengeId});

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                try{
                    var state = response.getState();                
                    if (component.isValid() && state === 'SUCCESS') {
                        var result = response.getReturnValue();
                        console.log(result);
                        window.localStorage.setItem('objectDescribes', result);

                        this.getMissions(component);
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
        } catch(e) {
            console.log(e);
        }
    },
    getColumns: function(component) {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Objectve Type', fieldName: 'FieloPLT__ObjectiveType__c', type: 'text'},
            {label: 'Field to Aggregate', fieldName: 'FieloPLT__FieldToAggregate__c', type: 'text'},
            {label: 'Operator', fieldName: 'FieloPLT__Operator__c', type: 'text'},
            {label: 'Value', fieldName: 'FieloPLT__ObjectiveValue__c', type: 'text'},
            {label: 'Rewarding Time', fieldName: 'FieloPLT__RewardingTime__c', type: 'text'},
            {label: 'Table Type', fieldName: 'FieloPLT__TableType__c', type: 'text'},
            {label: 'Matching Criteria', fieldName: 'FieloPLT__LogicalExpression__c', type: 'text'},
            {label: 'Order', fieldName: 'FieloPLT__Order__c', type: 'text'}
        ]);
    },
    getData: function(component) {
        var missions = component.get('v.missions');
        var objectDescribes = JSON.parse( window.localStorage.getItem('objectDescribes') );

        missions.forEach(function(m){
            var missionId = m.Id;
            var missionObject = objectDescribes[missionId].object;
            var missionObjectsDescribes = objectDescribes[missionId].describes;

            m.FieloPLT__FieldToAggregate__c = missionObjectsDescribes[missionObject].label + '.' + missionObjectsDescribes[missionObject].fields[m.FieloPLT__FieldToAggregate__c].label;
            
            m.FieloPLT__ObjectiveValue__c = String(m.FieloPLT__ObjectiveValue__c);
        });

        component.set('v.data', Object.prototype.valueOf.call(missions));
        
        console.log(component.get('v.data'));
    }
})
