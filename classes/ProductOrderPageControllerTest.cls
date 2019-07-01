/**
 * Created by aafanevich on 7/1/2019.
 */
@IsTest
private with sharing class ProductOrderPageControllerTest {
    @TestSetup
    private static void testSetup() {
        Integer periodTerm = 30;
        Org_Configuration__c orgConfiguration = new Org_Configuration__c(
                Period_Term__c = periodTerm
        );
        insert orgConfiguration;
        Product_Table__c prod1 = new Product_Table__c(
                Name = 'Test prod 1',
                Product_Description__c = 'Description',
                Unit_Price__c = 85.20,
                Units_Available__c = 300,
                Added_Date__c = Date.today()
        );
        insert prod1;
        Contact cont1 = new Contact(
                FirstName = 'First Name Contact 1',
                LastName = 'Last Name Contact 1',
                Email = 'test@mail.com'
        );
        insert cont1;
    }
    @IsTest
    private static void assignToExistContact() {
        Contact contact = [SELECT LastName, FirstName, Email FROM Contact];
        Product_Table__c product = [SELECT Id, Name, Unit_Price__c, Added_Date__c, Units_Available__c FROM Product_Table__c];

        Test.startTest();
        PageReference pageRef = Page.ProductOrderPage;
        pageRef.getParameters().put('Id', String.valueOf(product.Id));
        Test.setCurrentPage(pageRef);
        ProductOrderPageController prPageContr = new ProductOrderPageController();
        prPageContr.firstName = contact.FirstName;
        prPageContr.lastName = contact.LastName;
        prPageContr.email = contact.Email;
        prPageContr.amountFromPage = Integer.valueOf(product.Units_Available__c);
        prPageContr.buyButton();
        Test.stopTest();

        Contact newCont = [SELECT LastName, Email FROM Contact WHERE Email = :contact.Email];
        System.assertEquals (newCont.LastName, contact.LastName);
    }
    @IsTest
    private static void cancelOrder() {
        Contact contact = [SELECT LastName, FirstName, Email FROM Contact];
        Product_Table__c product = [SELECT Id, Name, Unit_Price__c, Added_Date__c, Units_Available__c FROM Product_Table__c];

        Test.startTest();
        PageReference pageRef = Page.ProductOrderPage;
        pageRef.getParameters().put('Id', String.valueOf(product.Id));
        Test.setCurrentPage(pageRef);
        ProductOrderPageController prPageContr = new ProductOrderPageController();
        prPageContr.firstName = contact.FirstName;
        prPageContr.lastName = contact.LastName;
        prPageContr.email = contact.Email;
        prPageContr.amountFromPage = Integer.valueOf(product.Units_Available__c) + 7;
        prPageContr.buyButton();
        Test.stopTest();

        List<Order_Table__c> orderList = [SELECT Id FROM Order_Table__c];

        System.assertEquals (0, orderList.size());
    }
    @IsTest
    private static void assignToNewContact() {
        Contact contact = [SELECT LastName, FirstName, Email FROM Contact];
        Product_Table__c product = [SELECT Id, Name, Unit_Price__c, Added_Date__c, Units_Available__c FROM Product_Table__c];

        Test.startTest();
        Integer amount = 10;
        PageReference pageRef = Page.ProductOrderPage;
        pageRef.getParameters().put('Id', String.valueOf(product.Id));
        pageRef.getParameters().put('myParam', String.valueOf(amount));
        Test.setCurrentPage(pageRef);
        ProductOrderPageController prPageContr = new ProductOrderPageController();
        prPageContr.firstName = contact.FirstName;
        prPageContr.lastName = contact.LastName;
        prPageContr.email = 'email@mail.com';
        prPageContr.amountFromPage = amount;
        prPageContr.refreshTotalOrderPrice();
        prPageContr.buyButton();
        Test.stopTest();

        Contact newCont = [SELECT LastName, Email FROM Contact WHERE Email = 'email@mail.com'];
        System.assertEquals (newCont.Email, 'email@mail.com');
    }
    @IsTest
    private static void incorrectEmail() {
        Contact contact = [SELECT LastName, FirstName FROM Contact];
        Product_Table__c product = [SELECT Id, Name, Unit_Price__c, Added_Date__c, Units_Available__c FROM Product_Table__c];

        Test.startTest();
        PageReference pageRef = Page.ProductOrderPage;
        pageRef.getParameters().put('Id', String.valueOf(product.Id));
        Test.setCurrentPage(pageRef);
        ProductOrderPageController prPageContr = new ProductOrderPageController();
        prPageContr.firstName = contact.FirstName;
        prPageContr.lastName = contact.LastName;
        prPageContr.email = 'emailmail';
        prPageContr.amountFromPage = Integer.valueOf(product.Units_Available__c);
        prPageContr.buyButton();
        Test.stopTest();

        List<Apexpages.Message> msgsList = ApexPages.getMessages();
        System.assertNotEquals(0, msgsList.size());
    }
    @IsTest
    private static void incorrectFirstName() {
        Contact contact = [SELECT LastName, FirstName, Email FROM Contact];
        Product_Table__c product = [SELECT Id, Name, Unit_Price__c, Added_Date__c, Units_Available__c FROM Product_Table__c];

        Test.startTest();
        PageReference pageRef = Page.ProductOrderPage;
        pageRef.getParameters().put('Id', String.valueOf(product.Id));
        Test.setCurrentPage(pageRef);
        ProductOrderPageController prPageContr = new ProductOrderPageController();
        prPageContr.lastName = contact.LastName;
        prPageContr.email = contact.Email;
        prPageContr.amountFromPage = Integer.valueOf(product.Units_Available__c);
        prPageContr.buyButton();
        Test.stopTest();

        List<Apexpages.Message> msgsList = ApexPages.getMessages();
        System.assertNotEquals(0, msgsList.size());
    }
    @IsTest
    private static void incorrectLastName() {
        Contact contact = [SELECT LastName, FirstName, Email FROM Contact];
        Product_Table__c product = [SELECT Id, Name, Unit_Price__c, Added_Date__c, Units_Available__c FROM Product_Table__c];

        Test.startTest();
        PageReference pageRef = Page.ProductOrderPage;
        pageRef.getParameters().put('Id', String.valueOf(product.Id));
        Test.setCurrentPage(pageRef);
        ProductOrderPageController prPageContr = new ProductOrderPageController();
        prPageContr.firstName = contact.FirstName;
        prPageContr.email = contact.Email;
        prPageContr.amountFromPage = Integer.valueOf(product.Units_Available__c);
        prPageContr.buyButton();
        Test.stopTest();

        List<Apexpages.Message> msgsList = ApexPages.getMessages();
        System.assertNotEquals(0, msgsList.size());
    }
    @IsTest
    private static void incorrectAmount() {
        Contact contact = [SELECT LastName, FirstName, Email FROM Contact];
        Product_Table__c product = [SELECT Id, Name, Unit_Price__c, Added_Date__c, Units_Available__c FROM Product_Table__c];

        Test.startTest();
        PageReference pageRef = Page.ProductOrderPage;
        pageRef.getParameters().put('Id', String.valueOf(product.Id));
        Test.setCurrentPage(pageRef);
        ProductOrderPageController prPageContr = new ProductOrderPageController();
        prPageContr.lastName = contact.LastName;
        prPageContr.firstName = contact.FirstName;
        prPageContr.email = contact.Email;
        prPageContr.amountFromPage = 0;
        prPageContr.buyButton();
        prPageContr.toShoppingButton();
        Test.stopTest();

        List<Apexpages.Message> msgsList = ApexPages.getMessages();
        System.assertNotEquals(0, msgsList.size());
    }
}