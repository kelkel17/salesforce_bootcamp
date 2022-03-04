public class AccountTriggerHelper {
	public static void beforeInsertAccount(List<Account> newAccount) {
        for (Account tempAcc : newAccount) {
            if (tempAcc.BillingStreet == null &&
                tempAcc.BillingCity == null &&
                tempAcc.BillingCountry == null &&
                tempAcc.BillingState == null &&
                tempAcc.BillingPostalCode == null
            ) {
                   tempAcc.BillingStreet.addError('Billing Street Address must be populated.');
                   tempAcc.BillingCity.addError('Billing City Address must be populated.');
                   tempAcc.BillingCountry.addError('Billing Country Address must be populated.');
                   tempAcc.BillingState.addError('Billing Country Address must be populated.');
                   tempAcc.BillingPostalCode.addError('Billing Postal Code Address must be populated.');
            }
        }
    }

    // Create new Contact after creating new account
    public static void createContact(List<Account> newAccount) {
        List<Contact> contact = new List<Contact>();
        Contact newContact = new Contact();

        for (Account tempAcc : newAccount) {
            contact.add(new Contact(
                AccountId = tempAcc.id,
                MailingStreet = tempAcc.BillingStreet,
                MailingCity = tempAcc.BillingCity,
                MailingCountry = tempAcc.BillingCountry,
                MailingState = tempAcc.BillingState,
                MailingPostalCode = tempAcc.BillingPostalCode,
                LastName =  tempAcc.Name + ' New Account'
            ));
        }

        insert contact;
    }

    // Update Mailing Address based from Account Billing Address
    public static void updateContact(List<Account> newAccount) {
        Set<Id> accountId = new Set<Id>();

        for (Account tempAcc : newAccount) {
            accountId.add(tempAcc.Id);
        }
		List<Contact> newContact = new List<Contact>();
        List<Contact> contact = new List<Contact>([SELECT Id,
                                                           Name,
                                                           FirstName,
                                                           LastName,
                                                           AccountId,
                                                           MailingStreet,
                                                           MailingCity,
                                                           MailingCountry,
                                                           MailingState,
                                                           MailingPostalCode
                                                  FROM Contact WHERE AccountId IN :accountId]);

        for (Account tempAcc : newAccount) {
            for (Contact tempCon : contact) {
                tempCon.MailingStreet = tempAcc.BillingStreet;
                tempCon.MailingCity = tempAcc.BillingCity;
                tempCon.MailingCountry = tempAcc.BillingCountry;
                tempCon.MailingState = tempAcc.BillingState;
                tempCon.MailingPostalCode = tempAcc.BillingPostalCode;
                tempCon.FirstName = '';
                tempCon.LastName =  tempAcc.Name + ' New Account';

                newContact.add(tempCon);
            }
        }

        upsert newContact;
    }

    /*
     * Mickale L. Saturre
     * Date Created: 09/29/2021
     * Method Purpose:
     * During update of account client type this method
     * checks if how many cases are assigned to the account
     * displays error depending on the client type
	*/
    public static void checkNumberOfCases(List<Account> newAcc) {
        Id accountId;

        for (Account tempAcc : newAcc) {
            accountId = tempAcc.Id;
        }

        Map<Id, Account> queryAccount = new Map<Id, Account>([SELECT Id,
                                                              		 Client_Type__c,
                                                              		(SELECT Id FROM Cases WHERE Status != 'Closed')
                                                             		FROM Account WHERE Id = :accountId
                                                             ]);

        for (Account tempAcc : newAcc) {
            for (Account acc : queryAccount.values()) {
                if (tempAcc.Client_Type__c == 'Silver' && acc.Cases.size() >= 2) {
                    tempAcc.Client_Type__c.addError(Label.SilverError);
                } else if (tempAcc.Client_Type__c == 'Gold' && acc.Cases.size() >= 4) {
                    tempAcc.Client_Type__c.addError(Label.GoldError);
                }
            }
        }
    }
}