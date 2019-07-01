/**
 * Created by aafanevich on 6/12/2019.
 */

public with sharing class AssignWarehouseToProductTableHandler {

    private static final Org_Configuration__c ORG_CONFIGURATION = Org_Configuration__c.getInstance();

    public void onBeforeInsertUpdate(List<Product_Table__c> triggerNewList) {
        List<Date> prodsAddDateList = new List<Date>();
        for (Product_Table__c prod : triggerNewList) {
            if (prod.Added_Date__c != null) {
                prodsAddDateList.add(prod.Added_Date__c);
            } else {
                prod.Added_Date__c = Date.today();
                prodsAddDateList.add(prod.Added_Date__c);
            }
        }
        List<Date> prodsAddDateSortList = new List<Date>(prodsAddDateList);
        prodsAddDateSortList.sort();
        Integer periodTerm;
        if (ORG_CONFIGURATION != null && ORG_CONFIGURATION.Period_Term__c != null) {
            periodTerm = ORG_CONFIGURATION.Period_Term__c.intValue();
        }
        List<Warehouse__c> whList = new List<Warehouse__c>([
                SELECT Id, Name, Period_Start__c, Period_End__c
                FROM Warehouse__c
                WHERE Period_Start__c <= :prodsAddDateSortList[prodsAddDateSortList.size() - 1]
                AND Period_End__c >= :prodsAddDateSortList[0]
                ORDER BY Period_Start__c
        ]);
        List<Warehouse__c> whNewList = new List<Warehouse__c>();
        Map<Product_Table__c, Warehouse__c> prTableToWarehouseMap = new Map<Product_Table__c, Warehouse__c>();
        for (Product_Table__c prTable : triggerNewList) {
            if (String.isBlank(prTable.Warehouse__c)) {
                if (!whList.isEmpty()) {
                    Integer i = 1;
                    for (Warehouse__c wh : whList) {
                        if (prTable.Added_Date__c >= wh.Period_Start__c &&
                                prTable.Added_Date__c <= wh.Period_End__c) {
                            prTable.Warehouse__c = wh.Id;
                            break;
                        } else if (i == whList.size()) {
                            Warehouse__c newWh = createNewWarehouse(prTable, periodTerm);
                            whNewList.add(newWh);
                            prTableToWarehouseMap.put(prTable, newWh);
                            break;
                        } else {
                            i++;
                        }
                    }
                } else {
                    Warehouse__c newWh = createNewWarehouse(prTable, periodTerm);
                    whNewList.add(newWh);
                    prTableToWarehouseMap.put(prTable, newWh);
                }
            }
        }
        if (!whNewList.isEmpty()) {
            insert whNewList;
            for (Product_Table__c prTable : triggerNewList) {
                if (String.isBlank(prTable.Warehouse__c)) {
                    prTable.Warehouse__c = prTableToWarehouseMap.get(prTable).Id;
                }
            }
        }
    }

    public Warehouse__c createNewWarehouse(Product_Table__c prTable, Integer periodTerm) {
        Warehouse__c newWh = new Warehouse__c();
        newWh.Name = 'Warehouse ' + String.valueOf(prTable.Added_Date__c) + ' - ' + String.valueOf(prTable.Added_Date__c + periodTerm); //String.format here
        newWh.Period_Start__c = prTable.Added_Date__c;
        newWh.Period_End__c = prTable.Added_Date__c + periodTerm;
        return newWh;
    }

}