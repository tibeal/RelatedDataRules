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
                            component.set('v.criteria', Object.prototype.valueOf.call(result));
                            this.getData(component);
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
    },
    getColumns: function(component) {
        component.set('v.columns', [
            {label: 'Order', fieldName: 'Order__c', type: 'text', fixedWidth: 100},
            {label: 'Criteria', fieldName: 'Criteria__c', type: 'text'}
        ]);
    },
    getData: function(component) {
        try{
            var objectDescribes = JSON.parse( window.localStorage.getItem('objectDescribes') );
            var missionId = component.get('v.mission').Id;
            
            var missionObject = objectDescribes[missionId].object;
            var missionObjectsDescribes = objectDescribes[missionId].describes;

            var criteria = component.get('v.criteria');
            var data = [];
            var c;
            Object.keys(criteria).forEach(function(rowNo){
                c = criteria[rowNo];
                if ( c.Name.substring(0,2) === 'C-' ) {
                    // Criterion
                    data.push({
                        'Order__c': String( c.FieloPLT__Order__c ),
                        'Criteria__c': '"' + missionObjectsDescribes[missionObject].label +
                            '.' + missionObjectsDescribes[missionObject].fields[c.FieloPLT__FieldName__c].label + '"' +
                            ' ' + c.FieloPLT__Operator__c +
                            ' "' + String( c.FieloPLT__FieldType__c === 'Number' ? c.FieloPLT__NumberValue__c : c.FieloPLT__Values__c ) + '"'
                    });
                } else if( c.Name.substring(0,2) === 'CG' ) {
                    // Criterion Group
                    var criterionGroupCriterias = [];
                    var matchingCriteria = c.FieloPLT__LogicalExpression__c;
                    var objectDescribe = objectDescribes[missionId].describes[c.FieloPLT__RelatedList__c];
                    var objectName = objectDescribes[missionId].describes[c.FieloPLT__RelatedList__c].label;

                    c.FieloPLT__Criteria__r.forEach(function(criterion){
                        criterionGroupCriterias.push( '"' + objectName + '.' + criterion.FieloPLT__FieldName__c.replace(new RegExp('FieloPLT__','g'),'') + '"' +
                            ' ' + criterion.FieloPLT__Operator__c +
                            ' "' + String( criterion.FieloPLT__FieldType__c === 'Number' ? criterion.FieloPLT__NumberValue__c : criterion.FieloPLT__Values__c ) + '"'
                        );
                    });

                    var criteriaText = '';
                    if (matchingCriteria == 'ALL') {
                        criteriaText = criterionGroupCriterias.join(' AND ');
                    } else if (matchingCriteria == 'ANY') {
                        criteriaText = criterionGroupCriterias.join(' OR ');
                    } else {
                        for(var i = 1; i <= criterionGroupCriterias.length; i++) {
                            criteriaText = matchingCriteria.replace(String(i), criterionGroupCriterias[i-1]);
                        }
                    }

                    var mode = '';
                    
                    if (c.FieloPLT__Mode__c == 'COUNT') {
                        mode = c.FieloPLT__Mode__c +
                        '("' + objectDescribes[missionId].describes[c.FieloPLT__RelatedList__c].label + '"';
                    } else {
                        mode = c.FieloPLT__Mode__c +
                        '("' + objectDescribes[missionId].describes[c.FieloPLT__RelatedList__c].label +
                            '.' + objectDescribes[missionId].describes[c.FieloPLT__RelatedList__c].fields[c.FieloPLT__Field__c].label + '"';
                    }

                    criteriaText = mode + ' WHEN ' + criteriaText + ') ' + c.FieloPLT__Operator__c + ' "' + c.FieloPLT__Value__c + '"';

                    data.push({
                        'Order__c': String( c.FieloPLT__Order__c ),
                        'Criteria__c': criteriaText
                    });
                }
            });
            console.log(data);
            component.set('v.data', Object.prototype.valueOf.call(data))
        } catch(e) {
            console.log(e);
        }
    }
})
