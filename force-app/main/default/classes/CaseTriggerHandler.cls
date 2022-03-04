public class CaseTriggerHandler {
    public static void createHandler() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                CaseTriggerHelper.beforeInsert(Trigger.New);
            }
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                CaseTriggerHelper.updateAccountFieldsRelatedToCase(Trigger.New, false);
            }

            if (Trigger.isDelete) {
                CaseTriggerHelper.updateAccountFieldsRelatedToCase(Trigger.New, true);
            }
        }
    }
}