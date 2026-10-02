global class PendingVehicleOrderScheduler
    implements Schedulable {

    global void execute(SchedulableContext sc) {

        Database.executeBatch(
            new PendingVehicleOrderBatch(),
            50
        );
    }
}