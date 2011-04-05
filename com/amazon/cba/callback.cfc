<!--- PLEASE VIEW THE CALLBACK API GUIDE FOR ADDITIONAL INSTRUCTIONS/CONSIDERATIONS/EXTENSIONS --->
<cfcomponent hint="Callback helper methods. This is a special instance of the cart object." extends="com.amazon.factory" output="false">

	<cffunction name="init" hint="Initialize an empty cart" returntype="void">
		<cfargument name="accessKeyID" type="string" required="true" hint="Your Checkout by Amazon Access Key ID"/>
		<cfargument name="secretKeyID" type="string" required="true" hint="Your Checkout by Amazon Secret Access Key"/>
		<cfargument name="merchantID" type="string" required="true" hint="Your Merchant ID"/>
		<cfargument name="sandbox" type="boolean" required="false" hint="True if using the sandbox environment." default="false"/>
		<cfscript>
			//Initialize the parent object
			super.init(arguments.accessKeyID,arguments.secretKeyID,arguments.merchantID,arguments.sandbox);
		</cfscript>
	</cffunction>
	
	<cffunction name="parseRequest" access="public" output="false" returntype="void" hint="Parse the request into a managable object. This method creates an struct attribute called REQUEST. This object extracts several keys commonly used in processing a callback.">
		<cfargument name="orderCalculationRequest" type="string" required="false" hint="The text to parse. If none is provided, the method looks for an attribute called order-calculation-request in the FORM scope."/>
		<cfscript>
			var i 		= 0;
			var items 	= ArrayNew(1);
			var tmp 	= "";			
	
			//Check for the request in the FORM scope if none is defined in the arguments.
			if(not StructKeyExists(arguments,"orderCalculationRequest"))
				arguments.orderCalculationRequest = form['order-calculation-request'];
				
			//Parse the request
			this.request = StructNew();
			this.request.xml = XmlParse(arguments.orderCalculationRequest).XmlRoot;
	
			//Populate some commonly used request data into helper attributes
			this.request.address = StructNew();
			this.request.address.id = this.request.xml.CallbackOrders.CallbackOrder.Address.AddressId.XmlText;
			this.request.address.field1 = this.request.xml.CallbackOrders.CallbackOrder.Address.AddressFieldOne.XmlText;
			this.request.address.field2 = this.request.xml.CallbackOrders.CallbackOrder.Address.AddressFieldTwo.XmlText;
			this.request.address.city = this.request.xml.CallbackOrders.CallbackOrder.Address.City.XmlText;
			this.request.address.state = this.request.xml.CallbackOrders.CallbackOrder.Address.State.XmlText;
			this.request.address.zip = this.request.xml.CallbackOrders.CallbackOrder.Address.PostalCode.XmlText;
			this.request.address.country = this.request.xml.CallbackOrders.CallbackOrder.Address.CountryCode.XmlText;
			
			this.request.referenceId = this.request.xml.CallbackReferenceId.XmlText;
			
			//Add each item with a SKU to the item request array
			items = this.request.xml.CallbackOrderCart.CallbackOrderCartItems.XmlChildren;
			this.request.items = StructNew();
			for(i=1;i lte arraylen(items);i=i+1){
				tmp = StructNew();
				tmp.id = items[i].CallbackOrderItemId.XmlText;
				StructInsert(this.request.items,items[i].Item.SKU.XmlText,tmp);
			}
	
			//Identify what is accessible in the callback
			this.enabled = "";
			if(trim(lcase(this.request.xml.OrderCalculationCallbacks.CalculateTaxRates.XmlText)) is "true")
				this.enabled = listappend(this.enabled,"TAX");
			if(trim(lcase(this.request.xml.OrderCalculationCallbacks.CalculatePromotions.XmlText)) is "true")
				this.enabled = listappend(this.enabled,"PROMO");
			if(trim(lcase(this.request.xml.OrderCalculationCallbacks.CalculateShippingRates.XmlText)) is "true")
				this.enabled = listappend(this.enabled,"SHIPPING");
		</cfscript>
	</cffunction>
	
	<cffunction name="isEnabled" access="private" output="false" returntype="Boolean">
		<cfargument name="element" type="string" required="true" hint="TAX, PROMO, or SHIPPING"/>
		<cfreturn listcontainsnocase(this.enabled,trim(arguments.element)) gte 1/>
	</cffunction>
	
	<cffunction name="disable" access="private" output="false" returntype="void">
		<cfargument name="element" type="string" required="true" hint="TAX, PROMO, or SHIPPING"/>
		<cfscript>
			while(listcontainsnocase(arguments.element,this.enabled))
				this.enabled = listdeleteat(this.enabled,listfindnocase(this.enabled,arguments.element));
		</cfscript>
	</cffunction>
	
	<cffunction name="addCustomTaxRate" access="public" output="false" returntype="void" hint="Add a custom tax table to the response. This is used to define custom tax rates for an order.">
		<cfargument name="id" required="true" type="string" hint="The ID used to uniquely identify the tax table. Ex: tax-method-1"/>
		<cfargument name="rate" required="true" type="numeric" hint="The tax rate expressed as a percentage. This value should be greater than zero but less than 1 (i.e. 8% = .08)"/>
		<cfargument name="shippingtaxed" required="false" type="Boolean" default="false" hint="Tax is calculated on shipping. Defaults to false."/>
		<cfargument name="region" required="false" type="string" default="USZip" hint="A predefined region where the tax is applied."/>
		<cfscript>
			var taxTable = StructCopy(arguments);
			
			if(not isEnabled("TAX"))
				throwError("Calculated Tax Rates Unsupported.","Custom tax rate calculation for this request is unavailable. Please modify the cart to enable custom tax tables.");
			
			//Make sure the promotion attribute is available
			if(not StructKeyExists(this,"customTax"))
				this.customTax = StructNew();
			
			
			StructDelete(taxTable,"id"); //Cleanup the struct. ID is redundant since it's the key to the customTax struct.
			StructInsert(this.customTax,arguments.id,taxTable);
		</cfscript>
	</cffunction>
	
	<cffunction name="applyTaxRate" access="public" output="false" returntype="void" hint="Apply a custom tax rate to a specific item (item identified via SKU)">
		<cfargument name="sku" type="string" required="true" hint="SKU number of the item to be uniquely taxed."/>
		<cfargument name="taxTableId" type="string" required="true" hint="The ID of the custom tax rate applied to the item."/>
		<cfscript>
			if(not StructKeyExists(this.customTax,arguments.taxTableId))
				throwError("Invalid tax rate.","The specified tax table could not be found. All custom tax rates must be defined using the addCustomTaxRate method.");
				
			//Apply the tax table ID to the item
			StructInsert(this.request.items[arguments.sku],"TaxTableId",arguments.taxTableId);
		</cfscript>
	</cffunction>
	
	<cffunction name="addPromotion" access="public" output="false" returntype="void" hint="Add a promotion to the response. This is used at an item level to apply promotions/discounts to specific items.">
		<cfargument name="id" required="true" type="string" hint="The ID used to uniquely identify the promotion. Ex: promotion-1"/>
		<cfargument name="description" required="true" type="string" hint="Text description of the promotion."/>
		<cfargument name="amount" required="true" type="numeric" hint="The monetary value (discount) of the promotion."/>
		<cfargument name="fixed" required="false" type="Boolean" default="true" hint="Indicates the discount is a fixed amount. Set to false to use a discount rate. If using a discount rate, the amount should be between 0 and 1 (i.e. 25% off = .25)"/>
		<cfargument name="currency" required="false" type="string" default="USD" hint="The currency of the promotion. Currently only supports USD."/>
		<cfscript>
			var promo = StructCopy(arguments);
			
			if(not isEnabled("PROMO"))
				throwError("Promotions Unsupported.","Promotion calculation for this request is unavailable. Please modify the cart to enable custom tax tables.");
			
			//Make sure the promotion attribute is available
			if(not StructKeyExists(this,"promotion"))
				this.promotion = StructNew();
			
			//Cleanup the struct. The ID is redundant since it is the key for the customTax struct. 
			StructDelete(promo,"id");
			StructInsert(this.promotion,arguments.id,promo);
		</cfscript>
	</cffunction>
	
	<cffunction name="applyPromotion" access="public" output="false" returntype="void" hint="Apply a promotion specific item SKU">
		<cfargument name="sku" type="string" required="true" hint="SKU number of the item to be uniquely taxed."/>
		<cfargument name="promoId" type="string" required="true" hint="The ID of the custom tax rate applied to the item."/>
		<cfscript>
			if(not StructKeyExists(this.promotion,arguments.promoId))
				throwError("Invalid promotion.","The specified promotion could not be found. All promotions must be defined using the addPromotion method.");
				
			//Apply the tax table ID to the item
			StructInsert(this.request.items[arguments.sku],"PromotionId",arguments.promoId);
		</cfscript>
	</cffunction>
	
	<cffunction name="addShippingMethod" access="public" output="false" returntype="void" hint="Add a shipping method. This example uses a limited set of options for demo purposes. To extend, please view the Callback API Guide.">
		<cfargument name="id" type="string" required="true" hint="The unique ID of the shipping method."/>
		<cfargument name="servicelevel" type="string" required="true" hint="Valid values include Standard, Expedited, OneDay, or TwoDay."/>
		<cfargument name="ratetype" type="string" required="true" hint="Valid values include WeightBased, ItemQuantityBased, and ShipmentBased"/>
		<cfargument name="rate" type="numeric" required="true" hint="The monetary rate charged per unit base for this shipping method."/>
		<cfscript>
			var ship = StructCopy(arguments);
			
			if(not isEnabled("SHIPPING"))
				throwError("Shipping Methods Unsupported.","Shipping calculation for this request is unavailable. Please modify the cart to enable custom shipping methods.");
			
			//Make sure the promotion attribute is available
			if(not StructKeyExists(this,"shipping"))
				this.shipping = StructNew();
			
			//Cleanup the struct. The ID is redundant since it is the key for the customTax struct. 
			StructDelete(ship,"id");
			StructInsert(this.shipping,arguments.id,ship);
		</cfscript>
	</cffunction>
		
	<cffunction name="applyShippingMethod" access="public" output="false" returntype="void" hint="Make a custom shipping method available during checkout.">
		<cfargument name="sku" type="string" required="true" hint="SKU number of the item to be uniquely taxed."/>
		<cfargument name="shipId" type="string" required="true" hint="The ID of the custom tax rate applied to the item."/>
		<cfscript>
			if(not StructKeyExists(this.shipping,arguments.shipId))
				throwError("Invalid promotion.","The specified shipping method could not be found. All shipping methods must be defined using the addShippingMethod method.");
				
			//Apply the tax table ID to the item
			if(not StructKeyExists(this.request.items[arguments.sku],"ShippingMethods"))
				StructInsert(this.request.items[arguments.sku],"ShippingMethods",ArrayNew(1));
			
			//Add the method to the item
			arrayappend(this.request.items[arguments.sku]['ShippingMethods'],arguments.shipId);
		</cfscript>
	</cffunction>
	
	<cffunction name="getAllItemSkuNumbers" access="public" output="false" returntype="array" hint="Gets a simple one dimensional array of SKU numbers.">
		<cfscript>
			//Make sure the request is parsed
			requestValid();
			
			return StructKeyArray(this.request.items);
		</cfscript>
	</cffunction>
	
	<cffunction name="getXmlResponse" access="public" output="false" returntype="xml" hint="Generates the XML used in the callback response.">
		<cfscript>
			var i		= 0;
			var n		= 0;
			var xml 	= XmlNew();
			var rsp		= XmlElemNew(xml,"Response");
			var cbos	= XmlElemNew(xml,"CallbackOrders");
			var cbo		= XmlElemNew(xml,"CallbackOrder");
			var cbi		= XmlElemNew(xml,"CallbackOrderItems");
			var addr	= XmlElemNew(xml,"Address");
			var tax		= XmlElemNew(xml,"TaxTables");
			var promo	= XmlElemNew(xml,"Promotions");
			var shipto	= XmlElemNew(xml,"ShippingMethods");
			var item	= "";
			var items	= ArrayNew(1);
			var taxes	= ArrayNew(1);
			var promos	= ArrayNew(1);
			var ship	= ArrayNew(1);
			var benefit	= "";
			var tmp		= "";
			
			//Make sure the request is loaded
			requestValid();
			
			//Create the XML Root with the Amazon Payments namespace.
			xml.XmlRoot = XmlElemNew(xml,"OrderCalculationsResponse");
			xml.XmlRoot.XmlAttributes['xmlns'] = this.xmlns.default;
			
			//Create the address node & append it to the response
			arrayappend(addr.XmlChildren,XmlElemNew(xml,"AddressId"));
			addr.AddressId.XmlText = this.request.address.id;
			arrayappend(cbo.XmlChildren,addr);
			
			//Loop through item list and add each item to the response
			items = getAllItemSkuNumbers();
			for(i=1; i lte arraylen(items); i=i+1){
				//Required response content
				item = XmlElemNew(xml,"CallbackOrderItem");
				arrayappend(item.XmlChildren,XmlElemNew(xml,"CallbackOrderItemId"));
				item.CallbackOrderItemId.XmlText = XmlFormat(this.request.items[items[i]].id);
				
				//Add custom tax if applicable
				if(isEnabled("TAX")){
					arrayappend(item.XmlChildren,XmlElemNew(xml,"TaxTableId"));
					if(StructKeyExists(this.request.items[items[i]],"TaxTableId"))
						item.TaxTableId.XmlText = XmlFormat(this.request.items[items[i]].TaxTableId);
				}
				
				//Add promotion if applicable
				if(isEnabled("PROMO")){
					arrayappend(item.XmlChildren,XmlElemNew(xml,"PromotionIds"));
					arrayappend(item.PromotionIds.XmlChildren,XmlElemNew(xml,"PromotionId"));
					if(StructKeyExists(this.request.items[items[i]],"PromotionId"))
						item.PromotionIds.PromotionId.XmlText = XmlFormat(this.request.items[items[i]].PromotionId);
				}
				
				//Add shipping methods if applicable
				if(isEnabled("SHIPPING")){
					arrayappend(item.XmlChildren,XmlElemNew(xml,"ShippingMethodIds"));
					if(StructKeyExists(this.request.items[items[i]],"ShippingMethods")){
						for(n=1; n lte arraylen(this.request.items[items[i]]['ShippingMethods']); n=n+1){
							tmp = XmlElemNew(xml,"ShippingMethodId");
							tmp.XmlText = XmlFormat(this.request.items[items[i]]['ShippingMethods'][n]);
							arrayappend(item.ShippingMethodIds.XmlChildren,tmp);
						}
					}
				}
				
				arrayappend(cbi.XmlChildren,item);
			}
			
			//Add items to response
			arrayappend(cbo.XmlChildren,cbi);
			arrayappend(cbos.XmlChildren,cbo);
			arrayappend(rsp.XmlChildren,cbos);
			arrayappend(xml.XmlRoot.XmlChildren,rsp);
			
			//Add tax tables if applicable
			if(StructKeyExists(this,"customTax")){
				taxes = StructKeyArray(this.customTax);
				if(arraylen(taxes)){
					//Loop through the tax tables and add each to the response
					for(i=1; i lte arraylen(taxes); i=i+1){
						tmp = XmlElemNew(xml,"TaxTable");
						arrayappend(tmp.XmlChildren,XmlElemNew(xml,"TaxTableId"));
						tmp.TaxTableId.XmlText=taxes[i];
						arrayappend(tmp.XmlChildren,XmlElemNew(xml,"TaxRules"));
						arrayappend(tmp.TaxRules.XmlChildren,XmlElemNew(xml,"TaxRule"));
						arrayappend(tmp.TaxRules.TaxRule.XmlChildren,XmlElemNew(xml,"Rate"));
						tmp.TaxRules.TaxRule.Rate.XmlText = XmlFormat(this.customTax[taxes[i]].rate);
						arrayappend(tmp.TaxRules.TaxRule.XmlChildren,XmlElemNew(xml,"IsShippingTaxed"));
						if (this.customTax[taxes[i]].shippingtaxed)
							tmp.TaxRules.TaxRule.IsShippingTaxed.XmlText = "true";
						else
							tmp.TaxRules.TaxRule.IsShippingTaxed.XmlText = "false";
						//For brevity & clarity of the example, only US Zip codes are supported in this demo.
						//Please refer to the Callback API Guide for extension options.
						arrayappend(tmp.TaxRules.TaxRule.XmlChildren,XmlElemNew(xml,"USZipRegion"));
						tmp.TaxRules.TaxRule.USZipRegion.XmlText = XmlFormat(this.request.address.zip);
						
						arrayappend(tax.XmlChildren,tmp);
					}
					arrayappend(xml.XmlRoot.XmlChildren,tax);
				} else
					disable("TAX");
			}
			
			//Add promotion tables if applicable
			if(StructKeyExists(this,"promotion")){
				promos = StructKeyArray(this.promotion);
				if (arraylen(promos)){
					//Loop through the tax tables and add each to the response
					for(i=1; i lte arraylen(promos); i=i+1){
						tmp = XmlElemNew(xml,"Promotion");
						arrayappend(tmp.XmlChildren,XmlElemNew(xml,"PromotionId"));
						tmp.PromotionId.XmlText=promos[i];
						arrayappend(tmp.XmlChildren,XmlElemNew(xml,"Description"));
						tmp.Description.XmlText=this.promotion[promos[i]].description;
						
						//Handle fixed and variable benefits
						benefit = XmlElemNew(xml,"Benefit");
						if(this.promotion[promos[i]].fixed){
							arrayappend(benefit.XmlChildren,XmlElemNew(xml,"FixedAmountDiscount"));
							arrayappend(benefit.FixedAmountDiscount.XmlChildren,XmlElemNew(xml,"Amount"));
							benefit.FixedAmountDiscount.Amount.XmlText = this.promotion[promos[i]].amount;
							arrayappend(benefit.FixedAmountDiscount.XmlChildren,XmlElemNew(xml,"CurrencyCode"));
							benefit.FixedAmountDiscount.CurrencyCode.XmlText = this.promotion[promos[i]].currency;
						} else {
							arrayappend(benefit.XmlChildren,XmlElemNew(xml,"DiscountRate"));
							benefit.DiscountRate.XmlText = this.promotion[promos[i]].amount;
						}
						arrayappend(tmp.XmlChildren,benefit);
						arrayappend(promo.XmlChildren,tmp);
					}
					arrayappend(xml.XmlRoot.XmlChildren,promo);
				} else
					disable("PROMO");
			}
			
			//Add shipping tables if applicable
			if(StructKeyExists(this,"shipping")){
				ship = StructKeyArray(this.shipping);
				if(arraylen(ship)){
					//Loop through the tax tables and add each to the response
					for(i=1; i lte arraylen(ship); i=i+1){
						tmp = XmlElemNew(xml,"ShippingMethod");
						arrayappend(tmp.XmlChildren,XmlElemNew(xml,"ShippingMethodId"));
						tmp.ShippingMethodId.XmlText=ship[i];
						arrayappend(tmp.XmlChildren,XmlElemNew(xml,"ServiceLevel"));
						tmp.ServiceLevel.XmlText=XmlFormat(this.shipping[ship[i]].servicelevel);
						
						//Add rates
						arrayappend(tmp.XmlChildren,XmlElemNew(xml,"Rate"));
						arrayappend(tmp.Rate.XmlChildren,XmlElemNew(xml,this.shipping[ship[i]].ratetype));
						arrayappend(tmp.Rate[this.shipping[ship[i]].ratetype].XmlChildren,XmlElemNew(xml,"Amount"));
						tmp.Rate[this.shipping[ship[i]].ratetype].Amount.XmlText=XmlFormat(this.shipping[ship[i]].rate);
						arrayappend(tmp.Rate[this.shipping[ship[i]].ratetype].XmlChildren,XmlElemNew(xml,"CurrencyCode"));
						tmp.Rate[this.shipping[ship[i]].ratetype].CurrencyCode.XmlText=XmlFormat('USD');
						
						//Add the current region. For simplicity, only the postal/zip code of the buyer is used.
						//Regions can be excluded or modified. See documentation for help extending this section.
						arrayappend(tmp.XmlChildren,XmlElemNew(xml,"IncludedRegions"));
						arrayappend(tmp.IncludedRegions.XmlChildren,XmlElemNew(xml,"USZipRegion"));
						tmp.IncludedRegions.USZipRegion.XmlText = XmlFormat(this.request.address.zip);
						
						arrayappend(shipto.XmlChildren,tmp);
					}
					arrayappend(xml.XmlRoot.XmlChildren,shipto);
				}
			} else
				disable("SHIPPING");
			
			return xml;
		</cfscript>
	</cffunction>
	
	<cffunction name="getXmlErrorResponse" access="public" output="false" returntype="xml" hint="A helper method to respond to Amazon with an error message.">
		<cfargument name="code" type="string" required="false" default="INTERNAL_SERVER_ERROR"/>
		<cfargument name="message" type="string" required="false" default="Unknown Error"/>
		<cfscript>
			var i		= 0;
			var xml 	= XmlNew();
			var response= XmlElemNew(xml,"Response");
			var error	= XmlElemNew(xml,"Error");
			var cd		= XmlElemNew(xml,"Code");
			var msg		= XmlElemNew(xml,"Message");
			
			if(not listcontainsnocase("INVALID_SHIPPING_ADDRESS,INTERNAL_SERVER_ERROR,SERVICE_UNAVAILABLE",trim(ucase(arguments.code))))
				throwError("Invalid error code","The error code must be one of the following: INVALID_SHIPPING_ADDRESS,INTERNAL_SERVER_ERROR,SERVICE_UNAVAILABLE");
			
			//Create the XML Root with the Amazon Payments namespace.
			xml.XmlRoot = XmlElemNew(xml,"OrderCalculationsResponse");
			xml.XmlRoot.XmlAttributes['xmlns'] = "Checkout by Amazon Shopping Cart";
			
			//Populate error message
			cd.XmlText = XmlFormat(ucase(arguments.code));
			msg.XmlText = XmlFormat(arguments.message);
			
			//Construct XML nodes
			arrayappend(error.XmlChildren,cd);
			arrayappend(error.XmlChildren,msg);
			arrayappend(response.XmlChildren,error);
			arrayappend(xml.XmlRoot.XmlChildren,response);
			
			return xml;
		</cfscript>
	</cffunction>
	
	<cffunction name="generateResponse" access="public" output="false" returntype="string" hint="Generate the properly encoded response.">
		<cfscript>
			var xml = toString(getXmlResponse());
			var str = "order-calculations-response="&urlencodedformat(xml);
			
			//Add the other attributes required for a proper response
			str = listappend(str,"Signature="&urlencodedformat(super.sign(xml,this.secretKeyId)),"&");
			str = listappend(str,"aws-access-key-id="&urlencodedformat(this.accessKeyId),"&");
			
			return trim(str);
		</cfscript>
	</cffunction>
	
	<cffunction name="requestValid" access="private" output="true" returntype="void">
		<cfscript>
			if(not StructKeyExists(this,"request"))
				throwError("Invalid request.","The request is invalid or could not be found. Use parseRequest() to load the request manually.");
		</cfscript>
	</cffunction>
	
	<cffunction name="throwError" access="private" output="true" hint="A wrapper method for ColdFusion error output (supports some older versions of CF).">
		<cfargument name="message" type="string" required="false" default="Unknown Error."/>
		<cfargument name="detail" type="string" required="false" default="Unknown Error."/>
		<cfscript>
			super.throwError(arguments.message,arguments.detail);
		</cfscript>
	</cffunction>
	
</cfcomponent>