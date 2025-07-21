@isTest
public class BusOccupation_Test {

    @isTest
    static void busOccupationBatchTest() {
        List<Bus__c> buses = new List<Bus__c>();
        for (Integer i = 0; i < 200; i++) {
            buses.add(new Bus__c(Name = 'Bus ' + i));
        }
        insert buses;

        List<Passenger__c> passengers = new List<Passenger__c>();

        for (Integer i = 0; i < 9; i++) {
            passengers.add(new Passenger__c(Name = 'Passanger ' + i, Bus__c = buses[1].Id));
        }

        for (Integer i = 0; i < 15; i++) {
            passengers.add(new Passenger__c(Name = 'Passanger ' + i, Bus__c = buses[2].Id));
        }

        for (Integer i = 0; i < 20; i++) {
            passengers.add(new Passenger__c(Name = 'Passanger' + i, Bus__c = buses[3].Id));
        }

        insert passengers;

        Test.startTest();
        BusOccupation batch = new BusOccupation(new List<Id>{
            buses[0].Id, buses[1].Id, buses[2].Id, buses[3].Id
        });
        Database.executeBatch(batch, 200);
        Test.stopTest();

        Map<Id, Bus__c> updatedBuses = new Map<Id, Bus__c>([
            SELECT Id, Bus_Status__c FROM Bus__c WHERE Id IN :buses
        ]);

        Assert.areEqual('Available', updatedBuses.get(buses[0].Id).Bus_Status__c, 'Bus 0 should be Available');
        Assert.areEqual('Available', updatedBuses.get(buses[1].Id).Bus_Status__c, 'Bus 1 should be Available');
        Assert.areEqual('Limited Seats', updatedBuses.get(buses[2].Id).Bus_Status__c, 'Bus 2 should be Limited Seats');
        Assert.areEqual('Full', updatedBuses.get(buses[3].Id).Bus_Status__c, 'Bus 3 should be Full');
    }
}
