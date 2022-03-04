@isTest (seeAllData = false)
private class AccountContactsTest {
    @testSetup
    static void setUp() {
        Account account = new Account();
        Contact contact = new Contact();

        account.Name = 'Test Account';
        account.BillingStreet = 'Test Street';
        account.BillingCity = 'Test City';
        account.BillingState = 'Test State';
        account.BillingPostalCode = '1234';
        account.BillingCountry = 'Test Country';

        insert account;

        for (Integer i = 0; i < 5; i++) {
            contact.AccountId = account.Id;
            contact.FirstName = 'Test First Name ' + i;
            contact.LastName = account.Name + ' New Account';
        }

        insert contact;
    }

    @isTest
    static void displayContactsFromAccountTest() {
        Integer value = 0;
        Test.startTest();
        value = AccountContacts.displayContactsFromAccount();
        Test.stopTest();

        System.assert(value > 0);
    }
}