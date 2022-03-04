public class AccountContacts {
    public static Integer displayContactsFromAccount() {
        Integer returnValue = 0;
        Map<Id, Account> mapAccount;

        mapAccount = new Map<id, Account>([SELECT Id,
                                           (SELECT Id,
                                            FirstName
                                            FROM Contacts WHERE AccountId != NULL)
                                           FROM Account]);

        for (Account tempAcc : mapAccount.values()) {
            if (tempAcc.Contacts.size() > 0) {
                returnValue = tempAcc.Contacts.size();

                for (Contact tempCon : tempAcc.Contacts) {
                    // Additional filter to not display contacts with no firstname
                    // Refer to activity 3 (Create contact after creating new account)
                    if (tempCon.FirstName != NULL) {
                        System.debug('Account ' + tempAcc.Id + ' has ' + tempAcc.Contacts.size() + ' contacts. One of the contacts is ' + tempCon.FirstName);
                    }
                }
            }
        }

        return returnValue;
    }
}