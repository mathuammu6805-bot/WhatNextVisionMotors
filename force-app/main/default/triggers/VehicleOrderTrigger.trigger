trigger VehicleOrderTrigger on Vehicle_Order__c (before insert) {

    VehicleOrderTriggerHandler.validateStock(Trigger.new);

}