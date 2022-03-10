public with sharing class ClinicianContactController {
    public static final String HOME_BASED = 'Home Based';
    public static final String IN_CLINIC = 'In-Clinic';
    public static final String TELEHEALTH = 'Telehealth';

    /**
     * @name getClinicianContactList
     * @param Id enquiryId
     * @description gets the most suited clinician
     * @return list of ClinicianContact
     **/
    @AuraEnabled(cacheable=false)
    public static List<ClinicianContactWrapper> getClinicianContactList(Id enquiryId) {
        Set<Id> enquirySetId = new Set<Id>{ enquiryId };
        List<String> parameters = new List<String>();
        List<ClinicianContact__c> clinicianList = new List<ClinicianContact__c>();
        List<ClinicianContactWrapper> clinicianWrapperList = new List<ClinicianContactWrapper>();

        try {
            // Get the Enquiry Record
            Enquiry__c enquiry = EnquiriesDAO.getEnquiryRecordById(enquirySetId);
            parameters = setParameters(enquiry);

            // Get Clinician Record
            clinicianList = ClinicianContactDAO.getClinicianContactRecordWithServiceAndLocation(parameters);

            // Match Enquiry with Clinician
            clinicianWrapperList = matchClinicianWithEnquiry(enquiry, clinicianList);

        } catch (System.QueryException e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        } catch (System.DmlException e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

    	return clinicianWrapperList;
    }

    /**
     * @name setParameters
     * @param Enquiry__c enquiry
     * @description add the parameters needed for query to a list
     * @return list of string
     **/
    private static List<String> setParameters(Enquiry__c enquiry) {
        List<String> parameters = new List<String>();

        parameters.add(enquiry.Enquired_Service__r.Name);
        parameters.add(enquiry.Participant__r.Street__c);
        parameters.add(enquiry.Participant__r.Suburb_Town__c);
        parameters.add(enquiry.Participant__r.State__c);
        parameters.add(enquiry.Participant__r.Postal_Code__c);

        return parameters;
    }

    /**
     * @name matchClinicianWithEnquiry
     * @param Enquiry__c enquiry
     * @param List<ClinicianContact__c> clinician
     * @description check if parameters matches the Enquiry and Clinician
     * @return list of clinician sorted by most suitable (point system)
     **/
    private static List<ClinicianContactWrapper> matchClinicianWithEnquiry(
        Enquiry__c enquiry,
        List<ClinicianContact__c> clinicianList
    ) {
        List<ClinicianContactWrapper> clinicianListWrapper = new List<ClinicianContactWrapper>();
        Map<Id, ClinicianSchedule__c> clinicianlistOfSchedules = clinicialWithEarliestAvailability(enquiry);
        ClinicianSchedule__c earliestClinicianAvailable = clinicianlistOfSchedules.values()[0];

        for (ClinicianContact__c clinician : clinicianList) {
            Integer points = 0;

            // Force the clinician with earliest availability as most suited
            if (earliestClinicianAvailable != NULL && earliestClinicianAvailable.ClinicianContact__c == clinician.Id) {
                points += 10;
            }

            // Parameters 6 and 12
            if (
                String.isEmpty(clinician.Case_Load_Perference__c) ||
                String.isBlank(clinician.Case_Load_Perference__c)
            ) {
                points += 0;
            } else {
                points += isBelongToCaseLoadPreference(clinician.Case_Load_Perference__c, enquiry) ? 1 : 0;
            }

            // Parameter 7
            if (
                String.isEmpty(clinician.Language__c) ||
                String.isBlank(clinician.Language__c)
            ) {
                points += 0;
            } else {
                points += checkIfClinicianWillUnderstandParticipant(clinician.Language__c, enquiry) ? 1 : 0;
            }

            // Parameters 8 and 9
            if (
                String.isEmpty(enquiry.Gender_Preference__c) ||
                String.isBlank(enquiry.Gender_Preference__c)
            ) {
                points += 0;
            } else {
                points += isBelongToParticipantGenderPrefence(enquiry.Gender_Preference__c, clinician) ? 1 : 0;
            }

            clinician.Point__c = points;
            clinicianListWrapper.add(new ClinicianContactWrapper(clinician));
        }

        // Sort from highest to lowest points
        // Highest points = Most suited Clinician
        clinicianListWrapper.sort();

        return clinicianListWrapper;
    }

    /**
     * @name clinicialWithEarliestAvailability
     * @param Enquiry__c enquiry
     * @description get the list of clinicians based on the participant's appointment date
     * @return Map<Id, ClinicianSchedule__c> order by clinician's earliest availability
     **/
    private static Map<Id, ClinicianSchedule__c> clinicialWithEarliestAvailability(Enquiry__c enquiry) {
        DateTime nextDay = enquiry.Appointment_Date_Time__c.addDays(1);
        List<ClinicianSchedule__c> listOfSchedules = ClinicianScheduleDAO.getClinicianScheduleWithAppointmentDateTime(enquiry.Appointment_Date_Time__c, nextDay);
        Map<Id, ClinicianSchedule__c> clinicianScheduleMap = new Map<Id, ClinicianSchedule__c>();

        for (ClinicianSchedule__c tempRec : listOfSchedules) {
            if (!clinicianScheduleMap.containsKey(tempRec.ClinicianContact__c)) {
                clinicianScheduleMap.put(tempRec.ClinicianContact__c, tempRec);
            }
        }

        return clinicianScheduleMap;
    }

    /**
     * @name isBelongToCaseLoadPreference
     * @param String preference
     * @param Enquiry__c enquiry
     * @description check Participant's age belongs to Clinician's case load preference
     * @return flag
     **/
    private static Boolean isBelongToCaseLoadPreference(String preference, Enquiry__c enquiry) {
        List<String> agePreferenceGroup = preference.contains(';') ? preference.split(';') : preference.split('-');
        Integer minAge;
        Integer maxAge;
        Boolean flag;

        if (preference.contains(';')) {
            for (Integer i = 0; i < agePreferenceGroup.size(); i++) {
                // Set the first number of first age group as minimum age
                minAge = Integer.valueOf(agePreferenceGroup[0].split('-')[0]);

                // Check if the last age group is inlcuded
                if (agePreferenceGroup[agePreferenceGroup.size() - 1].contains('and above')) {
                    maxAge = 100;
                } else {
                    // Set the last number of last age group as maximum age
                    List<String> lastGroup = agePreferenceGroup[agePreferenceGroup.size() - 1].split('-');
                    maxAge = Integer.valueOf(lastGroup[lastGroup.size() - 1]);
                }
            }
        } else {
            minAge = Integer.valueOf(agePreferenceGroup[0]);
            maxAge = Integer.valueOf(agePreferenceGroup[agePreferenceGroup.size() - 1]);
        }

        // Check Participant's age if it belongs to the clinician's case load preference
        flag = enquiry.Participant__r.Age__c >= minAge && enquiry.Participant__r.Age__c <= maxAge ?
            true :
        	false;

        return flag;
    }

    /**
     * @name checkIfClinicianWillUnderstandParticipant
     * @param String languages
     * @param Enquiry__c enquiry
     * @description check if Participant's language exist in Clinician's languages
     * @return flag
     **/
    private static Boolean checkIfClinicianWillUnderstandParticipant(String languages, Enquiry__c enquiry) {
        List<String> clinicianLanguages = new List<String>();
        Boolean flag;

        if (languages.contains(';')) {
            clinicianLanguages = languages.split(';');
        } else {
            clinicianLanguages.add(languages);
        }

        flag = clinicianLanguages.contains(enquiry.Language__c) ? true : false;

        return flag;
    }

    /**
     * @name isBelongToParticipantGenderPrefence
     * @param String genderPreference
     * @param ClinicianContact__c clinician
     * @description check if Clinician's gender fits the Participant's gender preference
     * @return flag
     **/
    private static Boolean isBelongToParticipantGenderPrefence(String genderPreference, ClinicianContact__c clinician) {
        List<String> participantGenderPreference = new List<String>();
        Boolean flag;

        if (genderPreference.contains(';')) {
            participantGenderPreference = genderPreference.split(';');
        } else {
            participantGenderPreference.add('genderPreference');
        }

        flag = participantGenderPreference.contains(clinician.Gender__c);

        return flag;
    }
}