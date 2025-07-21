public class BusOccupation implements Database.Batchable<Id> {

    private List<Id> busIds;

    public BusOccupation(List<Id> busIds) {
        this.busIds = busIds;
    }

    public Iterable<Id> start(Database.BatchableContext bc) {
        return busIds;
    }

    public void execute(Database.BatchableContext bc, List<Id> scopeBusIds) {
        Map<Id, Integer> passengerCountMap = new Map<Id, Integer>();

        AggregateResult[] passengerCounts = [
            SELECT Bus__c busId, COUNT(Id) cnt
            FROM Passenger__c
            WHERE Bus__c IN :scopeBusIds
            GROUP BY Bus__c
        ];

        for (AggregateResult ar : passengerCounts) {
            passengerCountMap.put((Id)ar.get('busId'), (Integer)ar.get('cnt'));
        }

        List<Bus__c> busesToUpdate = new List<Bus__c>();

        for (Id busId : scopeBusIds) {
            Integer count = passengerCountMap.containsKey(busId) ? passengerCountMap.get(busId) : 0;
            Bus__c busToUpdate = new Bus__c(Id = busId);

            if (count < 10) {
                busToUpdate.Bus_Status__c = 'Available';
            } else if (count < 20) {
                busToUpdate.Bus_Status__c = 'Limited Seats';
            } else if (count == 20) {
                busToUpdate.Bus_Status__c = 'Full';
            } else if (count > 20) {
                throw new BusOccupationException('Bus Id ' + busId + ' has more than 20 passengers (' + count + ').');
            }
            busesToUpdate.add(busToUpdate);
        }

        if (!busesToUpdate.isEmpty()) {
            update busesToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('BusOccupation batch finished.');
    }

    public class BusOccupationException extends Exception {}
}
