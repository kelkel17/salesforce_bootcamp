/**
 * @name ClinicianSchedule
 * @description DAO Class for ClinicianSchedule__c Object
 */
public with sharing class ClinicianScheduleDAO {
    public static List<ClinicianSchedule__c> getClinicianScheduleWithAppointmentDateTime(DateTime appointmentDateTime, DateTime nextDay) {
        return [
            SELECT Id, Schedule__c, ClinicianContact__c, Schedule__r.Schedule_Date_Time__c
            FROM ClinicianSchedule__c
            WHERE (
                Schedule__r.Schedule_Date_Time__c >= :appointmentDateTime AND
                Schedule__r.Schedule_Date_Time__c < :nextDay AND
                Schedule__r.Capacity__c > 0
            )
            ORDER BY Schedule__r.Schedule_Date_Time__c
        ];
    }
}