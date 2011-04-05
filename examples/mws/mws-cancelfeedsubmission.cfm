<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Feed Submission Cancellation</div>
<cfscript>
	x = m.cancelFeedSubmissions(url.id);
</cfscript>

<fieldset class="result">
	<legend>Results</legend>
	<cfoutput>
		<b>Feed ID:</b> #url.id#<br/>
		<b>Total Feeds Removed:</b> #x.Count#<br/>
	</cfoutput>
	<cfdump var="#x.FeedSubmissionInfo#"/>
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
		&lt;cfdump var="#m.cancelFeedSubmissions(<i>'<cfoutput>#url.id#</cfoutput>'</i>)#"/&gt;
	</div>
</fieldset>