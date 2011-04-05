<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: Report Request</div>
<fieldset class="result">
	<legend>Request Report</legend>
	Due to the limited number of requests, live example report requests should only be generated as needed.<br/>
	<form action="./mws-runreportrequest.cfm" method="post">
		<select name="type" onchange="document.getElementById('reporttype').innerHTML=this.options[this.selectedIndex].value;document.getElementById('reportdsc').innerHTML=this.options[this.selectedIndex].text;">
			<cfset x = StructKeyArray(m.enum.ReportType)/>
			<cfloop from="1" to="#arraylen(x)#" step="1" index="i">
			<cfoutput><option value="#x[i]#"<cfif x[i] is "_GET_ORDERS_DATA_"> selected="true"</cfif>>#m.enum.ReportType[x[i]]#</option></cfoutput>
			</cfloop>
		</select>
		<input type="submit" value="Run"/>
	</form>
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;--- <span id="reportdsc">Scheduled XML Order Report</span> ---&gt;<br/>
		&lt;cfdump var="#m.requestReport(<i>'<span id="reporttype">_GET_ORDERS_DATA_</span>'</i>)#"/&gt;
	</div>
	There are several types of reports:
	<cfdump var="#m.enum.ReportType#" label="Report Types">
</fieldset>