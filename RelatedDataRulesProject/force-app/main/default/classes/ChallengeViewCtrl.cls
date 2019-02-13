public class ChallengeViewCtrl {
    
    @AuraEnabled
    public static List<SObject> getChallenges(){
        try{
            Map<String,Schema.SObjectField> challengeFields = Schema.SObjectType.Challenge__c.fields.getMap();

            String query = 'SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(challengeFields.keySet()), ',')) + ' FROM Challenge__c';

            return Database.query(query);

        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Object getChallengeFields(){
        try{
            Map<String,Schema.SObjectField> challengeFields = Schema.SObjectType.Challenge__c.fields.getMap();

            Map<String,String> fieldsMap = new Map<String,String>();

            for (Schema.SObjectField f : challengeFields.values()) {
                fieldsMap.put(f.getDescribe().getName(), f.getDescribe().getLabel());
            }

            return (Object) fieldsMap;

        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SObject> getMissions(Id challengeId){
        try{
            Map<String,Schema.SObjectField> missionFields = Schema.SObjectType.Mission__c.fields.getMap();

            String query = 'SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(missionFields.keySet()), ',')) + ' FROM Mission__c WHERE Challenge__c =: challengeId Order By Name';

            return Database.query(query);

        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getChallengeObjects(Id challengeId){
        try{
            Map<String,Schema.SObjectField> missionFields = Schema.SObjectType.Mission__c.fields.getMap();
            Set<String> objectNames = new Set<String>();

            String query = 'SELECT ' +
                'Action__r.RuleTrigger__r.Object__c, ' +
                String.escapeSingleQuotes(String.join(new List<String>(missionFields.keySet()), ',')) + ', ' +
                '(SELECT RelatedList__c FROM Criteria_Group__r)' +
                ' FROM Mission__c WHERE Challenge__c =: challengeId';
            
            List<Mission__c> missions = Database.query(query);
            List<CriterionGroup__c> criterionGroups = new List<CriterionGroup__c>();

            Map<String, Map<String, Object>> objectsDescribes = new Map<String, Map<String, Object>>();

            Schema.DescribeSObjectResult objectDescribe;
            Schema.DescribeSObjectResult childObjectDescribe;
            Map<String, Object> fieldsMap = new Map<String, Object>();
            Map<String, String> fieldInfo = new Map<String, String>();
            Map<String, Object> missionObjects = new Map<String, Object>();

            for (Mission__c m : missions) {
                objectDescribe = Schema.describeSObjects(new List<String>{m.Action__r.RuleTrigger__r.Object__c})[0];

                if ( !objectsDescribes.containsKey(m.Action__r.RuleTrigger__r.Object__c) ) {
                    objectsDescribes.put(m.Action__r.RuleTrigger__r.Object__c, new Map<String, Object>());
                    objectsDescribes.get(m.Action__r.RuleTrigger__r.Object__c).put('label', (Object) objectDescribe.getLabel());
                    objectsDescribes.get(m.Action__r.RuleTrigger__r.Object__c).put('labelPlural', (Object) objectDescribe.getLabelPlural());
                    
                    fieldsMap = new Map<String, Object>();
                    for( SobjectField fieldObj : objectDescribe.fields.getMap().values() ) {
                        fieldInfo = new Map<String, String>();
                        fieldInfo.put('name', fieldObj.getDescribe().getName() );
                        fieldInfo.put('label', fieldObj.getDescribe().getLabel() );
                        fieldsMap.put(fieldObj.getDescribe().getName(), (Object) fieldInfo);
                    }
                    
                    objectsDescribes.get(m.Action__r.RuleTrigger__r.Object__c).put('fields', (Object) fieldsMap);
                }

                if ( !m.Criteria_Group__r.isEmpty() ) {
                    for (CriterionGroup__c cg : m.Criteria_Group__r) {
                        for (Schema.ChildRelationship cr : objectDescribe.getChildRelationships()) {
                            if ( cr.getRelationshipName() == cg.RelatedList__c ) {
                                childObjectDescribe = cr.getChildSObject().getDescribe();

                                if ( !objectsDescribes.containsKey( childObjectDescribe.getName() ) ) {
                                    objectsDescribes.put(childObjectDescribe.getName(), new Map<String, Object>());
                                    objectsDescribes.get(childObjectDescribe.getName()).put('label', (Object) childObjectDescribe.getLabel());
                                    objectsDescribes.get(childObjectDescribe.getName()).put('labelPlural', (Object) childObjectDescribe.getLabelPlural());
                                    
                                    fieldsMap = new Map<String, Object>();
                                    for( SobjectField fieldObj : childObjectDescribe.fields.getMap().values() ) {
                                        fieldInfo = new Map<String, String>();
                                        fieldInfo.put('name', fieldObj.getDescribe().getName() );
                                        fieldInfo.put('label', fieldObj.getDescribe().getLabel() );
                                        fieldsMap.put(fieldObj.getDescribe().getName(), (Object) fieldInfo);
                                    }
                                    
                                    objectsDescribes.get(childObjectDescribe.getName()).put('fields', (Object) fieldsMap);

                                    objectsDescribes.put(cg.RelatedList__c, objectsDescribes.get(childObjectDescribe.getName()) );
                                }
                            }
                        }
                    }
                }

                missionObjects.put(m.Id, (Object) new Map<String,Object>{
                    'object' => (Object) m.Action__r.RuleTrigger__r.Object__c,
                    'describes' => (Object) objectsDescribes
                } );
            }

            return JSON.serialize(missionObjects);

        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<Integer, Object> getMissionCriteria(Id missionId){
        try{
            Map<String,Schema.SObjectField> criterionFields = Schema.SObjectType.Criterion__c.fields.getMap();
            Map<String,Schema.SObjectField> criterionGroupFields = Schema.SObjectType.CriterionGroup__c.fields.getMap();

            Map<Integer, Object> criteriaByOrder = new Map<Integer, Object>();

            String query = 'SELECT Id, Name, ' +
                '( SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(criterionFields.keySet()), ',')) + ' FROM MissionCriteria__r ), ' +
                '( SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(criterionGroupFields.keySet()), ',')) + ' FROM Criteria_Group__r ) ' +
                ' FROM Mission__c WHERE Id =: missionId';

            List<Mission__c> missions = Database.query(query);

            if ( !missions[0].MissionCriteria__r.isEmpty() ) {
                for (Criterion__c c : missions[0].MissionCriteria__r) {
                    criteriaByOrder.put((Integer)c.Order__c, (Object) c);
                }
            }

            if ( !missions[0].Criteria_Group__r.isEmpty() ) {
                query = 'SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(criterionGroupFields.keySet()), ',')) + ', ' +
                '( SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(criterionFields.keySet()), ',')) + ' FROM Criteria__r ORDER BY Order__c) ' +
                ' FROM CriterionGroup__c WHERE Mission__c =: missionId ORDER BY Order__c';

                Map<Id, CriterionGroup__c> cgMap = new Map<Id, CriterionGroup__c>( (List<CriterionGroup__c>) Database.query(query) );

                for (CriterionGroup__c cg : missions[0].Criteria_Group__r) {
                    criteriaByOrder.put((Integer)cg.Order__c, (Object) cgMap.get(cg.Id));
                }
            }

            return criteriaByOrder;

        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
