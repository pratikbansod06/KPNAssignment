import { LightningElement,track,api, wire} from 'lwc';
import getProducts from '@salesforce/apex/ProductsController.getProducts';
import { refreshApex } from '@salesforce/apex';
import getOrderProducts from '@salesforce/apex/OrderProductsController.getOrderProducts';
import updateOrders from '@salesforce/apex/ProductsController.updateOrders';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
export default class AvailableProductsComponent extends LightningElement {
@track columns = [
          { label: 'Name', fieldName: 'Name' },
          { label: 'UnitPrice', fieldName: 'UnitPrice',type: 'currency',
               typeAttributes: { currencyCode: 'USD' },}
      ];
     @track productList;
     @track orderItemList;
     @api recordId;
     @api selected;
     @api select1;
     //Method 2
     @wire (getProducts,{ recordId: '$recordId'}) wiredProducts({data,error}){
          if (data) {
               this.productList = data;
          console.log(data); 
          } else if (error) {
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
               
               //this.selected=true;
               //refreshComponent(this.test);
                 
          console.log(data); 
          } else if (error) {
          console.log(error);
          }
          //eval("$A.get('e.force:refreshView').fire();");
          //return refreshApex(this.getOrderProducts);
     }


     handleclick(event){
        
        var el = this.template.querySelector('lightning-datatable');
        console.log(el);
        //this.select1
        //this.selected=this.orderItemList;
        this.select1 = el.getSelectedRows();
        //this.selected=false;
        console.log(this.selected);
       
        updateOrders({
             con :JSON.stringify(this.select1) , 
             recId : this.recordId
             }).then(() => {
      refreshApex(this.wiredActivities);
      console.log('avhere'+JSON.stringify(this.wiredActivities));
      console.log('avhere1'+JSON.stringify(this.selected));
  });
         
        console.log(this.selected);
        const passEvent = new CustomEvent("productselection", {
            detail: this.selected 
        });
       this.dispatchEvent(passEvent);
       
    }
    
}