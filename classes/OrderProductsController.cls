public class OrderProductsController {
    //Method to Get the current orderitems in the OrderProducts component
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(String recordId) {
        
        List<OrderItem> opList=[SELECT id,Product2Id,Product2.Name,UnitPrice,Quantity,TotalPrice 
                                FROM OrderItem where OrderId=:recordId];
        return opList;
    }
    //Method to activate the order if clicked on activated
    @AuraEnabled
    public static void activateOrderProducts(String recordId) { 
        Order opRec=[SELECT id,Status FROM Order where Id=:recordId LIMIT 1];
        opRec.Status='Activated';
        update opRec;
        createJSONData(recordId);
        return;
    }
    //Method to check if the order is already active on page load
    @AuraEnabled(cacheable=true)
    public static Boolean checkOrder(String recordId) { 
        List<Order> opList=[SELECT id,Status FROM Order where Id=:recordId AND Status='Activated' LIMIT 1];
        if(opList.size()>0){
            return true;
        }
        else
        {
            return false;
        }
        
    }

    //Method to check if the orderLine is already Present on load
    @AuraEnabled(cacheable=true)
    public static Boolean checkOrderLine(String recordId) { 
        List<OrderItem> opList=[SELECT id FROM OrderItem where OrderId=:recordId];
        if(opList.size()>0){
            return true;
        }
        else
        {
            return false;
        }
        
    }

    //Method to send response to external system
    @future(callout=true)
    public static void createJSONData(String recordId)
    {
        try{
            //Select Account & Contact Records
            Order orderRec = [SELECT Id, Account.Name,orderNumber,type,status, (SELECT Product2.Name,UnitPrice,Quantity,Product2.productcode FROM OrderItems) FROM Order WHERE Id =: recordId];
             
            //Create a parent record
            OrderItemJSON par = new OrderItemJSON(orderRec);
             
            //Loop on Contacts
            for(OrderItem con: orderRec.OrderItems) {
                par.orderProducts.add(new OrderItemJSON.OrderProductsCls(con));
            }
             
            //Get the Json data
            String jsonData = JSON.serialize(par);
            System.debug('JsonData-' + jsonData);
        	HttpRequest req = new HttpRequest();
            req.setEndpoint('https://Myexample.requestcatcher.com');
             
              req.setMethod('POST');
              req.setHeader('Accept-Encoding', 'gzip,deflate');
              req.setHeader('content-type', 'text/xml; charset=utf-8');
              req.setHeader('Content-Length', String.valueOf(jsonData.length()));
             
            
              // setting body
              System.debug('Input Request:' + jsonData);
              req.setBody(jsonData);
            
              //Execute web service call here     
              Http http = new Http();
              HTTPResponse res = http.send(req);
            
              //Helpful debug messages
              System.debug(res.toString());
              
        	 if(res.getStatusCode()==200) {
                    String success = 'Success HTTP Code = '+res.getStatusCode()+
                                '. Message: '+res.getStatus()+'. Response Body: '+res.getBody();
                    System.debug('##### Success: '+success);
                    
        		}
        	else
            {
                String error = 'Request failed error.HTTP Code = '+res.getStatusCode()+
                                '. Message: '+res.getStatus()+'. Response Body: '+res.getBody();
                    System.debug('##### Failed: '+error);
                    
            }}catch(Exception msg){
                System.debug('Message'+msg);
            }
    }
}