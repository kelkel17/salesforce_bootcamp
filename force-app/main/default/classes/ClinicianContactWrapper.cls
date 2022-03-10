/**
 * Reference: 
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_list_sorting_sobject.htm#CustomSortSection
 */
global class ClinicianContactWrapper implements Comparable {
	public ClinicianContact__c clinicianContact;

    // Constructor
    public ClinicianContactWrapper(ClinicianContact__c cc) {
        clinicianContact = cc;
    }

    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to ClinicianContactWrapper
        ClinicianContactWrapper compareToClinicianContact = (ClinicianContactWrapper)compareTo;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (clinicianContact.Point__c < compareToClinicianContact.clinicianContact.Point__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (clinicianContact.Point__c > compareToClinicianContact.clinicianContact.Point__c) {
            // Set return value to a negative value.
            returnValue = -1;
        } else if ((clinicianContact.Point__c == null) && (compareToClinicianContact.clinicianContact.Point__c != null)) {
            // nulls-first implementation
            returnValue = -1;
        } else if ((clinicianContact.Point__c != null) && (compareToClinicianContact.clinicianContact.Point__c == null)) {
            // nulls-first implementation
            returnValue = 1;
        }

        return returnValue;
    }
}