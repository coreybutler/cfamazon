<cfcomponent hint="Simple Cart" extends="com.amazon.factory" output="false">

	<cfproperty name="items" type="array" />
	<cfproperty name="currencyCode" hint="The default currency code. Currently supports USD only." type="string" default="USD" />

	<cffunction name="init" hint="Initialize an empty cart" returntype="void">
		<cfargument name="accessKeyID" type="string" required="true" hint="Your Checkout by Amazon Access Key ID"/>
		<cfargument name="secretKeyID" type="string" required="true" hint="Your Checkout by Amazon Secret Access Key"/>
		<cfargument name="merchantID" type="string" required="true" hint="Your Merchant ID"/>
		<cfargument name="sandbox" type="boolean" required="false" hint="True if using the sandbox environment." default="false"/>
		<cfscript>
			//Initialize the parent object
			super.init(arguments.accessKeyID,arguments.secretKeyID,arguments.merchantID,arguments.sandbox);
			
			//Create default containers
			this.items = ArrayNew(1);
			this.currencyCode = 'USD';
			
			//The following are only used if Callbacks are used in processing
			this.callbacks = false;
			this.CalculateTaxRates = false;
			this.CalculatePromotions = false;
			this.CalculateShippingRates = false;
			this.processOrderOnCallbackFailure = false;
			this.callbackUrl = CGI.SERVER_NAME;
			this.customTax = StructNew();
			this.promotion = StructNew();
			this.shippingMethod = StructNew();
			
		</cfscript>
	</cffunction>
	
	<cffunction name="getCallbackUrl" access="public" output="false" returntype="String">
		<cfreturn this.CallbackUrl />
	</cffunction>

	<cffunction name="setCallbackUrl" access="public" output="false" returntype="void">
		<cfargument name="url" type="String" required="true" />
		<cfscript>
			this.CallbackUrl = trim(arguments.url);
			enableCallbacks();
		</cfscript>
	</cffunction>
	
	<cffunction name="getProcessOrderOnCallbackFailure" access="public" output="false" returntype="Boolean">
		<cfreturn this.processOrderOnCallbackFailure />
	</cffunction>

	<cffunction name="setProcessOrderOnCallbackFailure" access="public" output="false" returntype="void">
		<cfargument name="tf" type="Boolean" required="true" />
		<cfscript>
			this.processOrderOnCallbackFailure = arguments.tf;
			enableCallbacks();
		</cfscript>
	</cffunction>
	
	<cffunction name="getCalculateTaxRates" access="public" output="false" returntype="Boolean">
		<cfreturn this.CalculateTaxRates />
	</cffunction>

	<cffunction name="setCalculateTaxRates" access="public" output="false" returntype="void">
		<cfargument name="tf" type="Boolean" required="true" />
		<cfscript>
			this.CalculateTaxRates = arguments.tf;
			enableCallbacks();
		</cfscript>
	</cffunction>
	
	<cffunction name="getCalculatePromotions" access="public" output="false" returntype="Boolean">
		<cfreturn this.CalculatePromotions />
	</cffunction>

	<cffunction name="setCalculatePromotions" access="public" output="false" returntype="void">
		<cfargument name="tf" type="Boolean" required="true" />
		<cfscript>
			this.CalculatePromotions = arguments.tf;
			enableCallbacks();
		</cfscript>
	</cffunction>
	
	<cffunction name="getCalculateShippingRates" access="public" output="false" returntype="Boolean">
		<cfreturn this.CalculateShippingRates />
	</cffunction>

	<cffunction name="setCalculateShippingRates" access="public" output="false" returntype="void">
		<cfargument name="tf" type="Boolean" required="true" />
		<cfscript>
			this.CalculateShippingRates = arguments.tf;
			enableCallbacks();
		</cfscript>
	</cffunction>
	
	<cffunction name="getCallbacks" access="public" output="false" returntype="Boolean">
		<cfreturn this.callbacks />
	</cffunction>

	<cffunction name="enableCallbacks" access="public" output="false" returntype="void">
		<cfset this.callbacks = true />
		<cfreturn />
	</cffunction>

	<cffunction name="disableCallbacks" access="public" output="false" returntype="void">
		<cfset this.callbacks = false />
		<cfreturn />
	</cffunction>

	<cffunction name="getItems" access="public" output="false" returntype="array">
		<cfreturn this.items />
	</cffunction>

	<cffunction name="getCurrencyCode" access="public" output="false" returntype="string">
		<cfreturn this.currencyCode />
	</cffunction>

	<cffunction name="setCurrencyCode" access="public" output="false" returntype="void">
		<cfargument name="currencyCode" type="string" required="true" />
		<cfset this.currencyCode = arguments.currencyCode />
		<cfreturn />
	</cffunction>

	<cffunction name="addCustomItem" hint="Add an item object to the cart." access="public" output="false" returntype="void">
		<cfargument name="item" type="com.amazon.cba.item" hint="The item to add to the cart." required="true" />
		<cfset arrayappend(this.items,arguments.item)/>
	</cffunction>
	
	<cffunction name="addItem" hint="Add an item to the cart." access="public" output="false" returntype="void">
		<cfargument name="title" type="string" hint="The short description for your Item." required="true" />
		<cfargument name="price" type="numeric" hint="The monetary cost of the item." default="0" required="true" />
		<cfargument name="quantity" type="numeric" hint="The total number of this Item being purchased." default="0" required="true" />
		<cfargument name="sku" type="string" hint="The SKU assigned to the Item." required="false" />
		<cfscript>
			var item = createOBject("component","com.amazon.cba.item");
			
			//Initialize a new item object
			item.init(arguments.title,arguments.price,arguments.quantity);
	
			//Add a SKU number to the item (if specified)
			if(StructKeyExists(arguments,"sku"))
				item.setSku(arguments.sku);
				
			//Add the item to the cart
			addCustomItem(item);
		</cfscript>
	</cffunction>

	<cffunction name="removeItem" hint="Remove an item from the cart" access="public" output="false" returntype="void">
		<cfargument name="index" type="numeric" hint="The index number of the item to be removed." required="true" />
		<cfset arraydeleteat(this.items,arguments.index)/>
	</cffunction>
	
	<cffunction name="getItemAt" hint="Get the item at the specified cart index." access="public" returntype="com.amazon.cba.item">
		<cfargument name="index" type="numeric" hint="The index number of the item to be removed." required="true" />
		<cfreturn this.items[arguments.index]/>
	</cffunction>

	<cffunction name="addPromotion" hint="Add a promotional discount applied to the entire cart. (ex: $5 off your order)" access="public" returntype="void">
		<cfargument name="id" required="true" type="string" hint="The ID used to uniquely identify the promotion. Ex: cart-promotion-1"/>
		<cfargument name="description" required="true" type="string" hint="Text description of the promotion."/>
		<cfargument name="amount" required="true" type="numeric" hint="The monetary value (discount) of the promotion."/>
		<cfargument name="fixed" required="false" type="Boolean" default="true" hint="Indicates the discount is a fixed amount. Set to false to use a discount rate. If using a discount rate, the amount should be between 0 and 1 (i.e. 25% off = .25)"/>
		<cfargument name="currency" required="false" type="string" default="USD" hint="The currency of the promotion. Currently only supports USD."/>
		<cfscript>
			//Make sure the promotion attribute is available
			if(not StructKeyExists(this,"cartpromotion"))
				this.cartpromotion = StructNew();
			
			//Cleanup the struct. The ID is redundant since it is the key for the customTax struct. 
			this.cartpromotion = StructCopy(arguments);
		</cfscript>
	</cffunction>
	
	<cffunction name="getXML" access="public" hint="Get the cart as Raw XML" returntype="string">
		<cfscript>
			var i		= 0;
			var xml 	= XmlNew();
			var cart 	= XmlElemNew(xml,"Cart");
			var items 	= XmlElemNew(xml,"Items");
			var cb		= XmlElemNew(xml,"OrderCalculationCallbacks");//Callbacks
			var promo	= "";
			var benefit	= "";
			var item 	= "";
			var tmp		= "";
			
			//Create the XML Root with the Amazon Payments namespace.
			xml.XmlRoot = XmlElemNew(xml,"Order");
			xml.XmlRoot.XmlAttributes['xmlns'] = this.xmlns.default;
			
			//Generate the XML nodes for each item
			for(i=1; i lte arraylen(this.items); i=i+1){
				
				//Get the item data object
				item  = getItemAt(i);
				
				//Create an empty XML node
				tmp = XmlElemNew(xml,"Item");
				
				
				
				/************ REQUIRED ITEM ATTRIBUTES **************/
				
				//Add SKU: This is required in most cases for signed carts
				if(StructKeyExists(item,"sku")){
					arrayappend(tmp.XmlChildren,XmlElemNew(xml,"SKU"));
					tmp.SKU.XmlText = XmlFormat(item.sku);
				} else if (this.callbacks)
					super.throwError("SKU required in callback request.","A SKU is required for each item when using the Amazon callback API.");
				
				//Add your merchant ID to the item node
				arrayappend(tmp.XmlChildren,XmlElemNew(xml,"MerchantId"));
				tmp.MerchantId.XmlText = XmlFormat(this.merchantID);
				
				//Add Item Title
				arrayappend(tmp.XmlChildren,XmlElemNew(xml,"Title"));
				tmp.Title.XmlText = XmlFormat(item.title);
				
				//Add Item Price
				arrayappend(tmp.XmlChildren,XmlElemNew(xml,"Price"));
				arrayappend(tmp.Price.XmlChildren,XmlElemNew(xml,"Amount"));
				arrayappend(tmp.Price.XmlChildren,XmlElemNew(xml,"CurrencyCode"));
				tmp.Price.Amount.XmlText = XmlFormat(item.price);
				tmp.Price.CurrencyCode.XmlText = XmlFormat(item.currencycode);
				
				//Add Item Quantity
				arrayappend(tmp.XmlChildren,XmlElemNew(xml,"Quantity"));
				tmp.Quantity.XmlText = XmlFormat(item.quantity);
				
				
				
				/************ OPTIONAL ITEM ATTRIBUTES **************/
				
				//Add Weight
				if(StructKeyExists(item,"weight")){
					arrayappend(tmp.XmlChildren,XmlElemNew(xml,"Weight"));
					arrayappend(tmp.Weight.XmlChildren,XmlElemNew(xml,"Amount"));
					arrayappend(tmp.Weight.XmlChildren,XmlElemNew(xml,"Unit"));
					tmp.Weight.Amount.XmlText = XmlFormat(item.weight);
					tmp.Weight.Unit.XmlText = XmlFormat(item.weightunit);
				}
				
				//There are many more optional item attributes that can be added here.
				
				
				
				/************ ADD ITEM XML NODE **************/
				arrayappend(items.XmlChildren,tmp);
			}
			
			//Add all child nodes to the XML document
			arrayappend(cart.XmlChildren,items);
			//Add a cart promotion (if applicable)
			if(StructKeyExists(this,"cartpromotion")){
				arrayappend(cart.XmlChildren,XmlElemNew(xml,"CartPromotionId"));
				cart.CartPromotionId.XmlText = XmlFormat(this.cartpromotion.id);
			}
			arrayappend(xml.XmlRoot.XmlChildren,cart);
			
			//If a cart-level promotion has been applied, create the appropriate XML node.
			if(StructKeyExists(this,"cartpromotion")){
				promo = XmlElemNew(xml,"Promotions");
				arrayappend(promo.XmlChildren,XmlElemNew(xml,"Promotion"));
				arrayappend(promo.Promotion.XmlChildren,XmlElemNew(xml,"PromotionId"));
				arrayappend(promo.Promotion.XmlChildren,XmlElemNew(xml,"Description"));
				
				benefit = XmlElemNew(xml,"Benefit");
				if(this.cartpromotion.fixed){
					arrayappend(benefit.XmlChildren,XmlElemNew(xml,"FixedAmountDiscount"));
					arrayappend(benefit.FixedAmountDiscount.XmlChildren,XmlElemNew(xml,"Amount"));
					benefit.FixedAmountDiscount.Amount.XmlText = this.cartpromotion.amount;
					arrayappend(benefit.FixedAmountDiscount.XmlChildren,XmlElemNew(xml,"CurrencyCode"));
					benefit.FixedAmountDiscount.CurrencyCode.XmlText = this.cartpromotion.currency;
				} else {
					arrayappend(benefit.XmlChildren,XmlElemNew(xml,"DiscountRate"));
					benefit.DiscountRate.XmlText = this.promotion.amount;
				}
				arrayappend(promo.Promotion.XmlChildren,benefit);
				promo.Promotion.PromotionId.XmlText = XmlFormat(this.cartpromotion.id);
				promo.Promotion.Description.XmlText = XmlFormat(this.cartpromotion.description);
				
				//Add to the XML
				arrayappend(xml.XmlRoot.XmlChildren,promo);
			}
	
			//If callbacks are enabled, add OrderCalculationCallbacks BELOW the cart node
			if(this.callbacks){
				
				//Calculate Taxes
				arrayappend(cb.XmlChildren,XmlElemNew(xml,"CalculateTaxRates"));
				cb.CalculateTaxRates.XmlText = XmlFormat(this.CalculateTaxRates);
				
				//Calculate Promotions
				arrayappend(cb.XmlChildren,XmlElemNew(xml,"CalculatePromotions"));
				cb.CalculatePromotions.XmlText = XmlFormat(this.CalculatePromotions);
				
				//Calculate Shipping Rates
				arrayappend(cb.XmlChildren,XmlElemNew(xml,"CalculateShippingRates"));
				cb.CalculateShippingRates.XmlText = XmlFormat(this.CalculateShippingRates);
				
				//Add endpoint
				arrayappend(cb.XmlChildren,XmlElemNew(xml,"OrderCallbackEndpoint"));
				cb.OrderCallbackEndpoint.XmlText = XmlFormat(this.callbackUrl);
				
				//Indicate whether processing should continue on callback failure
				arrayappend(cb.XmlChildren,XmlElemNew(xml,"ProcessOrderOnCallbackFailure"));
				cb.ProcessOrderOnCallbackFailure.XmlText = XmlFormat(this.processOrderOnCallbackFailure);
				
				arrayappend(xml.Xmlroot.XmlChildren,cb);
			}
			
			return trim(toString(xml));
		</cfscript>
	</cffunction>
	
	<cffunction name="getXmlSignature" access="public" hint="A shortcut method for returning the XML signature.">
		<cfscript>
			return super.sign(getXML(),this.secretKeyID);
		</cfscript>
	</cffunction>
	
	<cffunction name="getHtmlObject" access="public" hint="Returns a struct object containing the HTML and signature data necessary for processing the cart as HTML. Contains the following keys: header, form, signature, and html. The html key is the combination of the other three keys (shortcut)." returntype="struct">
		<cfargument name="signed" type="boolean" required="false" default="true" hint="Set this to false to create an UNsigned cart."/>
		<cfscript>
			var i		= 0;
			var cr		= chr(10); //Carriage Return
			var item	= "";
			var sigBase	= "";
			var itemHTML= "";
			var obj		= StructNew();
			var btnId	= createuuid();
			var formId	= createuuid();
			
			//EMPTY CART
			if(not arraylen(this.items))
				return obj;
			
			//COMMON HTML
			obj.signed = arguments.signed;
			obj.header = "<script type=""text/javascript"" src=""https://images-na.ssl-images-amazon.com/images/G/01/cba/js/jquery.js""></script>" & cr;
			obj.header = obj.header & "<script type=""text/javascript"" src=""https://images-na.ssl-images-amazon.com/images/G/01/cba/js/widget/widget.js""></script>";
			obj.form = "<form id=""#formId#"">" & cr;
			obj.form = obj.form & "<input name=""aws_access_key_id"" value=""#this.accessKeyID#"" type=""hidden"" />" & cr;
			obj.form = obj.form & "<input name=""currency_code"" value="""&this.items[1].currencycode&""" type=""hidden"" />" & cr;
			
			//HTML signature string
			sigBase = "aws_access_key_id="&this.accessKeyID;
			sigBase = listappend(sigBase,"currency_code="&this.items[1].currencycode,"&");
			
			
			//ITEM HTML
			for(i=1; i lte arraylen(this.items); i=i+1){
				
				//Get the item data object
				item  = getItemAt(i);
				
				//Prepare a fresh list of HTML form elements
				itemHTML = "";
				
				/************ REQUIRED ITEM ATTRIBUTES **************/
				itemHTML = listappend(itemHTML,"<input name=""item_merchant_id_#i#"" value="""&this.merchantID&""" type=""hidden"" />",cr);
				itemHTML = listappend(itemHTML,"<input name=""item_title_#i#"" value="""&item.title&""" type=""hidden"" />",cr);
				itemHTML = listappend(itemHTML,"<input name=""item_price_#i#"" value="""&item.price&""" type=""hidden"" />",cr);
				itemHTML = listappend(itemHTML,"<input name=""item_quantity_#i#"" value="""&item.quantity&""" type=""hidden"" />",cr);
				sigBase = listappend(sigBase,"item_merchant_id_"&i&"="&urlencodedformat(this.merchantID),"&");
				sigBase = listappend(sigBase,"item_title_"&i&"="&urlencodedformat(item.title),"&");
				sigBase = listappend(sigBase,"item_price_"&i&"="&urlencodedformat(item.price),"&");
				sigBase = listappend(sigBase,"item_quantity_"&i&"="&urlencodedformat(item.quantity),"&");
			
			
				/************ OPTIONAL ITEM ATTRIBUTES **************/
				if(StructKeyExists(item,"sku")){
					itemHTML = listappend(itemHTML,"<input name=""item_sku_#i#"" value="""&item.sku&""" type=""hidden"" />",cr);
					sigBase = listappend(sigBase,"item_sku_"&i&"="&urlencodedformat(item.sku),"&");
				}
				
				if(StructKeyExists(item,"description")){
					itemHTML = listappend(itemHTML,"<input name=""item_description_#i#"" value="""&item.description&""" type=""hidden"" />",cr);
					sigBase = listappend(sigBase,"item_description_"&i&"="&urlencodedformat(item.description),"&");
				}
					
				if(StructKeyExists(item,"weight")){
					itemHTML = listappend(itemHTML,"<input name=""item_weight_#i#"" value="""&item.weight&""" type=""hidden"" />",cr);
					itemHTML = listappend(itemHTML,"<input name=""item_weight_unit_#i#"" value="""&item.weightUnit&""" type=""hidden"" />",cr);
					sigBase = listappend(sigBase,"item_weight_"&i&"="&urlencodedformat(item.weight),"&");
					sigBase = listappend(sigBase,"item_weight_unit_"&i&"="&urlencodedformat(item.weightUnit),"&");
				}
				
				//Sort HTML items for consistency & add to the form
				itemHTML = listsort(itemHTML,"text","asc",cr);
				obj.form = obj.form & itemHTML;
			}
			
			
			/************ CREATE SIGNATURE **************/
			sigBase = listsort(sigBase,"text","asc","&");
			obj.signature = super.sign(sigBase,this.secretKeyID);
			
			
			/************ FINISH HTML FORM **************/
			if(arguments.signed)
				obj.form = obj.form & cr&"<input name=""merchant_signature"" value="""&obj.signature&""" type=""hidden"" />" & cr;
			obj.form = obj.form &"</form>";
			
			//Create the checkout button
			obj.button = StructNew();
			obj.button.code = "<div id=""#btnId#""/>";
			obj.button.javascript = "<script>"&cr&"new CBA.Widgets.StandardCheckoutWidget({"&cr;
			obj.button.javascript = obj.button.javascript & "merchantId:'#this.merchantID#',"&cr&"orderInput:{"&cr;
			obj.button.javascript = obj.button.javascript & "format:""HTML""," & cr & "value:""#formId#""" & cr & "},"&cr;
			obj.button.javascript = obj.button.javascript & "buttonSettings:{size:'large',color:'orange',background:'white'}";
			obj.button.javascript = obj.button.javascript & cr & "}).render(""#btnId#"");";
			obj.button.javascript = obj.button.javascript & cr & "</script>";
			
			//Concatenate the HTML for the entire cart
			obj.html = obj.header & cr & obj.form & cr & obj.button.code & cr & obj.button.javascript;
			obj.signatureinput = sigBase;
dumpx(obj);			
			return obj;
		</cfscript>
	</cffunction>
	
	<cffunction name="getHtml" access="public" hint="A shortcut method to return the cart as HTML." returntype="string">
		<cfargument name="signed" type="boolean" required="false" default="true" hint="Set this to false to create an UNsigned cart."/>
		<cfreturn getHtmlObject(arguments.signed).html />
	</cffunction>
	
	<cffunction name="getHtmlSignature" access="public" hint="A shortcut method to return the cart HTML signature.">
		<cfreturn getHtmlObject().signature />
	</cffunction>
</cfcomponent>