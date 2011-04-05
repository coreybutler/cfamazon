<cfscript>
	//Create the cart
	cart = createObject("component","com.amazon.cba.cart");
	
	/*
	 * Initialize the cart with your access key, secret key, and merchant ID
	 * Your access/secret key are available in Seller Central under Integration->Access Key
	 * and your merchant ID is available under Settings->Checkout Pipeline Settings
	 */	
	cart.init('@ID','@SECRET','@MERCHANT',true);
	
	//Add a regular item to the cart.
	cart.addItem('Red Fish',19.99,1);
	
	//Add a customized item to the cart.
	item = createObject("component","com.amazon.cba.item");
	item.init('Blue Fish',29.99,1);
	item.setWeight(1.75,"lb");
	cart.addCustomItem(item);
</cfscript>
<html>
	<head>
		<!-- NOTICE: Example uses payments sandbox -->
		<script language="javascript" src="https://payments-sandbox.amazon.com/cba/js/PaymentWidgets.js"></script>
		<title>XML Signed Cart Example</title>
	</head>
	<body>
		<em>Regular Order</em>
		<table cellpadding="1" cellspacing="1" border="1">
			<tr>
				<th>Item</th>
				<th>Quantity</th>
				<th>Price</th>
				<th>Amount</th>
			</tr>
			<cfset tot = 0/>
			<cfloop from="1" to="#arraylen(cart.items)#" step="1" index="i">
				<cfoutput>
					<tr>
						<td>#cart.items[i].title#</td>
						<td align="center">#cart.items[i].quantity#</td>
						<td align="right">#DollarFormat(cart.items[i].price)#</td>
						<td align="right">#DollarFormat(cart.items[i].amount)#</td>
					</tr>
				</cfoutput>
				<cfset tot = tot+cart.items[i].amount>
			</cfloop>
			<tr>
				<th colspan="3" align="right">Total</th>
				<th><cfoutput>#DollarFormat(tot)#</cfoutput></th>
			</tr>
		</table>
		<!--- <cfdump var="#cart.items#" label="Cart Items"> --->
		<br/><!-- Signed Checkout -->
		<div id="signedBtn"/>
		<cfoutput>
		<script>
			new CBA.Widgets.StandardCheckoutWidget({
				merchantId:'#cart.merchantID#',
				orderInput:{
					format:"XML",
					value: "type:merchant-signed-order/aws-accesskey/1;order:#toBase64(cart.getXml())#;signature:#cart.getXmlSignature()#;aws-access-key-id:#cart.accessKeyID#"
				},
				buttonSettings:{
					size:'large',
					color:'orange',
					background:'green'
				}
			}).render("signedBtn");
		</script>
		</cfoutput>
	</body>
</html>