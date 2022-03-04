({
    saveAllRecords: function(component, event, helper) {
        helper.saveRecords(component);
    },
    refreshTable: function(component, event, helper) {
        let mainComponent = component.get("v.parent");
        mainComponent.resetCounter(0, true);
    },
    handleValueChange: function(component, event, helper) {
        if (event.getParam("value") > 0) {
            component.set("v.isDisabled", false);
        } else {
            component.set("v.isDisabled", true);
        }
    },
})