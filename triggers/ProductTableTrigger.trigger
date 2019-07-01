/**
 * Created by aafanevich on 6/12/2019.
 */

trigger ProductTableTrigger on Product_Table__c (before insert, before update, before delete, after insert,
        after update, after delete, after undelete) {

    AssignWarehouseToProductTableHandler handler = new AssignWarehouseToProductTableHandler();

    if ((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) {
        if (!System.isFuture())
            handler.onBeforeInsertUpdate(Trigger.new);
    }

}