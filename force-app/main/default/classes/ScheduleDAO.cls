/**
 * @name ScheduleDAO
 * @description DAO Class for Schedule__c Object
 */
public with sharing class ScheduleDAO {
    public static List<Schedule__c> getScheduleWithAppointmentDateTime(DateTime appointmentDateTime, DateTime nextDay) {
        return [
            SELECT Id, Schedule_Date_Time__c, Capacity__c
            FROM Schedule__c
            WHERE (
                Schedule_Date_Time__c >= :appointmentDateTime AND
                Schedule_Date_Time__c <= :nextDay AND
                Capacity__c > 0
            )
        ];
    }
}