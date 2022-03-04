public class CaseTriggerHelper {
    public static void beforeInsert(List<Case> newCase) {
        List<Case> caseFromAccount;
        String caseStatus;
        Set<Id> accountId = new Set<Id>();

        for (Case tempCase : newCase) {
            accountId.add(tempCase.AccountId);
        }

        Map<Id, Account> queryAccount = new Map<Id, Account>([SELECT Id,
                                                              		 Client_Type__c,
                                                              		(SELECT Id FROM Cases WHERE Status != 'Closed')
                                                             		FROM Account WHERE Id IN: accountId
                                                             ]);

        for (Case tempCase : newCase) {
            for (Account tempAcc : queryAccount.values()) {
                if (tempCase.Status != 'Closed') {
                    if (tempAcc.Client_Type__c == 'Silver' && tempAcc.Cases.size() + 1 > 1) {
                        tempCase.addError(Label.SilverError);
                    } else if (tempAcc.Client_Type__c == 'Gold' && tempAcc.Cases.size() + 1 > 3) {
                        tempCase.addError(Label.GoldError);
                    }
                }
            }
        }
    }

    /* Activity 5
    * Author: Mickale L. Saturre
    * Date Created: 09/29/2021
    * Update Account Fields Related to Cases
    *
    */
    public static void updateAccountFieldsRelatedToCase(List<Case> newCase, Boolean isTriggerTypeDelete) {
        Set<Id> accountId = new Set<Id>();
        List<Account> newAccount = new List<Account>();

        Integer activeCases = 0;
        Integer closedCases = 0;
        String lastUpdatedCase;
        String caseStatus;

        // Set AccountIDs
        for (Case tempCase : newCase) {
            accountId.add(tempCase.AccountId);
            caseStatus = tempCase.Status;
            lastUpdatedCase = tempCase.CaseNumber;
        }

        Map<Id, Account> queryAccount = new Map<Id, Account>([SELECT Id,
                                                              		 Active_Cases__c,
                                                              		 Closed_Cases__c,
                                                              		 Total_Cases__c,
                                                                     Last_Updated_Case__c,
                                                              		(SELECT Id, Status, CaseNumber FROM Cases ORDER BY LastModifiedDate DESC)
                                                             	FROM Account WHERE Id IN: accountId
                                                              ]);

        for (Account tempAcc : queryAccount.values()) {
            for (Case tempCase : tempAcc.Cases) {
                if (tempCase.Status == 'Closed') {
                    closedCases += 1;
                } else {
                    activeCases += 1;
                }
            }

            tempAcc.Active_Cases__c = isTriggerTypeDelete && caseStatus != 'Closed' ? tempAcc.Active_Cases__c -1 : activeCases;
            tempAcc.Closed_Cases__c = isTriggerTypeDelete && caseStatus == 'Closed' ? tempAcc.Closed_Cases__c -1 : closedCases;
            tempAcc.Total_Cases__c = activeCases + closedCases;
            tempAcc.Last_Updated_Case__c = lastUpdatedCase;

            newAccount.add(tempAcc);
        }

        update newAccount;
    }
}