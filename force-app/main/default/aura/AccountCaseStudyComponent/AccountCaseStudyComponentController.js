({
    onInit : function(component, event, helper) {
        helper.fetchAllAccount(component);
    },
	handleSearchEvent: function(component, event, helper) {
        var searchedValue = event.getParam("searchedValue").toLowerCase();
        let accounts = component.get("v.accounts");
        let accountContainer = component.get("v.accountContainer");
        let tempArray = [];

        for (let i of accounts) {
            tempArray.push(i);
        }

        if (searchedValue.length <= 0) {
            component.set("v.accounts", accountContainer);
        } else {
            component.set("v.accounts", helper.search(tempArray, searchedValue));
        }
    },
    handleCreateAccountEvent: function(component, event, helper) {
        let arrayOfAccounts = [];
        let flag = event.getParam("didCreateAccount");
        let numEventsHandled = parseInt(component.get("v.newRecordCounter")) + 1;
        let accounts = component.get("v.accounts");

        let newAccount = {
            'Name': event.getParam("Name"),
            'Phone': event.getParam("Phone"),
            'Type': event.getParam("Type"),
            'Industry': event.getParam("Industry")
        };

        if (flag) {
            helper.showSuccessToast(component, event);

            for (let i of accounts) {
                arrayOfAccounts.push(i);
            }

            arrayOfAccounts.push(newAccount);

            component.set("v.accounts", arrayOfAccounts);
            component.set("v.accountContainer", arrayOfAccounts);
            component.set("v.newRecordCounter", numEventsHandled);
        }
    },
    resetCounter: function(component, event, helper) {
        var params = event.getParam('arguments');

        if (params) {
            component.set("v.newRecordCounter", params.reset);

            if (params.refresh) {
                helper.fetchAllAccount(component);
            }
        }
    },
})