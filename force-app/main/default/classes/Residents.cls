public class Residents {
    public static void insertResidents(List<City_Census__c> newCityCensus) {
    	List<Resident__c> newResidentList = new List<Resident__c>();
        String cityCensusId;
        String city;

        for (City_Census__c tempCityCensus : newCityCensus) {
            city = tempCityCensus.City__c;
            cityCensusId = tempCityCensus.Id;
        }

        // Query all contacts with the city census city
        List<Contact> contactList = [SELECT Id, City__c, Salutation FROM Contact WHERE City__c = :city];
        // Get All available record types from resident object
        List<String> availableCaseTypes = GetAvailableRecordTypeIdsForSObject(Resident__c.SObjectType);
        // [0 => 'Female', 1 => 'Male']

        for (Contact tempCon : contactList) {
            if (!String.isBlank(tempCon.Salutation) || tempCon.Salutation != null) {
                if (tempCon.Salutation.contains('Mr')) {
                    newResidentList.add(new Resident__c(
                        City__c = city,
                        City_Census__c = cityCensusId,
                        Contact_Record__c = tempCon.Id,
                        RecordTypeId = availableCaseTypes[1]
                    ));
                } else if (tempCon.Salutation.contains('Ms') || tempCon.Salutation.contains('Mrs')) {
                    newResidentList.add(new Resident__c(
                        City__c = city,
                        City_Census__c = cityCensusId,
                        Contact_Record__c = tempCon.Id,
                        RecordTypeId = availableCaseTypes[0]
                    ));
                }
            }
        }

        try {
            insert newResidentList;
        } catch(System.DmlException error) {
            System.debug(error.getMessage());
        }
    }

    public static List<String> GetAvailableRecordTypeIdsForSObject(Schema.SObjectType objType) {
        List<String> ids = new List<String>();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        // If there are 2 or more RecordTypes...
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
                // Ignore the Master Record Type, whose Id always ends with 'AAA'.
                // We check the Id because Name can change depending on the user's language.
                if (i.isAvailable() && !String.valueOf(i.getRecordTypeId()).endsWith('AAA')) {
                    ids.add(i.getRecordTypeId());
                }
            }
        }
        // Otherwise there's just the Master record type,
        // so add it in, since it MUST always be available
        else ids.add(infos[0].getRecordTypeId());

        return ids;
    }
}