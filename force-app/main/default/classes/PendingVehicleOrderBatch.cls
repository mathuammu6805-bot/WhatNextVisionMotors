global class PendingVehicleOrderBatch
    implements Database.Batchable<SObject> {

    global Database.QueryLocator start(
        Database.BatchableContext bc
    ) {
        return Database.getQueryLocator([
            SELECT Id, Status__c, Vehicle__c
            FROM Vehicle_Order__c
            WHERE Status__c = 'Pending'
            AND Vehicle__c != null
        ]);
    }

    global void execute(
        Database.BatchableContext bc,
        List<Vehicle_Order__c> orders
    ) {

        Set<Id> vehicleIds = new Set<Id>();

        for (Vehicle_Order__c order : orders) {
            vehicleIds.add(order.Vehicle__c);
        }

        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>(
            [
                SELECT Id, Stock_Quantity__c
                FROM Vehicle__c
                WHERE Id IN :vehicleIds
            ]
        );

        List<Vehicle_Order__c> ordersToUpdate =
            new List<Vehicle_Order__c>();

        Set<Id> vehiclesAlreadyUsed = new Set<Id>();

        for (Vehicle_Order__c order : orders) {

            Vehicle__c vehicle = vehicles.get(order.Vehicle__c);

            if (vehicle != null &&
                vehicle.Stock_Quantity__c != null &&
                vehicle.Stock_Quantity__c > 0 &&
                !vehiclesAlreadyUsed.contains(vehicle.Id)) {

                order.Status__c = 'Confirmed';

                ordersToUpdate.add(order);

                vehiclesAlreadyUsed.add(vehicle.Id);
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }

    global void finish(
        Database.BatchableContext bc
    ) {
        System.debug('Pending vehicle order batch completed.');
    }
}