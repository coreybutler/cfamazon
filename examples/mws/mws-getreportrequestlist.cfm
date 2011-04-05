<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Report Request <i>Count</i></div>
<cfset count = m.getReportRequestCount()/>
<fieldset class="result">
	<legend>Results</legend>
	<b>Total Report Requests: </b><cfoutput>#count#</cfoutput>
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
		&lt;cfdump var="#m.getReportRequestCount()#"/&gt;
	</div>
</fieldset>
<hr class="break"/>

<div class="subtitle">Viewing: MWS Report Request <i>List</i></div>
<fieldset class="result">
	<legend>Results</legend>
	<cfset x = m.getReportRequestList()/>
	<cfdump var="#x#">
	<cfif not StructKeyExists(x,"ReportRequestInfo")>
		No report requests (identified by missing ReportRequestInfo key).
	</cfif>
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="#m.getReportRequestList()#"/&gt;
	</div>
</fieldset>