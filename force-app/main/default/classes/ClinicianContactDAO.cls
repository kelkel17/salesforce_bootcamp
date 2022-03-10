/**
 * @name ClinicianContactDAO
 * @description DAO Class for ClinicianContact__c Object
 */
public with sharing class ClinicianContactDAO {
    public static List<ClinicianContact__c> getClinicianContactRecordWithServiceAndLocation(List<String> state) {
        return [
            SELECT 
            	Id,
            	Case_Load_Perference__c,
            	Language__c,
            	Gender__c,
            	Point__c
            FROM ClinicianContact__c
            WHERE (
                Job_Title__c IN :state AND
            	Office__r.State__c IN :state AND
            	Office__r.Postal_Code__c IN :state
            )
        ];
    }
    
    public static ClinicianContact__c getClinicianContactRecordWithService(String service) {
        return [
            SELECT 
            	Id
            FROM ClinicianContact__c
            WHERE Job_Title__c = :service
        ];
    }
}