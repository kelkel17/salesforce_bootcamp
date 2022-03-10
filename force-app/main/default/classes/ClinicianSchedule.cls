/**
 * @name ClinicianSchedule
 * @description DAO Class for ClinicianSchedule__c Object
 */
public with sharing class ClinicianSchedule {
    public static ClinicianSchedule__c getClinicianSchedule(Id clinicianId) {
        return [
            SELECT Id, Schedule__r.Schedule_Date_Time__c, Schedule__r.Capacity__c
            FROM ClinicianSchedule__c
            WHERE (
                ClinicianContact__r.Id = :clinicianId AND
                Schedule__r.Capacity__c > 0
            )
        ];
    }
}