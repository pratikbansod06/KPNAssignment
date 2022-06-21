import { LightningElement, track, api,wire } from 'lwc';
import getOrderProducts from '@salesforce/apex/OrderProductsController.getOrderProducts';
import activateOrder from '@salesforce/apex/OrderProductsController.activateOrderProducts';
import checkOrder from '@salesforce/apex/OrderProductsController.checkOrder';
import checkOrderLine from '@salesforce/apex/OrderProductsController.checkOrderLine';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class OrderProductsComponent extends LightningElement {
  @api recordId;
  @api isNotActivated;
  @track selected=[];
  @api isOrderProductPresent;
  @track columns = [
          { label: 'Name', fieldName: 'ProductName' , wrapText: true },
          { label: 'UnitPrice', fieldName: 'UnitPrice',type: 'currency',
               typeAttributes: { currencyCode: 'USD' }},
          { label: 'Quantity', fieldName: 'Quantity', alternativeText: 1},
          { label: 'TotalPrice', fieldName: 'TotalPrice',type: 'currency',
               typeAttributes: { currencyCode: 'USD' }},
      ];
  @track productList;
  @wire (checkOrder,{ recordId: '$recordId'}) checkOrder({data,error}){
          if (data) {
               this.isNotActivated=true;

          console.log(data); 
          } else if (error) {
          console.log(error);
          }
     }

     @wire (checkOrderLine,{ recordId: '$recordId'}) checkOrderLine({data,error}){
          if (data) {
               this.isOrderProductPresent=true;

          console.log(data); 
          } else  {
               this.isOrderProductPresent=false;
          console.log(error);
          }
     }

      @wire (getOrderProducts,{ recordId: '$recordId'}) wired1Products(result){
          this.wiredActivities = result;
          const { data, error } = result;
          if (data) {
                let d = [];
                data.forEach(element => {
                let elt = {};
                elt.ProductName = element.Product2.Name;
                elt.UnitPrice = element.UnitPrice ;
                elt.Quantity =  element.Quantity ;
                elt.TotalPrice =  element.TotalPrice ;
                d.push(elt);
            });
            
               this.selected = d;    
          console.log(data); 
          } else if (error) {
          console.log(error);
          }
          //eval("$A.get('e.force:refreshView').fire();");
          //return refreshApex(this.getOrderProducts);
     }

     
    

  hanldeProgressValueChange(event) {
    this.selected = event.detail;
    console.log(this.selected);
    this.isOrderProductPresent=true;
    console.log('here'+JSON.stringify(this.selected));
    refreshApex(this.checkOrderLine);
     //refreshApex(this.getOrderProducts);
    eval("$A.get('e.force:refreshView').fire();");
  }
     handleclick()
     {
          activateOrder({recordId : this.recordId});
          
          this.isNotActivated=true;
          if(this.isNotActivated)
          {
                    eval("$A.get('e.force:refreshView').fire();");
                    const evt = new ShowToastEvent({
                         title: 'Order Activated',
                         message: 'Order is Activated and Response sent',
                         variant: 'success',
                    });
                    this.dispatchEvent(evt);
          }
     }
     
  
}