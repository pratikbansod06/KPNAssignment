public class ProductsController {
    public static Map<String,String> orderItemMap= new Map<String,String>();
    //To get the products from the pricebook of the order. This gets displayed in the Available Products section
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProducts(String recordId) {
        
        List<order> pbList= [SELECT Pricebook2Id from order WHERE id=:recordId LIMIT 1];
        List<OrderItem> opList=[SELECT id,Product2Id,Product2.name FROM OrderItem where OrderId=:recordId];
        Set<Id> productsPresentSet=new Set<Id>();
        
        List<PricebookEntry> pList=new List<PricebookEntry>();
        if(opList.size()>0)
        {
            for(OrderItem itemRec:opList)
            {
                //orderItemMap.put(itemRec.Product2.name,itemRec.id);
                productsPresentSet.add(itemRec.Product2Id);
            }
            List<PricebookEntry> pbList1= [SELECT Name, UnitPrice, Id ,Product2Id,ProductCode,Pricebook2Id
                                           FROM PricebookEntry 
                                           where Pricebook2Id=:pbList[0].Pricebook2Id AND Product2Id 
                                           IN :productsPresentSet];
            List<PricebookEntry> pbList2= [SELECT Name, UnitPrice, Id ,Product2Id,ProductCode,Pricebook2Id
                                           FROM PricebookEntry 
                                           where Pricebook2Id=:pbList[0].Pricebook2Id AND Product2Id
                                           NOT IN :productsPresentSet];
            
            pList.addall(pbList1);
            pList.addall(pbList2);
            return pList;
        }
        
        return [SELECT Name, UnitPrice, Id 
                FROM PricebookEntry 
                where Pricebook2Id=:pbList[0].Pricebook2Id];
    }
    // Method to update the quantity of the order items to +1
    @AuraEnabled
    public static void updateOrders(List<PricebookEntry> con,String recId){
        List<OrderItem> itemList= new List<OrderItem>();
        List<OrderItem> itemUpdateList= new List<OrderItem>();
        Set<String> orderItemSet= new set<String>();
        if(con.size()>0)
        {
            for(PricebookEntry pbRec:con)
            {
                orderItemSet.add(pbRec.Name);
            }}
        List<OrderItem> opList=[SELECT id,Product2Id,Product2.name,Quantity FROM OrderItem where OrderId=:recId and Product2.name IN:orderItemSet ];
        if(opList.size()>0)
        {
            for(OrderItem itemRec:opList)
            {
                orderItemMap.put(itemRec.Product2.name,itemRec.id);
            }}
        System.debug('+++'+con);
        
        for(PricebookEntry pbRec:con)
        {
            if(orderItemMap.containsKey(pbRec.Name))
            {
                orderItemSet.add(orderItemMap.get(pbRec.Name));
            }
            else if(!orderItemMap.containsKey(pbRec.Name))//Create new orderitem with quantity 1 if the item is not present in order
            {
                OrderItem itemRec= new OrderItem();
                itemRec.Product2Id=pbRec.Product2Id;
                //itemRec.ProductCode=pbRec.ProductCode;
                itemRec.Quantity=1;
                itemRec.UnitPrice=pbRec.UnitPrice;
                itemRec.OrderId=recId;
                itemRec.PricebookEntryId=pbRec.Id;
                itemList.add(itemRec);
            }
        }
        for(OrderItem oiRec:opList)//Update the existing item quantity +1
        {
            
            OrderItem itemRec= new OrderItem();
            itemRec.Product2Id=oiRec.Product2Id;
            itemRec.Quantity=oiRec.Quantity+1;
            itemRec.id=oiRec.Id;
            itemUpdateList.add(itemRec);
            
        }
        update itemUpdateList;
        insert itemList;
        return;
    }
}