public class CityCensusTriggerHelper {
    public static void beforeInsertUpdate(List<City_Census__c> newCityCensus) {
        Group queueCity = fetchCorrespondingQueueCity(newCityCensus);

        // Update City for all Contacts with no City
        Contacts.updateCity();
        
        for (City_Census__c tempCityCensus : newCityCensus) {
            if (tempCityCensus.City__c != NULL || !String.isBlank(tempCityCensus.City__c)) {
                if (!tempCityCensus.Auto_Approve__c) {
                    tempCityCensus.Approval_Status__c = 'For Approval';
                    tempCityCensus.Approved_By__c = '';
                } else {
                    tempCityCensus.Approval_Status__c = 'Approved';
                    tempCityCensus.Approved_By__c = queueCity.Name;
                }
                
                tempCityCensus.OwnerId = queueCity.Id;
            } else {
                tempCityCensus.City__c.addError('City must have a value');
            } 
        }
    }
    
    // Create residents after approving
    public static void afterInsertUpdate(List<City_Census__c> newCityCensus) {
        Boolean isApproved = false;

        for (City_Census__c tempCityCensus : newCityCensus) {
            if (tempCityCensus.City__c != NULL || !String.isBlank(tempCityCensus.City__c)) {
                if (tempCityCensus.Auto_Approve__c) {
                    isApproved = true;
                }
            }
        }
        
        if (isApproved) {
            // method.class
            Residents.insertResidents(newCityCensus);
        }
    }
    
    /*
     * Mickale L. Saturre
     * Created at: 10/01/2021
     * Custom Methods
	*/
    public static Group fetchCorrespondingQueueCity(List<City_Census__c> newCityCensus) {
        String city = checkIfCityIsNull(newCityCensus);
        Group queueCity;
        
        // Try catch block to show users that city must not be null
        try {
            queueCity = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name LIKE :city];
        } catch(System.QueryException error) {
            // QueryException because it's expected return value is null or 0
            for (City_Census__c tempCityCensus : newCityCensus) {
                tempCityCensus.City__c.addError('City must have a value to assign corresponding City Approvers');
            }
        }
        
        return queueCity;
    }
    
    public static String checkIfCityIsNull(List<City_Census__c> newCityCensus) {
        String city;
        
        for (City_Census__c tempCityCensus : newCityCensus) {
            if (String.isBlank(tempCityCensus.City__c) || tempCityCensus.City__c == NULL) {
                city = 'City field must have a value';
            } else {
            	city = tempCityCensus.City__c + '%';
            }
        }
        
        return city;
    }
}