/**
 * @name EnquiriesDAO
 * @description DAO Class for Enquiry__c Object
 */
public with sharing class EnquiriesDAO {
    public static Enquiry__c getEnquiryRecordById(Set<Id> enquirySetId) {
        return [
            SELECT
            	Id,
            	Medium__c,
            	Language__c,
            	Gender_Preference__c,
            	Appointment_Date_Time__c,
            	Participant__r.Gender__c,
            	Participant__r.Age__c,
            	Participant__r.Building_Unit__c,
            	Participant__r.Street__c,
            	Participant__r.Suburb_Town__c,
            	Participant__r.State__c,
            	Participant__r.Postal_Code__c,
            	Enquired_Service__r.Name
            FROM Enquiry__c
            WHERE Id IN :enquirySetId
        ];
    }
}