<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS List Orders</div>
<fieldset class="result">
	<legend>Results</legend>
	<cfscript>
		m.setCreatedAfter(dateadd('d',-30,now()));
		m.setOrderStatus("Shipped,Canceled");
	</cfscript>
	<cfdump var="#m.listorders()#"/>
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<cfoutput>
	<b>#m.mwsrequest.method# Request:</b><br/>
	<dd><pre>#replace(m.mwsrequest.uri,"&","<br/>&","ALL")#</pre></dd>
	</cfoutput>
	<br/><br/>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="#m.listorders()#"/&gt;
	</div>
</fieldset>