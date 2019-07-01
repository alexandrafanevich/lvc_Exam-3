/**
 * Created by aafanevich on 6/20/2019.
 */

public with sharing class ProductOrderPageController {
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public Integer amountFromPage { get; set; }
    public String productId;
    public Product_Table__c product = new Product_Table__c ();
    public Decimal totalOrderPrice {
        get {
            return (totalOrderPrice == 0) ? null : totalOrderPrice;
        }
        set;
    }

    public static Boolean validateEmail(String email) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern myPattern = Pattern.compile(emailRegex);
        Matcher myMatcher = myPattern.matcher(email);
        if (!myMatcher.matches()) {
            res = false;
        }
        return res;
    }

    public ProductOrderPageController() {
        productId = ApexPages.currentPage().getParameters().get('Id');
        product = [
                SELECT Id, Name, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
                WHERE Id = :productId
        ];
    }

    public Product_Table__c getProduct() {
        return product;
    }

    public PageReference refreshTotalOrderPrice() {
        String strAmount = ApexPages.currentPage().getParameters().get('myParam');
        if (String.isNotBlank(strAmount)) {
            amountFromPage = (Integer.valueOf(strAmount.trim()) == 0) ? 0 : Integer.valueOf(strAmount.trim());
        }else {
            amountFromPage = 0;
        }
        getTotalOrderPrice(amountFromPage);
        return null;
    }
    public Decimal getTotalOrderPrice(Integer amountFromPage) {
        if (amountFromPage > 0 && product.Unit_Price__c > 0) {
            totalOrderPrice = amountFromPage * product.Unit_Price__c;
        } else {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ProductOrderPage_Error_Units_count);
            ApexPages.addMessage(msg);
        }
        return totalOrderPrice;
    }

    public void buyButton() {
        Boolean isCorrect = String.isNotBlank(firstName) &&
                String.isNotBlank(lastName) &&
                validateEmail(email) &&
                amountFromPage > 0;

        if (isCorrect) {
            List<Contact> contList = [
                    SELECT Name, FirstName, LastName, Email
                    FROM Contact
                    WHERE Email = :email
                    LIMIT 1
            ];
            Contact cont = new Contact();
            if (!contList.isEmpty()) {
                cont = contList[0];
                cont.FirstName = firstName;
                cont.LastName = lastName;
            } else {
                cont.FirstName = firstName;
                cont.LastName = lastName;
                cont.Email = email;
            }
            Savepoint sp = Database.setSavepoint();
            upsert cont;

            Order_Table__c order = new Order_Table__c ();
            order.Product__c = product.Id;
            order.Units__c = amountFromPage;
            order.Order_Amount__c = amountFromPage * product.Unit_Price__c;
            order.Contact__c = cont.Id;
            insert order;


            if (order.Units__c <= product.Units_Available__c) {
                product.Units_Available__c -= order.Units__c;
                order = null;
                update product;
                String successMsg = Label.ProductOrderPage_Success_Buying + product.Name;
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, successMsg);
                ApexPages.addMessage(msg);
            } else {
                String errMsg = String.format(Label.ProductOrderPage_Error_Buying, new List<Object>{product.Units_Available__c});
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, errMsg);
                ApexPages.addMessage(msg);
                Database.rollback(sp);
            }

        } else {
            if (amountFromPage <= 0) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.ProductOrderPage_Error_Units_count);
                ApexPages.addMessage(msg);
            } else if (!validateEmail(email)) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.ProductOrderPage_Error_Email_Unavailable);
                ApexPages.addMessage(msg);
            } else if (String.isBlank(firstName)) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.ProductOrderPage_Error_FirstNme_IsNotFilled);
                ApexPages.addMessage(msg);
            } else if (String.isBlank(lastName)) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.ProductOrderPage_Error_LastNme_IsNotFilled);
                ApexPages.addMessage(msg);
            }
        }
    }
    public PageReference toShoppingButton() {
        PageReference pageRef = Page.ProductsListPage;
        pageRef.setRedirect(true);
        return pageRef;
    }
}