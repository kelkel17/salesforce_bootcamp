public class AccountController {
    @AuraEnabled
    public static List<String> findPicklistOptions(String objAPIName, String fieldAPIname) {
        // List<PicklistWrapper> returnValue = new List<PicklistWrapper>();
        List<String> returnValue = new List<String>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.sObjectType objType = schemaMap.get(objAPIName);
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
		List<Schema.PicklistEntry> values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();

		for (Schema.PicklistEntry a: values) {
			/*
             PicklistWrapper aa = new PicklistWrapper();
			 aa.pickListLabel = a.getLabel();
			 aa.pickListValue = a.getValue();
			 returnValue.add(aa);
             */
            returnValue.add(a.getValue());
		}

        System.debug(returnValue);

        return returnValue;
    }

    public class PicklistWrapper {
		public string pickListLabel;
		public string pickListValue;
    }

    @AuraEnabled
    public static List<Account> fetchAllAccount() {
        List<Account> accountList = [SELECT Id, Name, Type, Industry, Phone FROM Account ORDER BY Name ASC NULLS LAST];

        return accountList;
    }

    @AuraEnabled
    public static void deleteAccount(Account account){
        delete account;
    }

    @AuraEnabled
    public static List<Account> saveRecords(List<Account> accounts){
        List<Account> saveAccounts = new List<Account>();

		// This will bypass the validation rule
        for (Account tempAcc : accounts) {
            tempAcc.BillingStreet = 'Test Street';
            tempAcc.BillingCity = 'Test City';
            tempAcc.BillingState = 'Test State';
            tempAcc.BillingPostalCode = 'Test Postal Code';
            tempAcc.BillingCountry = 'Test Country';
            saveAccounts.add(tempAcc);
        }

        insert saveAccounts;

        System.debug(saveAccounts);

        return saveAccounts;
    }
}