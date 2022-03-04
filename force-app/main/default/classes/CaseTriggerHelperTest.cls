@isTest (seeAllData = false)
private class CaseTriggerHelperTest {
	@testSetup
    static void setUp() {
        // Diamond Account Creation
        Account diamondAccount = new Account();
        List<Case> diamondCaseList = new List<Case>();

        diamondAccount.Name = 'Test Diamond Account';
        diamondAccount.BillingStreet = 'Test Street';
        diamondAccount.BillingCity = 'Test City';
        diamondAccount.BillingState = 'Test State';
        diamondAccount.BillingPostalCode = '1234';
        diamondAccount.BillingCountry = 'Test Country';
        diamondAccount.Client_Type__c = 'Diamond';

        insert diamondAccount;

        for (Integer i = 0; i < 3; i++) {
            diamondCaseList.add(new Case(
            	AccountId = diamondAccount.Id,
                Status = 'New',
                Origin = 'Phone'
            ));
        }

        insert diamondCaseList;

        // Gold Account Creation
        Account goldAccount = new Account();
        List<Case> goldCaseList = new List<Case>();

        goldAccount.Name = 'Test Gold Account';
        goldAccount.BillingStreet = 'Test Street';
        goldAccount.BillingCity = 'Test City';
        goldAccount.BillingState = 'Test State';
        goldAccount.BillingPostalCode = '1234';
        goldAccount.BillingCountry = 'Test Country';
        goldAccount.Client_Type__c = 'Gold';

        insert goldAccount;

        for (Integer i = 0; i < 3; i++) {
            goldCaseList.add(new Case(
            	AccountId = goldAccount.Id,
                Status = 'New',
                Origin = 'Phone'
            ));
        }

        insert goldCaseList;

        // Silver Account and Case Creation
        Account silverAccount = new Account();

        silverAccount.Name = 'Test Silver Account';
        silverAccount.BillingStreet = 'Test Street';
        silverAccount.BillingCity = 'Test City';
        silverAccount.BillingState = 'Test State';
        silverAccount.BillingPostalCode = '1234';
        silverAccount.BillingCountry = 'Test Country';
        silverAccount.Client_Type__c = 'Silver';

        insert silverAccount;

        Case silverCase = new Case();
        silverCase.AccountId = silverAccount.Id;
        silverCase.Status = 'New';
        silverCase.Origin = 'Phone';

        insert silverCase;
    }

	@isTest
    static void beforeInsertGoldAccountTest() {
        Boolean hasError = false;
        Account account = [SELECT Id,
                               Client_Type__c,
                               (SELECT Id FROM Cases WHERE Status != 'Closed')
                           FROM Account WHERE Name = 'Test Gold Account'];

        Case newCase = new Case();
        newCase.AccountId = account.Id;
        newCase.Status = 'New';
        newCase.Origin = 'Phone';

        Test.startTest();
        try {
            insert newCase;
        } catch(Exception Error) {
			hasError = true;
        }
        Test.stopTest();

        if (newCase.Status != 'Closed') {
            if (account.Client_Type__c == 'Silver' && account.Cases.size() + 1 > 1) {
                System.assertEquals(Label.SilverError, 'Silver Clients can only have 1 Active Case');
            } else if (account.Client_Type__c == 'Gold' && account.Cases.size() + 1 > 3) {
                System.assertEquals(Label.GoldError, 'Gold Clients can only have 3 Active Cases');
            }
        }

        System.assertEquals(true, hasError, '['+ hasError +'] != true');
    }

    @isTest
    static void beforeInsertSilverAccountTest() {
        Boolean hasError = false;
        Account account = [SELECT Id,
                               Client_Type__c,
                               (SELECT Id FROM Cases WHERE Status != 'Closed')
                           FROM Account WHERE Name = 'Test Silver Account'];

        Case newCase = new Case();
        newCase.AccountId = account.Id;
        newCase.Status = 'New';
        newCase.Origin = 'Phone';

        Test.startTest();
        try {
            insert newCase;
        } catch(Exception Error) {
			hasError = true;
        }
        Test.stopTest();

        if (newCase.Status != 'Closed') {
            if (account.Client_Type__c == 'Silver' && account.Cases.size() + 1 > 1) {
                System.assertEquals(Label.SilverError, 'Silver Clients can only have 1 Active Case');
            } else if (account.Client_Type__c == 'Gold' && account.Cases.size() + 1 > 3) {
                System.assertEquals(Label.GoldError, 'Gold Clients can only have 3 Active Cases');
            }
        }

        System.assertEquals(true, hasError, '['+ hasError +'] != true');
    }

    @isTest
    static void beforeInsertDiamondAccountTest() {
        Boolean hasError = false;
        Account account = [SELECT Id,
                               Client_Type__c,
                               (SELECT Id FROM Cases WHERE Status != 'Closed')
                           FROM Account WHERE Name = 'Test Diamond Account'];

        Case newCase = new Case();
        newCase.AccountId = account.Id;
        newCase.Status = 'New';
        newCase.Origin = 'Phone';

        Test.startTest();
        try {
            insert newCase;
        } catch(Exception Error) {
			hasError = true;
        }
        Test.stopTest();

        if (newCase.Status != 'Closed') {
            if (account.Client_Type__c == 'Silver' && account.Cases.size() + 1 > 1) {
                System.assertEquals(Label.SilverError, 'Silver Clients can only have 1 Active Case');
            } else if (account.Client_Type__c == 'Gold' && account.Cases.size() + 1 > 3) {
                System.assertEquals(Label.GoldError, 'Gold Clients can only have 3 Active Cases');
            }
        }

        System.assertNotEquals(true, hasError, '['+ hasError +'] != true');
    }

