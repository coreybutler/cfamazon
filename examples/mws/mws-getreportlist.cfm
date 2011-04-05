<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Report <i>Count</i></div>
<cfset count = m.getReportCount('_GET_FLAT_FILE_OPEN_LISTINGS_DATA_')/>
<fieldset class="result">
	<legend>Results</legend>
	<b>Total Reports: </b><cfoutput>#count#</cfoutput>
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
		&lt;cfdump var="#m.getReportCount('_GET_FLAT_FILE_OPEN_LISTINGS_DATA_')#"/&gt;
	</div>
</fieldset>
<hr class="break"/>

<div class="subtitle">Viewing: MWS Report <i>List</i></div>
<fieldset class="result">
	<legend>Report Results</legend>
	<cfset x = m.getReportList('_GET_FLAT_FILE_OPEN_LISTINGS_DATA_')/>
	<cfif not StructKeyExists(x,"ReportInfo")>
		No report requests (identified by missing ReportInfo key).<br/>
		Note that Feed Summary Reports may be included (which are not reflected in the count).<br/><br/>
	</cfif>
	<cfif StructKeyExists(x,"ReportRequestInfo")>
		<cfset l = StructKeyArray(x.ReportRequestInfo)/>
		<cfloop from="1" to="#arraylen(l)#" step="1" index="i">
			<cfoutput>
				<b>#l[i]#:</b> <a href="./mws-getreport.cfm?id=#l[i]#">View</a> | <a href="./mws-reportacknowledgement.cfm?id=#l[i]#">Acknowledge</a>
				<cfdump var="#x.ReportRequestInfo[l[i]]#">
			</cfoutput>
			<br/><br/>
		</cfloop>
	<cfelse>
		<cfdump var="#x#">
	</cfif>
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="#m.getReportList('_GET_FLAT_FILE_OPEN_LISTINGS_DATA_')#"/&gt;
	</div>
</fieldset>