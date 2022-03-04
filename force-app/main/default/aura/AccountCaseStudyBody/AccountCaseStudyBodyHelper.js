({
    deleteRecord: function(component, event) {
        let isLoading = true;
        var accountRec = event.getParam('row');
        var action = component.get("c.deleteAccount");
        let message;

        if (accountRec.hasOwnProperty("Id")) {
            action.setParams({
                "account": accountRec
            });

            action.setCallback(this, response => {
                let state = response.getState();

                if (state === "SUCCESS") {
                    isLoading = false;
                    message = `You have successfully delete Account ${accountRec.Id} Record`;
                    this.removeFromTable(component, accountRec, message);
                } else {
                    isLoading = false;
                    let error = response.getError()[0].pageErrors[0];
                    this.showNotice(component, `${error.statusCode} ${error.message}`);
                }
            });
        } else {
            message = `You have successfully remove ${accountRec.Name} in Account record draft.`;
            this.removeFromTable(component, accountRec, message);
            this.callResetCounter(component, event);
        }

        $A.enqueueAction(action);

        return isLoading;
    },
    removeFromTable: function(component, accountRec, message) {
        var rows = component.get('v.accounts');
        var rowIndex = rows.indexOf(accountRec);
        rows.splice(rowIndex, 1);
        component.set('v.accounts', rows);
        this.showToast(component, message);
    },
    callResetCounter: function(component, event) {
        var mainComponent = component.get("v.parent");
        let counter = component.get("v.newRecordCounter");
        let newCounter = parseInt(counter) - 1;
		mainComponent.resetCounter(newCounter, false);
    },
    showToast : function(component, message) {
        component.find('deleteNotifyId').showToast({
            "variant": "Success",
            "title": "Success!",
            "message": message
        });
	},
    showNotice : function(component, message) {
		component.find('deleteNotifyId').showNotice({
            "variant": "error",
            "header": "Something has gone wrong!",
            "message": message
        });
	},
    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    handleSort: function(component, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        var accounts = component.get('v.accounts');
        var cloneData = accounts.slice(0);

        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));

        component.set('v.accounts', cloneData);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy);
    }
})