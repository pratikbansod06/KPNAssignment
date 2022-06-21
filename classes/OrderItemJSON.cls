public class OrderItemJSON {

	@AuraEnabled public String accountNumber;	//
	@AuraEnabled public String orderNumber;	//
	@AuraEnabled public String type;	//order type
	@AuraEnabled public String status;	//order status
	@AuraEnabled public OrderProductsCls[] orderProducts;
	public class OrderProductsCls {
		@AuraEnabled public String name;	//product name
		@AuraEnabled public String code;	//product code
		@AuraEnabled public Decimal unitPrice;	//10
		@AuraEnabled public Decimal quantity;	//1
        
        public OrderProductsCls(orderItem itemRec)
        {
            this.name=itemRec.Product2.Name;	//product name
            this.code=itemRec.Product2.productcode;	//product code
            this.unitPrice=itemRec.UnitPrice;	//10
            this.quantity=itemRec.Quantity;	//1
        }
	}
	public static OrderItemJSON parse(String json){
		return (OrderItemJSON) System.JSON.deserialize(json, OrderItemJSON.class);
	}
    
	public OrderItemJSON(Order orderRec)
    {
        this.accountNumber=orderRec.Account.Name;
        this.orderNumber=orderRec.OrderNumber;	//
		this.type=orderRec.Type;	//order type
		this.status=orderRec.Status;	//order status
        
        //for(orderItem itemRec:orderRec.OrderItems)
        {
        orderProducts=new OrderProductsCls[0];
            //i++;
        }
    }

}