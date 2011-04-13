<!--- Create an Amazon Factory to help with processing the callback --->
<cfset callback = createObject("component","com.amazon.cba.callback")/>
<cfset callback.init('@ID','@SECRET','@MERCHANT',true)/>

<!--- Callback API Response --->
<cftry>
	
	<!--- 1. Verify the request is from Amazon within the appropriate timeframe. --->
	<!--- This step can be skipped if you accept UNsigned carts in Seller Central. --->
	<cfset valid = callback.verifyRequestIsFromAmazon(urldecode(form.UUID),urldecode(form.Timestamp),form.Signature)/>
	<cfif not valid>
		<cfsavecontent variable="out"><cfdump var="#form#"></cfsavecontent>
		<cfset match = callback.getSignatureMatch(urldecode(form.UUID),urldecode(form.Timestamp),form.Signature)/>
		<cfmail to="@EMAILTO" from="@EMAILFROM" subject="INVALID CALLBACK REQUEST" type="html">Match Part A:#match.request# (Request)<br/>Match Part B:#match.response# (Response)<br/>Time Difference:#match.timeDifference#<hr>#out#</cfmail>
		<cfoutput>#callback.getXmlErrorResponse("INTERNAL_SERVER_ERROR","Invalid Request")#</cfoutput>
		<cfexit>
	</cfif>
	
	
	<!--- 2. Parse the XML Request Data --->
	<cfset callback.parseRequest(urldecode(form['order-calculations-request']))/>
	
	
	<!--- 3. Calculate Tax Rates, Promotional Discounts, and/or Shipping Rates --->
	<cfscript>
		//Get all Item SKU numbers from the order
		skus = callback.getAllItemSkuNumbers();
				
		//Create a custom tax rate
		callback.addCustomTaxRate("wa-sales-tax",.065,true);
		
		//Create & apply a basic promotion/discount
		callback.addPromotion("halfoffbluefish","Half Off Blue Fish!",.5,false);
		callback.applyPromotion(skus[2],"halfoffbluefish"); //applied to the second item (Blue Fish)
		
		//Create a buy one get one free promotion.
		//The SKU number of the promotion item (as found on xml-signed-callbacks.cfm)
		saleItemSku = "12345SKU"; 
		//Make sure the item is in the cart
		if(StructKeyExists(callback.request.items,saleItemSku)){
			itemprice = 19.99; //as found on xml-signed-callbacks.cfm
			callback.addPromotion("buy1get1free"&saleItemSku,"Buy one Red Fish, get one FREE!",itemprice,true);
			callback.applyPromotion(saleItemSku,"buy1get1free"&saleItemSku);
		}
		
		//Apply a coupon code if one exists
		//This is not a Checkout By Amazon promotion defined in Seller Central!
		//This assumes you have created & manage your own custom coupon program!
		if(isdefined("session")){
			if (StructKeyExists(session,"coupon")){
				//Assumes the session variable "coupon" contains the SKU of the promotional item (Fish Tank)
				if(StructKeyExists(callback.request.items,session.coupon)){
					callback.addPromotion("coupon","$5 OFF Fish Tank",5,true);
					callback.applyPromotion(session.coupon,"coupon");
				}
			}
		}
		
		
		//Create special shipping rates
		callback.addShippingMethod("US One-day","OneDay","ItemQuantityBased",10.29);
		callback.addShippingMethod("US Two-day","TwoDay","ItemQuantityBased",7.29);
		callback.addShippingMethod("US Standard","Standard","WeightBased",2.50);
		
		//Apply custom tax rates to all items
		for(i=1; i lte arraylen(skus); i=i+1){
			callback.applyTaxRate(skus[i],"wa-sales-tax");
			callback.applyShippingMethod(skus[i],"US One-day");
			callback.applyShippingMethod(skus[i],"US Two-day");
			callback.applyShippingMethod(skus[i],"US Standard");
		}
		
	</cfscript>
	
	<cfmail to="@EMAILTO" from="@EMAILFROM" subject="TEST OUTPUT" type="text">#callback.generateResponse()#</cfmail>
		
	<cfscript>	
		writeoutput(callback.generateResponse());
	</cfscript>
	
	<!--- Processing any errors --->
	<cfcatch type="any">
		
		<!--- Notify an administrator of the error/s --->
		<cfsavecontent variable="out">
			Enabled: <cfoutput>#callback.enabled#</cfoutput><br/>
			<cfdump var="#callback#">
			<cfdump var="#form#" label="Form Elements">
			<cfdump var="#cfcatch#" label="Error">
		</cfsavecontent>
		<cfmail to="@EMAILTO" from="@EMAILFROM" subject="CALLBACK ERROR" type="html">#out#</cfmail>
		
		<!--- Respond to Amazon with an error --->
		<cfoutput>#toString(callback.getXmlResponse("INTERNAL_SERVER_ERROR",cfcatch.message&" "&cfcatch.detail))#</cfoutput>
		
	</cfcatch>
</cftry>