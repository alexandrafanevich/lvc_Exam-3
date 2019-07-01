/**
 * Created by aafanevich on 6/20/2019.
 */

public with sharing class ProductsSinglePageController {

    public Id productId;
    public ProductsSinglePageController() {
        productId = ApexPages.currentPage().getParameters().get('Id');
    }
    public Product_Table__c product {
        get {
            if (product == null) {
                product = [
                        SELECT Id, Name, Image_Url__c, Unit_Price__c, Product_Description__c, Units_Available__c
                        FROM Product_Table__c
                        WHERE Id = :productId
                ];
            }
            return product;
        }
        set;
    }

}