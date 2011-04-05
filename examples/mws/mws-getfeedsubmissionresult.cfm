<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Feed Submissions &amp; Reports</div>
<cfscript>
	x = m.getFeedSubmissionResult(url.id);
</cfscript>

<fieldset class="result">
	<legend>Results</legend>
	<cfoutput>
		<b>Feed ID:</b> #url.id#<br/>
		<b>Message ID:</b> #x.MessageId#<br/>
		<b>MessageType:</b> #x.MessageType#<br/>
	</cfoutput>
	<cfdump var="#x.ProcessingReport#"/>
</fieldset>

<fieldset class="howto">
	<legend>How To</legend>
	<cfoutput>
	<b>#m.mwsrequest.method# Request:</b><br/>
	<dd><pre>#replace(m.mwsrequest.uri,"&","<br/>&","ALL")#</pre></dd>
	</cfoutput>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="#m.getFeedSubmissionResult(<i>'<cfoutput>#url.id#</cfoutput>'</i>)#"/&gt;
	</div>
</fieldset>