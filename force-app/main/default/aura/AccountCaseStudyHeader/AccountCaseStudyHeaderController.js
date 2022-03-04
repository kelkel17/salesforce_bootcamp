({
	handleKeyUp: function (component, event, helper) {
        var isEnterKey = event.keyCode === 13;

        let queryTerm = component.find('enter-search').get('v.value');
        let searchEvent = component.getEvent("searchEvent");

        searchEvent.setParams({ "searchedValue" : queryTerm });
        searchEvent.fire()
    },
    showModal: function(component, event, helper) {
        let isAlreadySet = component.get('v.isAlreadySet');
        let modalToggle = component.get('v.showModal');
        let button = event.getSource();
        button.set('v.disabled', true);

        if (!isAlreadySet) {
            let industry = helper.fetchIndustry(component);
            let type = helper.fetchAccountType(component);

            if (industry && type) {
                button.set('v.disabled', false);
                component.set('v.showModal', true);
                component.set('v.isAlreadySet', true);
            }
        } else {
            button.set('v.disabled', false);
            component.set('v.showModal', true);
        }
    }
})