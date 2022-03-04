({
	fetchIndustry: function(component) {
        let flag = false;
		let action = component.get("c.findPicklistOptions");
		action.setParams({
            objAPIName: "Account",
			fieldAPIname: "Industry"
        });

		action.setCallback(this, $A.getCallback(function(response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                flag = true;
				component.set('v.industryOptions', response.getReturnValue());
            }
        }));

        $A.enqueueAction(action);

        return true;
	},
	fetchAccountType: function(component) {
        let flag = false;
		let action = component.get("c.findPicklistOptions");
		action.setParams({
            objAPIName: "Account",
			fieldAPIname: "Type"
        });

		action.setCallback(this, response => {
            let state = response.getState();

            if (state === "SUCCESS") {
                flag = true;
				component.set('v.typeOptions', response.getReturnValue());
            }
        });

        $A.enqueueAction(action);

        return true;
	}
})