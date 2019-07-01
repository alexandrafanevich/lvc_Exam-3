/**
 * Created by aafanevich on 6/20/2019.
 */

public with sharing class ProductsListPageController {
    public Id productId { get; set; }
    public List<Product_Table__c> productList { get; set; }
    public Product_Table__c product { get; set; }

    public ProductsListPageController() {
        productList = [
                SELECT Id, Name, Image_Url__c, Unit_Price__c, Product_Description__c
                FROM Product_Table__c
                WHERE Image_Url__c != NULL
                AND Unit_Price__c != NULL
                AND Name != NULL
                LIMIT 50000
        ];
        productId = ApexPages.currentPage().getParameters().get('Id');

    }
    public PageReference detailPageReference() {
        PageReference detailPage = Page.ProductsSinglePage;
        detailPage.setRedirect(true);
        detailPage.getParameters().put('Id', productId);
        return detailPage;
    }
    public PageReference orderPageReference() {
        PageReference orderPage = Page.ProductOrderPage;
        orderPage.setRedirect(true);
        orderPage.getParameters().put('Id', productId);
        return orderPage;
    }
    public PageReference toShoppingButton() {
        PageReference pageRef = Page.ProductsListPage;
        pageRef.setRedirect(true);
        return pageRef;
    }
    public Product_Table__c getProductDetail() {
        product = [
                SELECT Id, Name, Image_Url__c, Unit_Price__c, Product_Description__c, Units_Available__c
                FROM Product_Table__c
                WHERE Id = :productId
        ];
        return product;
    }
}