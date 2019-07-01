/**
 * Created by aafanevich on 6/14/2019.
 */

public with sharing class Task26AccountCreationController {

    public Task26AccountCreationController() {
        formingAttachment();
        isDisplaying = false;
        isSectionDisplaying = false;
        isFileExist = true;
    }
//    public Task26AccountCreationController(PageReference accPage) {
//        if (accPage.getParameters().get('accId') != null) {
//            isDisplaying = !isDisplaying;
//        }
//    }
    public String serverTimeOnPage { get; set; }
    public Boolean isDisplaying { get; set; }
    public Boolean isSectionDisplaying { get; set; }
    public Boolean isFileExist { get; set; }
    public List<Attachment> attachmentList { get; set; }
    public transient Attachment attach { get; set; }
    public PageReference accPage {
        get {
            if (accPage.getParameters().get('accId') != null) {
                isDisplaying = !isDisplaying;
            }
            return accPage;
        }
        set;
    }
    Account account;
    public String newPageTitleValue = Label.Create_new_Account;
    public String newAttachBlockTitle = Label.Attaching_Block_title;
    public String getNewPageTitleValue() {
        return newPageTitleValue;
    }
    public String getNewAttachBlockTitle() {
        return newAttachBlockTitle;
    }
    public Account getAccount() {
        if (account == null) {
            account = new Account();
        }
        return account;
    }
    public List<Attachment> getAttachments() {
        if (attachmentList == null) {
            attachmentList = new List<Attachment>();
        }
        return attachmentList;
    }
    public PageReference addAttachments() {
        attachmentList.add(new Attachment());
        return null;
    }
    public PageReference removeAttachments() {
        if (attachmentList.size() > 1) {
            attachmentList.remove(attachmentList.size() - 1);
        }
        return null;
    }
    private void formingAttachment() {
        attach = new Attachment();
        attachmentList = new List<Attachment>();
        attachmentList.add(attach);
    }
    public PageReference createAccount() {
        insert account;
//        PageReference accPage = new ApexPages.StandardController(account).view();
        accPage = ApexPages.currentPage();
        accPage.getParameters().put('accId', account.Id);
        createNewTypeTitleAfterSave();
        return accPage;
    }
    public PageReference cancelButton() {
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference createNewTypeTitle() {
        String paramFromVF = ApexPages.currentPage().getParameters().get('newParam');
        newPageTitleValue = String.format(Label.newPageTitleValue, new List<String>{String.valueOf(paramFromVF)});
        return null;
    }

    public void createNewTypeTitleAfterSave() {
        String serverDateTime = Datetime.now().format(Label.serverDateTime);
        String userDateTime = System.now().format(Label.userDateTimeFormat);
        newPageTitleValue = String.format(Label.newNewPageTitle, new List<String>{String.valueOf(account.Type), String.valueOf(serverDateTime), String.valueOf(UserInfo.getName()), String.valueOf(userDateTime)});
    }
    public void getServerTime() {
        serverTimeOnPage = Datetime.now().format(Label.serverDateTime);
    }
    public void toggleView() {
        isSectionDisplaying = !isSectionDisplaying;
    }

    public String createNewAttachBlockTitle() {
        String attachmentName = '';
        for (Attachment att : attachmentList) {
            attachmentName += ' ' + att.Name;
        }
        newAttachBlockTitle = String.format(Label.newAttachBlockTitle, new List<String>{String.valueOf(account.Name), String.valueOf(attachmentName)});
        return newAttachBlockTitle;
    }
    public PageReference saveAttachments() {
        if (account != null) {
            List<Attachment> attList = new List<Attachment>();
            for (Attachment att : attachmentList) {
                if (att.Name != null && att.Body != null) {
                    attList.add(new Attachment(ParentId = account.Id, Name = att.Name, Body = att.Body)) ;
                }
            }
            if (attList != null) {
                upsert attList;
                String msgSuccessUpload = String.format(Label.Message_File_Upload_Success, new List<String>{String.valueOf(attList.size())});
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msgSuccessUpload));
                attList.clear();
                createNewAttachBlockTitle();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Message_Error_Upload));
            }
        }
        return null;
    }

}