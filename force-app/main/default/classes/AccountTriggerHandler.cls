public class AccountTriggerHandler {
    public static void createHandler() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
            	AccountTriggerHelper.beforeInsertAccount(Trigger.New);
            } else if (Trigger.isUpdate) {
                AccountTriggerHelper.checkNumberOfCases(Trigger.New);
            }
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
            	AccountTriggerHelper.createContact(Trigger.New);
            } else if (Trigger.isUpdate) {
            	AccountTriggerHelper.updateContact(Trigger.New);
            }
        }
    }
}