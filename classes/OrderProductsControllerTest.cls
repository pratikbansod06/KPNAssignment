@isTest
public class OrderProductsControllerTest {


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
    
    @isTest static void getOrderProductsTest() {
        Test.startTest();
        Order ordRec=[SELECT Id from Order LIMIT 1];
        List<OrderItem> itemList=OrderProductsController.getOrderProducts(ordRec.id); 
        system.assertEquals(1, itemList.size()); 
        Test.stopTest();
          
    }
    @isTest static void activateOrderProductsTest() {
        Test.startTest();
        Order ordRec=[SELECT Id from Order LIMIT 1];
        OrderProductsController.activateOrderProducts(ordRec.id);
        Order ordRec1=[SELECT Id,Status from Order LIMIT 1];
        system.assertEquals('Activated', ordRec1.Status); 
        Test.stopTest();
        
    }
	@isTest static void checkOrderTest() {
        Test.startTest();
        Order ordRec=[SELECT Id from Order LIMIT 1];
        Boolean isActive=OrderProductsController.checkOrder(ordRec.id); 
        system.assertEquals(false, isActive); 
        Test.stopTest();
          
    }

}