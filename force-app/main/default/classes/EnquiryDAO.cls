/**
 * @name EnquiryDAO
 * @description DAO Class for Enquiry Object
 */
public with sharing class EnquiryDAO {
    public static Enquiry__c getEnquiryRecordById(Set<Id> enquirySetId) {
        return [
            SELECT Id, Enquired_Service__c, Gender_Preference__c, Language__c, Medium__c, Participant__c
            FROM Enquiry__c
            WHERE Id IN :enquirySetId
        ];
    }
}
