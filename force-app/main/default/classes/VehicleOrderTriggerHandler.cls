public class VehicleOrderTriggerHandler {

    public static void validateStock(List<Vehicle_Order__c> orders) {

        Set<Id> vehicleIds = new Set<Id>();

        for (Vehicle_Order__c order : orders) {
            if (order.Vehicle__c != null) {
                vehicleIds.add(order.Vehicle__c);
            }
        }

        if (vehicleIds.isEmpty()) {
            return;
        }

        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>(
            [SELECT Id, Stock_Quantity__c
             FROM Vehicle__c
             WHERE Id IN :vehicleIds]
        );

        for (Vehicle_Order__c order : orders) {

            if (order.Vehicle__c == null) {
                continue;
            }

            Vehicle__c vehicle = vehicles.get(order.Vehicle__c);

            if (vehicle != null &&
                (vehicle.Stock_Quantity__c == null ||
                 vehicle.Stock_Quantity__c <= 0)) {

                order.addError(
                    'This vehicle is out of stock. The order cannot be created.'
                );
            }
        }
    }
}