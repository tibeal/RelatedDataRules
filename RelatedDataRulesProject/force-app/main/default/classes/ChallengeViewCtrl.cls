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

            String query = 'SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(missionFields.keySet()), ',')) + ' FROM Mission__c WHERE Challenge__c =: challengeId';

            return Database.query(query);

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
                '( SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(criterionFields.keySet()), ',')) + ' FROM Criteria__r ) ' +
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
