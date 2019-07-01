/**
 * Created by aafanevich on 6/18/2019.
 */
@IsTest
public class Task26AccountCreationControllerTest {

    @IsTest
    private static void createAccount() {
        Account acc = new Account (
                Name = 'Test Acc',
                Type = 'Prospect'
        );

        Test.startTest();
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        accContr.getAccount().put('Name', String.valueOf(acc.Name));
        accContr.getAccount().put('Type', String.valueOf(acc.Type));
        accContr.createAccount();
        Test.stopTest();

        List<Account> listAccounts = [
                SELECT Name, Type
                FROM Account
        ];
        System.assertEquals(1, listAccounts.size());
    }

    @IsTest
    private static void saveAttachments() {
        Account acc = new Account (
                Name = 'Test Acc',
                Type = 'Prospect'
        );
        insert acc;
        List<Attachment> listAttachments = new List<Attachment>();
        Attachment attachment = new Attachment (
                Name = 'Test Attach',
                ParentId = acc.Id,
                Body = Blob.valueOf('Test Acc Body')
        );
        listAttachments.add(attachment);

        Test.startTest();
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        accContr.getAccount().put('Id', String.valueOf(acc.Id));
        accContr.getAccount().put('Name', String.valueOf(acc.Name));
        accContr.getAccount().put('Type', String.valueOf(acc.Type));
        accContr.getAttachments().addAll(listAttachments);
        accContr.saveAttachments();
        Test.stopTest();

        List<Attachment> newListAttachments = [
                SELECT Name, ParentId, Body
                FROM Attachment
                WHERE ParentId = :acc.Id
        ];

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertNotEquals(0, msgList.size());
        System.assertEquals(listAttachments.size(), newListAttachments.size());
    }

    @IsTest
    private static void failedSaveAttachments() {
        Account acc = new Account (
                Name = 'TestAcc'
        );
        insert acc;
        List<Attachment> listAttachments = new List<Attachment>();
        Attachment attachment = new Attachment (
                Name = null,
                ParentId = acc.Id,
                Body = null
        );
        listAttachments.add(attachment);

        Test.startTest();
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        accContr.getAccount().put('Name', String.valueOf(acc.Name));
        accContr.getAttachments().addAll(listAttachments);
        accContr.saveAttachments();
        Test.stopTest();

        List<Attachment> newListAttachments = [
                SELECT Name, ParentId, Body
                FROM Attachment
                WHERE ParentId = :acc.Id
        ];
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertNotEquals(0, msgList.size());
        System.assertEquals(0, newListAttachments.size());
    }

    @IsTest
    private static void addAttachments() {
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        Integer expectedSizeAttachments = accContr.attachmentList.size() + 1;

        Test.startTest();
        accContr.addAttachments();
        Test.stopTest();

        Integer actualSizeAttachments = accContr.attachmentList.size();
        System.assertEquals(expectedSizeAttachments, actualSizeAttachments);
    }

    @IsTest
    private static void removeAttachments() {
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        accContr.addAttachments();
        Integer expectedSizeAttachments = accContr.attachmentList.size() - 1;

        Test.startTest();
        accContr.removeAttachments();
        Test.stopTest();

        Integer actualSizeAttachments = accContr.attachmentList.size();
        System.assertEquals(expectedSizeAttachments, actualSizeAttachments);
    }

    @IsTest
    private static void testCancelButton() {
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        String currentPage = pageRef.getUrl();
        String nextPage = accContr.cancelButton().getUrl();

        System.assertEquals(currentPage, nextPage);
    }

    @IsTest
    private static void toggleView() {
        Boolean isShowExpected = true;

        Test.startTest();
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        accContr.toggleView();
        Test.stopTest();

        Boolean isShowActual = accContr.isSectionDisplaying;
        System.assertEquals(isShowExpected, isShowActual);
    }

    @IsTest
    private static void changeTypeTitleAfterSave() {
        Account acc = new Account (
                Name = 'Test Acc',
                Type = 'Prospect'
        );
        insert acc;
        String expectedTitle = String.format(Label.newPageTitleValue, new List<String> {String.valueOf(acc.Type)});

        Test.startTest();
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        accContr.getAccount().put('Name', String.valueOf(acc.Name));
        accContr.getAccount().put('Type', String.valueOf(acc.Type));
        ApexPages.currentPage().getParameters().put('newParam', String.valueOf(acc.Type));
        accContr.createNewTypeTitle();
        Test.stopTest();

        String actualTitle = accContr.newPageTitleValue;
        System.assertEquals(expectedTitle, actualTitle);
    }

    @IsTest
    private static void showServerTimeTest() {
        Datetime serverTime = Datetime.now();
        String expectedServerTime = serverTime.format(Label.serverDateTime);

        Test.startTest();
        Task26AccountCreationController accContr = new Task26AccountCreationController();
        accContr.getServerTime();
        Test.stopTest();

        String actualServerTime = accContr.serverTime;
        System.assertEquals(expectedServerTime, actualServerTime);
    }

}