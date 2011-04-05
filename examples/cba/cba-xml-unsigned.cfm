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
	
	xml = XmlParse(cart.getXML());
</cfscript>
<html>
	<head>
		<!-- NOTICE: Example uses payments sandbox -->
		<script language="javascript" src="https://payments-sandbox.amazon.com/cba/js/PaymentWidgets.js"></script>
		<title>XML UNsigned Cart Example</title>
	</head>
	<body>
		<!-- Unsigned Checkout -->
		<div id="unsignedBtn"/>
		<cfoutput>
		<script>
			new CBA.Widgets.StandardCheckoutWidget({
				merchantId:'#cart.merchantID#',
				orderInput:{
					format:"XML",
					value: "type:unsigned-order/aws-accesskey/1;order:#toBase64(cart.getXml())#"
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