    @isTest
    static void updateAccountFieldsRelatedToInsertActiveCaseTest() {
        Integer closedCases = 0;
        Integer activeCases = 0;
        Boolean hasError = false;

        Account account = [SELECT Id,
                           Active_Cases__c,
                           Closed_Cases__c,
                           Total_Cases__c,
                           Last_Updated_Case__c,
                           (SELECT Id, Status, CaseNumber FROM Cases ORDER BY LastModifiedDate DESC)
                           FROM Account WHERE Name =: 'Test Diamond Account'];

        Case newCase = new Case();
        newCase.AccountId = account.Id;
        newCase.Status = 'New';
        newCase.Origin = 'Email';

        for (Case tempCase : account.Cases) {
            if (tempCase.Status == 'Closed') {
                closedCases += 1;
            } else {
                activeCases += 1;
            }
        }

        account.Active_Cases__c = activeCases;
        account.Closed_Cases__c = closedCases;
        account.Total_Cases__c = activeCases + closedCases;
        account.Last_Updated_Case__c = newCase.CaseNumber;

        Test.startTest();
        try {
            insert newCase;
            update account;
        } catch (Exception error) {
            hasError = true;
        }
        Test.stopTest();

        System.assertNotEquals(true, hasError, '['+ hasError +'] != true');
    }

    @isTest
    static void updateAccountFieldsRelatedToInsertClosedCaseTest() {
        Integer closedCases = 0;
        Integer activeCases = 0;
        Boolean hasError = false;

        Account account = [SELECT Id,
                           Active_Cases__c,
                           Closed_Cases__c,
                           Total_Cases__c,
                           Last_Updated_Case__c,
                           (SELECT Id, Status, CaseNumber FROM Cases ORDER BY LastModifiedDate DESC)
                           FROM Account WHERE Name =: 'Test Diamond Account'];

        Case newCase = new Case();
        newCase.AccountId = account.Id;
        newCase.Status = 'Closed';
        newCase.Origin = 'Email';

        for (Case tempCase : account.Cases) {
            if (tempCase.Status == 'Closed') {
                closedCases += 1;
            } else {
                activeCases += 1;
            }
        }

        account.Active_Cases__c = activeCases;
        account.Closed_Cases__c = closedCases;
        account.Total_Cases__c = activeCases + closedCases;
        account.Last_Updated_Case__c = newCase.CaseNumber;

        Test.startTest();
        try {
            insert newCase;
            update account;
        } catch (Exception error) {
            hasError = true;
        }
        Test.stopTest();

        System.assertNotEquals(true, hasError, '['+ hasError +'] != true');
    }

    @isTest
    static void updateAccountFieldsRelatedToUpdateClosedCaseTest() {
        Integer closedCases = 0;
        Integer activeCases = 0;
        String caseNumber;
        Boolean hasError = false;

        Account account = [SELECT Id,
                           Active_Cases__c,
                           Closed_Cases__c,
                           Total_Cases__c,
                           Last_Updated_Case__c,
                           (SELECT Id, Status, CaseNumber FROM Cases ORDER BY LastModifiedDate DESC)
                           FROM Account WHERE Name =: 'Test Diamond Account'];


        for (Case tempCase : account.Cases) {
            tempCase.Status = 'Closed';

            if (tempCase.Status == 'Closed') {
                closedCases += 1;
            } else {
                activeCases += 1;
            }
        }

        account.Active_Cases__c = activeCases;
        account.Closed_Cases__c = closedCases;
        account.Total_Cases__c = activeCases + closedCases;
        account.Last_Updated_Case__c = caseNumber;

        Test.startTest();
        try {
            update account.Cases;
            update account;
        } catch (Exception error) {
            hasError = true;
        }
        Test.stopTest();

        System.assertNotEquals(true, hasError, '['+ hasError +'] != true');
    }

    @isTest
    static void updateAccountFieldsRelatedToUpdateActiveCaseTest() {
        Integer closedCases = 0;
        Integer activeCases = 0;
        String caseNumber;
        Boolean hasError = false;

        Account account = [SELECT Id,
                           Active_Cases__c,
                           Closed_Cases__c,
                           Total_Cases__c,
                           Last_Updated_Case__c,
                           (SELECT Id, Status, CaseNumber FROM Cases ORDER BY LastModifiedDate DESC)
                           FROM Account WHERE Name =: 'Test Diamond Account'];


        for (Case tempCase : account.Cases) {
            tempCase.Status = 'Active';

            if (tempCase.Status == 'Closed') {
                closedCases += 1;
            } else {
                activeCases += 1;
            }
        }

        account.Active_Cases__c = activeCases;
        account.Closed_Cases__c = closedCases;
        account.Total_Cases__c = activeCases + closedCases;
        account.Last_Updated_Case__c = caseNumber;

        Test.startTest();
        try {
            update account.Cases;
            update account;
        } catch (Exception error) {
            hasError = true;
        }
        Test.stopTest();

        System.assertNotEquals(true, hasError, '['+ hasError +'] != true');
    }
}