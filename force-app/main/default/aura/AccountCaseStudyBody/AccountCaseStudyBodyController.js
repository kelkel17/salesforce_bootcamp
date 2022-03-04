({
	onInit: function(component, event, helper) {
		component.set("v.columns",  [
            {label: 'Account Name', fieldName: 'Name', type: 'text', sortable: true},
            {label: 'Phone', fieldName: 'Phone', type: 'phone', sortable: true},
            {label: 'Industry', fieldName: 'Industry', type: 'text', sortable: true},
            {label: 'Type', fieldName: 'Type', type: 'text', sortable: true},
            {
                label: 'Action',
                type: "button",
                typeAttributes: {
                    label: 'Delete',
                    iconName: 'action:delete',
                    title: 'Delete',
                    variant: 'destructive',
                    alternativeText: 'Delete'
                }
            },
        ]);
	},
    handleRowAction: function (component, event, helper) {
        let action = event.getParam('action');

        switch (action.title) {
            case 'Delete':
                helper.deleteRecord(component, event);
                break;
        }
    },
    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    }
})