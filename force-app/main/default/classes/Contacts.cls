public class Contacts {
    public static void updateCity() {
        List<Contact> contactList = [SELECT ID, AccountId, City__c FROM Contact WHERE City__c = null];
        List<String> cities = new List<String>();
        List<Approval_Mapping__mdt> approvalMappingMetaData = [SELECT City__c FROM Approval_Mapping__mdt];

        for (Approval_Mapping__mdt temp : approvalMappingMetaData) {
            cities.add(temp.City__c);
        }

        System.debug(cities);

        for (Contact c : contactList){
            Integer d = (Integer) (Math.random() * approvalMappingMetaData.size());
            c.City__c = cities[d];
        }

        update contactList;

    }
}