@isTest
public class ProductsControllerTest {

    @testSetup static void setup() {

    // Insert Account

    Account a = new Account();
    a.Name = 'Test Account';
    insert a;

    // Insert Product
    Product2 p = new Product2();
    p.Name = ' Test Product ';
    p.Description='Test Product Entry 1';
    p.productCode = 'ABC';
    p.isActive = true;
    insert p;
    

    Id pricebookId = Test.getStandardPricebookId();
    
    // Insert PricebookEntry

    PricebookEntry standardPrice = new PricebookEntry();
    standardPrice.Pricebook2Id = pricebookId;
    standardPrice.Product2Id = p.Id;
    standardPrice.UnitPrice = 1;
    standardPrice.IsActive = true;
    standardPrice.UseStandardPrice = false;
    insert standardPrice ;
    
    // Insert Order
    
    Order o = new Order();
    o.Name = 'Test Order ';
    o.Status = 'Draft';
    o.EffectiveDate = system.today();
    o.EndDate = system.today() + 4;
    o.AccountId = a.id;
    o.Pricebook2Id =  pricebookId ;
    
    insert o;
    
    // Insert Order Item

    OrderItem i = new OrderItem();
    i.OrderId = o.id;
    i.Quantity = 24;
    i.UnitPrice = 240;
    i.Product2id = p.id;
    i.PricebookEntryId=standardPrice.id;
    insert i;

        
    } 
    
    @isTest static void getProductsTest() {
        Test.startTest();
        Order ordRec=[SELECT Id from Order LIMIT 1];
        List<PricebookEntry> pbList=ProductsController.getProducts(ordRec.id); 
        system.assertEquals(1, pbList.size()); 
        Test.stopTest();
          
    }
    @isTest static void updateOrdersTest() {
        Test.startTest();
        Order ordRec=[SELECT Id from Order LIMIT 1];
        List<PricebookEntry> pbRecList=[SELECT Id,name from PricebookEntry LIMIT 1];
        ProductsController.updateOrders(pbRecList,ordRec.id);
        OrderItem ordItemRec=[SELECT Id,Quantity from Orderitem LIMIT 1];
        system.assertEquals(25, ordItemRec.Quantity); 
        Test.stopTest();
        
    }

}