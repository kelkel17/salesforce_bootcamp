({
    saveRecords: function(component, event) {
        let action = component.get("c.saveRecords");
        let accounts = component.get("v.accounts");
        let newRecordCounter = component.get("v.newRecordCounter");
        let newAccounts = [];
        let oldValue = [];

        for (let i of accounts) {
            if (!i.hasOwnProperty("Id")) {
                newAccounts.push(i);
            } else {
                oldValue.push(i);
            }
        }

        action.setParams({
            'accounts': newAccounts
        });

        action.setCallback(this, $A.getCallback(function(response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                let message = `You have successfully created ${newRecordCounter} record/s`;
                this.showSuccessToast(component, event, message);

                for (let i of response.getReturnValue()) {
                    oldValue.push(i);
                }

                component.set("v.accounts", oldValue);
                component.set("v.accountContainer", oldValue);
                component.set("v.newRecordCounter", 0)
            } else {
                let error = response.getError()[0].pageErrors[0];
                this.showNotice(component, JSON.stringify(error.statusCode), JSON.stringify(error.message));
            }
        }));

        $A.enqueueAction(action);
    },
    showSuccessToast: function(component, event, message) {
        let toast = component.find('saveAllRecordId').showToast({
            "variant": "Success",
            "title": "Success!",
            "message": message
        });
    },
    showNotice: function(component, header, message) {
		component.find('saveAllRecordId').showNotice({
            "variant": "error",
            "header": header,
            "message": message
        });
	}
})