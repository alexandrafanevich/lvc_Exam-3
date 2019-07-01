/**
 * Created by aafanevich on 6/13/2019.
 */
@IsTest
private class AssignWarehouseToProductTableHandlerTest {

    @TestSetup
    static void setupData(){
        Integer periodTerm = 30;
        Org_Configuration__c orgConfiguration = new Org_Configuration__c(
                Period_Term__c = periodTerm
        );
        insert orgConfiguration;

        Warehouse__c warehouseJune = new Warehouse__c(
                Name = 'June 2019 WH',
                Period_Start__c = Date.newInstance(2019, 06, 01),
                Period_End__c = Date.newInstance(2019, 06, 30)
        );
        insert warehouseJune;
        Warehouse__c warehouseAugust = new Warehouse__c(
                Name = 'August 2019 WH',
                Period_Start__c = Date.newInstance(2019, 08, 01),
                Period_End__c = Date.newInstance(2019, 08, 31)
        );
        insert warehouseAugust;
    }

    @IsTest
    static void insertProdAndAssignToWH() {

        Warehouse__c warehouseMay = new Warehouse__c(
                Name = 'May 2019 WH',
                Period_Start__c = Date.newInstance(2019, 05, 01),
                Period_End__c = Date.newInstance(2019, 05, 31)
        );
        Product_Table__c prodExistWH = new Product_Table__c(
                Name = 'prod May Exist WH',
                Warehouse__c = warehouseMay.Id,
                Added_Date__c = Date.newInstance(2019, 05, 11)
        );
        try {
            insert warehouseMay;
            insert prodExistWH;
            List<Product_Table__c> prodTableList = [SELECT Id, Warehouse__c FROM Product_Table__c];
            List<Warehouse__c> whNewList = [SELECT Id FROM Warehouse__c WHERE Id = :warehouseMay.Id];
            System.assertEquals(warehouseMay.Id, prodTableList[0].Warehouse__c);
            System.assertEquals(1, whNewList.size());
        }
        catch(DmlException de) {
            System.assert(false, de);
        }
    }

    @IsTest
    static void createNewProdAndNewWH() {

        List<Product_Table__c> prodList = new List<Product_Table__c>();
        Product_Table__c prodJuly = new Product_Table__c(
                Name = 'prod July 2019',
                Added_Date__c = Date.newInstance(2019, 07, 19)
        );
        prodList.add(prodJuly);

        Product_Table__c prodForSecondExistWH = new Product_Table__c(
                Name = 'Test prodForSecondExistWH',
                Added_Date__c = Date.newInstance(2019, 08, 11)
        );
        prodList.add(prodForSecondExistWH);

        Product_Table__c prodToday = new Product_Table__c(
                Name = 'Test prod Today'
        );
        prodList.add(prodToday);


        Product_Table__c prodNotExistWH = new Product_Table__c(
                Name = 'Test prodNotExistWH',
                Added_Date__c = Date.newInstance(2019, 06, 11)
        );
        prodList.add(prodNotExistWH);


        try {
            insert prodList;
            List<Product_Table__c> prodTableList = [SELECT Id FROM Product_Table__c];
            List<Warehouse__c> whNewList = [SELECT Id FROM Warehouse__c];
            System.assertEquals(4, prodTableList.size());
            System.assertEquals(3, whNewList.size());
        }
        catch(DmlException de) {
            System.assert(false, de);
        }
    }

    @IsTest
    static void createNewProdOutOfBoundsOfExistWH() {

        Product_Table__c prodSeptember = new Product_Table__c(
                Name = 'prod September 2019',
                Added_Date__c = Date.newInstance(2019, 09, 11)
        );


        try {
            insert prodSeptember;
            List<Product_Table__c> prodList = [SELECT Id FROM Product_Table__c];
            List<Warehouse__c> whList = [
                SELECT Id, Period_Start__c FROM Warehouse__c
                WHERE Period_Start__c <= :prodSeptember.Added_Date__c
                AND Period_End__c >= :prodSeptember.Added_Date__c
            ];
            System.assertEquals(1, prodList.size());
            System.assertEquals(1, whList.size());
            System.assertEquals(prodSeptember.Added_Date__c, whList[0].Period_Start__c);
        }
        catch(DmlException de) {
            System.assert(false, de);
        }
    }

    @IsTest
    static void insertProdInExistAndAssignedWH() {

        Date startDate = Date.newInstance(2019, 08, 01);
        Date endDate = Date.newInstance(2019, 08, 31);
        Warehouse__c whTest = [
                SELECT Id
                FROM Warehouse__c
                WHERE Period_Start__c >= :startDate
                AND Period_End__c <= :endDate
                LIMIT 1
        ];
        Product_Table__c prodTest = new Product_Table__c(
                Name = 'prod Test August 2019',
                Warehouse__c = whTest.Id,
                Added_Date__c = Date.newInstance(2019, 08, 21)
        );

        try {
            insert prodTest;
            List<Product_Table__c> prodList = [SELECT Id FROM Product_Table__c];
            System.assertEquals(1, prodList.size());
            System.assertEquals(prodTest.Warehouse__c, whTest.Id);
        }
        catch(DmlException de) {
            System.assert(false, de);
        }
    }

}