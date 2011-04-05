<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Submit Feed</div>
<cfsavecontent variable="feedXML"><?xml version="1.0" encoding="iso-8859-1" ?>
<AmazonEnvelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="amzn-envelope.xsd">
	<Header>
		<DocumentVersion>1.01</DocumentVersion>
		<MerchantIdentifier>#m.merchantId#</MerchantIdentifier>
	</Header>
	<MessageType>Price</MessageType>
	<Message>
		<MessageID>1</MessageID>
		<Price>
			<SKU>SKU12345</SKU>
			<StandardPrice currency="USD">#NumberFormat('13.00', "_.__")#</StandardPrice>
		</Price>
	</Message>
</AmazonEnvelope></cfsavecontent>

<fieldset class="result">
	<legend>Results</legend>
<cfdump var="#m.submitFeed(feedXML,'_POST_PRODUCT_PRICING_DATA_')#" label="SubmitFeed Results"/>
</fieldset>

<fieldset class="howto">
	<legend>How To</legend>
	<cfoutput>
	<b>#m.mwsrequest.method# Request:</b><br/>
	<dd><pre>#replace(m.mwsrequest.uri,"&","<br/>&","ALL")#</pre></dd>
	</cfoutput>
	<br/><br/>
	<b>BODY (XML File)</b><br/>
	<dd><pre><cfoutput>#HTMLEditFormat(feedXML)#</cfoutput></pre></dd>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="#m.submitFeed(feedXML,'_POST_PRODUCT_PRICING_DATA_')#"/&gt;
	</div>
</fieldset>