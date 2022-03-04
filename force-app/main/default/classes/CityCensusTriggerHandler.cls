public class CityCensusTriggerHandler {
    public static void createHandler() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert || Trigger.isUpdate) {
        		CityCensusTriggerHelper.beforeInsertUpdate(Trigger.New);
            }
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                CityCensusTriggerHelper.afterInsertUpdate(Trigger.New);
            }
        }
    }
}