<!--- Instant Payment Notification --->
<cftry>
	
	<!--- Create an Amazon Factory to help with processing the notice --->
	<cfset factory = createObject("component","com.amazon.factory")/>
	<cfset factory.init('@ID','@SECRET','@MERCHANT',true)/>
	
	<!--- 1. Parse the XML Notification Data --->
	<cfset xml = XmlParse(urldecode(form.NotificationData))/>
	
	
	<!--- 2. Verify the request is from Amazon within the appropriate timeframe. --->
	<cfset valid = factory.verifyRequestIsFromAmazon()/>
	<cfif not valid>
		<!--- Process invalid order or send a notice to an administrator --->
		<cfsavecontent variable="out">
			<cfdump var="#form#">
		</cfsavecontent>
		<cfmail to="@EMAILTO" from="@EMAILFROM" subject="IPN INVALID ORDER" type="html">#out#</cfmail>
		<cfheader statuscode="403" statustext="OK"/>
		<cfexit>
	</cfif>

	
	<!--- 3. Process the Notice --->
	<cfswitch expression="#form.NotificationType#">
		
		<!--- New Order --->
		<cfcase value="NewOrderNotification">
			<!--- Process a new order. The following code sends a dump of the valid cart to an administrator.
			This is a good place to log orders, handle inventory management, send notifications, etc.
			 ---><cfsavecontent variable="out">
				<cfdump var="#xml#">
			</cfsavecontent>
			<cfmail to="@EMAILTO" from="@EMAILFROM" subject="New Checkout by Amazon Order" type="html">#out#</cfmail>
		</cfcase>
		
		<!--- Ready to Ship --->
		<cfcase value="OrderReadyToShipNotification">
			<!--- 
			Process orders that are ready to ship.
			
			<cfsavecontent variable="out">
				<cfdump var="#xml#">
			</cfsavecontent>
			<cfmail to="@EMAILTO" from="@EMAILFROM" subject="Checkout by Amazon Order Read to Ship!" type="html">#out#</cfmail>
			--->		
		</cfcase>
		
		<!--- Cancelled Order --->
		<cfcase value="OrderCancelledNotification">
			<!--- Process a cancellation
			<cfsavecontent variable="out">
				<cfdump var="#xml#">
			</cfsavecontent>
			<cfmail to="@EMAILTO" from="@EMAILFROM" subject="Checkout by Amazon Order CANCELLED" type="html">#out#</cfmail> --->
		</cfcase>
	</cfswitch>
	
	<!--- 4. Respond to Amazon --->
	<!--- ColdFusion responds with a 200 OK by default --->
	
	<!--- Processing any errors --->
	<cfcatch type="any">
		
		<!--- Notify an administrator of the error/s --->
		<cfsavecontent variable="out">
			<cfdump var="#cfcatch#">
		</cfsavecontent>
		<cfmail to="@EMAILTO" from="@EMAILFROM" subject="IPN ERROR" type="html">#out#</cfmail>
		
		<!--- Respond to Amazon so the notice will be retried later --->
		<cfheader statuscode="500"/>
		
	</cfcatch>
</cftry>