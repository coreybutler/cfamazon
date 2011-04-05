<cfcomponent hint="Common Amazon Payment Methods" output="false">

	<cfproperty name="accessKeyID" hint="Your Checkout by Amazon Access Key ID" type="string" />
	<cfproperty name="secretKeyID" hint="Your Checkout by Amazon Secret Access Key" type="string" />
	<cfproperty name="merchantID" hint="Your Merchant ID" type="string" />

	<cffunction name="init" hint="Shortcut method for initializing Amazon Payments.">
		<cfargument name="accessKeyID" type="string" required="true" hint="Your Checkout by Amazon Access Key ID"/>
		<cfargument name="secretKeyID" type="string" required="true" hint="Your Checkout by Amazon Secret Access Key"/>
		<cfargument name="merchantID" type="string" required="true" hint="Your Merchant ID"/>
		<cfargument name="sandbox" type="boolean" required="false" hint="True if using the sandbox environment." default="false"/>
		<cfscript>
			setAccessKeyID(arguments.accessKeyID);
			setSecretKeyID(arguments.secretKeyID);
			setMerchantID(arguments.merchantID);
			
			//Select the approriate website for processing payments.
			this.sandbox = arguments.sandbox;
			if (arguments.sandbox)
				this.actionBaseUrl = "https://payments-sandbox.amazon.com";
			else
				this.actionBaseUrl = "https://payments.amazon.com";
			this.actionpage = this.actionBaseUrl & "/checkout/";
			
			//XMLNS
			this.xmlns = StructNew();
			this.xmlns.default = "http://payments.amazon.com/checkout/2009-05-15/";
			this.xmlns.callback = "Checkout by Amazon Shopping Cart";
			
			//XSD
			this.xsd = StructNew();
			this.xsd.order = "http://amazonservices.s3.amazonaws.com/Payments/documents/order.xsd";
			this.xsd.callback = "http://amazonservices.s3.amazonaws.com/Payments/documents/callback.xsd";
			this.xsd.iopn = "http://amazonservices.s3.amazonaws.com/Payments/documents/iopn.xsd";
		</cfscript>
	</cffunction>

	<cffunction name="sign" hint="Sign an object. This is most commonly used to sign the cart." access="public" output="false" returntype="String">
		<cfargument name="data" type="String" required="true" hint="The data to sign."/>
		<cfargument name="key" type="String" required="true" hint="The key used to sign data."/>
		<cfargument name="hashType" type="String" required="false" default="HmacSHA1" hint="The hash algorithm used to sign data."/>
		<cfscript>
			var sformat = "UTF-8";
		    var ekey 	= createObject("java","javax.crypto.spec.SecretKeySpec");
		    var secret 	= ekey.Init(arguments.key.getBytes(sformat),arguments.hashType);
		    var mac 	= createObject("java","javax.crypto.Mac");    
		    
		    //Initialize the MAC
		    mac = mac.getInstance(ekey.getAlgorithm());
		    mac.init(secret);
		    
		    return toBase64(mac.doFinal(arguments.data.getBytes(sformat)));
		</cfscript>
		<!--- <cfargument name="signKey" type="string" required="true" /> 
		<cfargument name="signMessage" type="string" required="true" /> 
		
		<cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") /> 
		<cfset var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") /> 
		
		<cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") /> 
		<cfset var mac = createObject("java","javax.crypto.Mac") /> 
		
		<cfset key = key.init(jKey,"HmacSHA256") /> 
		
		<cfset mac = mac.getInstance(key.getAlgorithm()) /> 
		<cfset mac.init(key) /> 
		<cfset mac.update(jMsg) /> 
		
		<cfreturn toBase64(mac.doFinal()) />  --->
	</cffunction>

	<cffunction name="md5" hint="Compute an MD5 hash." access="public" output="false" returnType="string">
		<cfargument name="content" type="any" hint="The content to hash."/>
		<cfreturn toBase64(BinaryDecode(Hash(arguments.content),'hex'))/>
	</cffunction>

	<cffunction name="getAccessKeyID" access="public" output="false" returntype="string">
		<cfreturn this.accessKeyID />
	</cffunction>

	<cffunction name="setAccessKeyID" access="public" output="false" returntype="void">
		<cfargument name="accessKeyID" type="string" required="true" />
		<cfset this.accessKeyID = arguments.accessKeyID />
		<cfreturn />
	</cffunction>

	<cffunction name="getSecretKeyID" access="public" output="false" returntype="string">
		<cfreturn this.secretKeyID />
	</cffunction>

	<cffunction name="setSecretKeyID" access="public" output="false" returntype="void">
		<cfargument name="secretKeyID" type="string" required="true" />
		<cfset this.secretKeyID = arguments.secretKeyID />
		<cfreturn />
	</cffunction>

	<cffunction name="getMerchantID" access="public" output="false" returntype="string">
		<cfreturn this.merchantID />
	</cffunction>

	<cffunction name="setMerchantID" access="public" output="false" returntype="void">
		<cfargument name="merchantID" type="string" required="true" />
		<cfset this.merchantID = arguments.merchantID />
		<cfreturn />
	</cffunction>
	
	<cffunction name="getOrderXsd" access="private" output="false" returntype="string" hint="Get the Order.xsd URL. This is commonly used for XMLNS.">
		<cfreturn this.xsd.base&this.xsd.order/>
	</cffunction>
	
	<cffunction name="getCallbackXsd" access="private" output="false" returntype="string" hint="Get the Order.xsd URL. This is commonly used for XMLNS.">
		<cfreturn this.xsd.base&this.xsd.callback/>
	</cffunction>
		
	<cffunction name="setOrderXsd" access="private" output="false" returntype="string" hint="Get the Order.xsd URL. This is commonly used for XMLNS.">
		<cfargument name="xsd" type="string" required="true" />
		<cfset this.xsd.order=arguments.xsd/>
	</cffunction>
	
	<cffunction name="setCallbackXsd" access="private" output="false" returntype="string" hint="Get the Order.xsd URL. This is commonly used for XMLNS.">
		<cfargument name="xsd" type="string" required="true" />
		<cfset this.xsd.callback=arguments.xsd/>
	</cffunction>
	
	<cffunction name="verifyRequestIsFromAmazon" access="public" output="false" returntype="Boolean" hint="Returns true if the request can be verified as coming from Amazon.">
		<cfargument name="uuid" type="string" required="false" hint="The UUID value from the IPN notice."/>
		<cfargument name="timestamp" type="string" required="false" hint="The Timestamp value from the IPN notice."/>
		<cfargument name="signature" type="string" required="false" hint="The Signature value from the IPN notice."/>
		<cfscript>
			//If operating in production and no signature is available, verification will fail.
			if (not StructKeyExists(arguments,"signature") and not StructKeyExists(form,"Signature") and not this.sandbox)
				return false;
				
			//Populate the variables from the URL scope if they aren't defined manually
			if (not StructKeyExists(arguments,"uuid"))
				arguments.uuid = urldecode(form.UUID);
			if (not StructKeyExists(arguments,"timestamp"))
				arguments.timestamp = urldecode(form.Timestamp);
			if (not StructKeyExists(arguments,"signature"))
				arguments.signature = form.Signature;
			
			//If the object is not initialized
			if (not StructKeyExists(this,"accessKeyID"))
				throwError("Failed Initialization","The factory object must be initialized to use the verifyRequestFromAmazon method.");
			
			//If a variable doesn't exist, throw an error
			if(not StructKeyExists(arguments,"uuid") or not StructKeyExists(arguments,"timestamp") or not StructKeyExists(arguments,"signature"))
				return false;
			
			//Verify the timestamp is within 15 minutes of the local server system clock
			//Amazon recommends using a NIST clock (http://www.time.gov/) to prevent dropping valid requests
			if(abs(DateDiff('n',GetHttpTimeString(now()),ParseDateTime(replace(listfirst(arguments.timestamp,"."),"T"," ","ONE")))) gt 15)
				return false;
			
			//Compare the signatures and return true/false based on whether they match.
			return trim(sign(arguments.UUID&arguments.Timestamp,this.secretKeyID)) is trim(arguments.signature);
		</cfscript>
	</cffunction>
	
	<cffunction name="getSignatureMatch" access="public" output="false" returntype="struct" hint="A helper method to display the received and generated signatures.">
		<cfargument name="uuid" type="string" required="true" hint="The UUID value from the IPN notice."/>
		<cfargument name="timestamp" type="string" required="true" hint="The Timestamp value from the IPN notice."/>
		<cfargument name="signature" type="string" required="true" hint="The Signature value from the IPN notice."/>
		<cfscript>
			var match = StructNew();
			
			//If the object is not initialized
			if (not StructKeyExists(this,"accessKeyID"))
				throwError("Failed Initialization","The factory object must be initialized to use the getSignatureMatch method.");
			
			match.timeDifference = abs(DateDiff('n',GetHttpTimeString(now()),ParseDateTime(replace(listfirst(arguments.timestamp,"."),"T"," ","ONE"))));
			match.request = arguments.signature;
			match.response = sign(arguments.UUID&arguments.Timestamp,this.secretKeyID);
			
			return match;
		</cfscript>
	</cffunction>
	
	<cffunction name="throwError" access="package" output="true" hint="A wrapper method for ColdFusion error output (supports some older versions of CF).">
		<cfargument name="message" type="string" required="false" default="Unknown Error."/>
		<cfargument name="detail" type="string" required="false" default="Unknown Detail."/>
		<cfargument name="extended" type="string" required="false" default=""/>
		<cfargument name="errorCode" type="string" required="false" default="">
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" errorCode="#arguments.errorCode#" extendedInfo="#arguments.extended#"/>
	</cffunction>
	
</cfcomponent>