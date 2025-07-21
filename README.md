# Salesforce Bus Occupation Management

This repository contains a Salesforce implementation that manages bus occupancy using custom objects and Apex batch processing.

---

## Contents

- **Custom Objects**
  - `Bus__c`: Represents a bus.
  - `Passenger__c`: Represents passengers linked to a bus.
- **Apex Classes**
  - `BusOccupation`: Batch Apex class to update bus statuses based on passenger counts.
  - `BusOccupationException`: Custom exception class used by the batch.
- **Test Classes**
  - `BusOccupation_Test`: Unit tests for the batch processing logic.

---

## Object Details

### Bus__c

| Field Name      | Type       | Description                      |
|-----------------|------------|--------------------------------|
| `Name`          | Text       | Bus identifier                  |
| `Bus_Status__c` | Picklist   | Status of the bus occupancy: Available, Limited Seats, Full |

### Passenger__c

| Field Name | Type   | Description                 |
|------------|--------|-----------------------------|
| `Name`     | Text   | Passenger identifier        |
| `Bus__c`   | Lookup | Lookup to related Bus record |

---

## Apex Classes

### BusOccupation

- Implements `Database.Batchable<Id>`
- Accepts list of bus Ids to process
- Queries passenger counts per bus and updates `Bus_Status__c` accordingly:
  - Less than 10 passengers: `Available`
  - Between 10 and 19: `Limited Seats`
  - Exactly 20: `Full`
  - More than 20: Throws `BusOccupationException` (after processing other valid buses)

### BusOccupationException

- Custom exception to report over-capacity buses.

---

## Running the Batch

Invoke the batch with the list of bus record IDs:

```apex
List<Id> busIds = [SELECT Id FROM Bus__c WHERE ...].Id;
BusOccupation batch = new BusOccupation(busIds);
Database.executeBatch(batch, 10); 
