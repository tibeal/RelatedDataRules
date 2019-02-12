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
}
