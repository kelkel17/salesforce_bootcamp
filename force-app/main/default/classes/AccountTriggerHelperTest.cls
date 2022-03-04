@isTest (seeAllData = false)
private class AccountTriggerHelperTest {
	@testSetup
    static void setup() {
        Account account = new Account();
        account.Name = 'Test Account';
		account.BillingStreet = 'Test Street';
		account.BillingCity = 'Test City';
		account.BillingState = 'Test State';
		account.BillingPostalCode = '1234';
		account.BillingCountry = 'Test Country';
        account.Client_Type__c = 'Gold';

        insert account;

        Contact contact = new Contact();
        contact.LastName = account.Name + ' New Account';
        contact.MailingStreet = account.BillingStreet;
        contact.MailingCity = account.BillingCity;
        contact.MailingState = account.BillingState;
        contact.MailingPostalCode = account.BillingPostalCode;
        contact.MailingCountry = account.BillingCountry;
        contact.AccountId = account.Id;

        insert contact;

        Case newCase = new Case();

        for (Integer i = 0; i < 4; i++) {
            newCase.AccountId = account.Id;
            newCase.Status = 'New';
            newCase.Origin = 'Phone';
        }

        insert newCase;
    }

    @isTest
    static void beforeInsertAccountWithErrorTest() {
        Boolean hasError = false;
        Account account = new Account();
        account.Name = 'Test Account';

        Test.startTest();
        try {
            insert account;
        } catch(Exception error) {
         	hasError = true;
        }
        Test.stopTest();

        System.assertEquals(true, hasError, 'hasError (['+ hasError +']) != true');
    }

    @isTest
    static void beforeInsertAccountWithOutErrorTest() {
        Boolean hasError = false;
        Account account = new Account();
        account.Name = 'Test Account';
		account.BillingStreet = 'Test Street';
		account.BillingCity = 'Test City';
		account.BillingState = 'Test State';
		account.BillingPostalCode = '1234';
		account.BillingCountry = 'Test Country';

        Test.startTest();
        try {
            insert account;
        } catch(Exception error) {
         	hasError = true;
        }
        Test.stopTest();

        System.assertNotEquals(true, hasError, 'hasError (['+ hasError +']) != true');
    }


    @isTest
    static void creatAccountTest() {
        // single record
        Account account = [SELECT Id,
                                BillingCity,
                                BillingStreet,
                                BillingState,
                                BillingPostalCode,
                                BillingCountry,
                                Name
                            FROM Account WHERE Name = 'Test Account'];

        Contact contact = new Contact();
        contact.LastName = account.Name + ' New Account';
        contact.MailingStreet = account.BillingStreet;
        contact.MailingCity = account.BillingCity;
        contact.MailingState = account.BillingState;
        contact.MailingPostalCode = account.BillingPostalCode;
        contact.MailingCountry = account.BillingCountry;
        contact.AccountId = account.Id;

        Test.startTest();
        insert contact;
        Test.stopTest();

       	Contact con = [SELECT Id,
                           MailingStreet,
                           MailingCity,
                           MailingState,
                           MailingPostalCode,
                           MailingCountry
                       FROM Contact WHERE Id =: contact.Id];

        System.assertEquals(account.BillingStreet, con.MailingStreet, 'Contact mailing street ['+ con.MailingStreet +'] != Account billing street ['+ account.BillingStreet +']');
        System.assertEquals(account.BillingCity, con.MailingCity, 'Contact mailing city ['+ con.MailingCity +'] != Account billing city ['+ account.BillingCity +']');
        System.assertEquals(account.BillingState, con.MailingState, 'Contact mailing state ['+ con.MailingState +'] != Account billing state ['+ account.BillingState +']');
        System.assertEquals(account.BillingPostalCode, con.MailingPostalCode, 'Contact mailing postal code ['+ con.MailingPostalCode +'] != Account billing postal code ['+ account.BillingPostalCode +']');
        System.assertEquals(account.BillingCountry, con.MailingCountry, 'Contact mailing country ['+ con.MailingCountry +'] != Account billing country ['+ account.BillingCountry +']');
    }

    @isTest
    static void updateContactTest() {
        Account account = [SELECT Id,
                                BillingCity,
                                BillingStreet,
                                BillingState,
                                BillingPostalCode,
                                BillingCountry,
                                BillingAddress,
                                Name
                            FROM Account WHERE Name = 'Test Account'];

        account.Name = 'Update Test Account';
		account.BillingStreet = 'Update Test Street';
		account.BillingCity = 'Update Test City';
		account.BillingState = 'Update Test State';
		account.BillingPostalCode = '4321';
		account.BillingCountry = 'Update Test Country';

        // array of contacts
        List<Contact> contact = [SELECT Id,
                                   MailingStreet,
                                   MailingCity,
                                   MailingState,
                                   MailingPostalCode,
                                   MailingCountry,
                                   MailingAddress
                               FROM Contact WHERE AccountId =: account.Id];

        for (Contact tempCon : contact) {
            tempCon.LastName = account.Name + ' New Account';
            tempCon.MailingStreet = account.BillingStreet;
            tempCon.MailingCity = account.BillingCity;
            tempCon.MailingState = account.BillingState;
            tempCon.MailingPostalCode = account.BillingPostalCode;
            tempCon.MailingCountry = account.BillingCountry;
        }

        Test.startTest();
        update account;
        update contact;
        Test.stopTest();

        for (Contact tempCon : contact) {
            System.assertEquals(account.BillingStreet, tempCon.MailingStreet, 'Contact mailing street ['+ tempCon.MailingStreet +'] == Account billing street ['+ account.BillingStreet +']');
            System.assertEquals(account.BillingCity, tempCon.MailingCity, 'Contact mailing city ['+ tempCon.MailingCity +'] == Account billing city ['+ account.BillingCity +']');
            System.assertEquals(account.BillingState, tempCon.MailingState, 'Contact mailing state ['+ tempCon.MailingState +'] == Account billing state ['+ account.BillingState +']');
            System.assertEquals(account.BillingPostalCode, tempCon.MailingPostalCode, 'Contact mailing postal code ['+ tempCon.MailingPostalCode +'] == Account billing postal code ['+ account.BillingPostalCode +']');
            System.assertEquals(account.BillingCountry, tempCon.MailingCountry, 'Contact mailing country ['+ tempCon.MailingCountry +'] == Account billing country ['+ account.BillingCountry +']');
       	}
    }

    @isTest
    static void checkNumberOfCasesTest() {
        Boolean hasError = false;
        String errorMessage;
        Account mapAccount = [SELECT Id,
                              Client_Type__c,
                              (SELECT Id FROM Cases WHERE Status != 'Closed')
                              FROM Account WHERE Name = 'Test Account'];

        mapAccount.Client_Type__c = 'Silver';
        update mapAccount;

        Test.startTest();
        try {
            update mapAccount;
        } catch(Exception error) {
            hasError = true;
        }
        Test.stopTest();

        System.assertEquals(Label.SilverError, 'Silver Clients can only have 1 Active Case');
    }
}