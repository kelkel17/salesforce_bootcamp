({
    fetchAllAccount: function(component) {
		let action = component.get("c.fetchAllAccount");

		action.setCallback(this, $A.getCallback(response => {
            let state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.accounts", response.getReturnValue());
                component.set("v.accountContainer", response.getReturnValue());
            }
        }));

        $A.enqueueAction(action);
    },
    showSuccessToast: function(component, event) {
        let toast = component.find('notifyId').showToast({
            "variant": "Success",
            "title": "Success!",
            "message": "You have added an Account record in draft"
        });
    },
    search: function(arrayOfAllObjects, searchText) {
        return arrayOfAllObjects.filter(object => {
            return JSON.stringify(object)
            .toString()
            .toLowerCase()
            .includes(searchText);
        });
    }
})