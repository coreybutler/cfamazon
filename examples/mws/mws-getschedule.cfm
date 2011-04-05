<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Get Report Schedule Count</div>
<fieldset class="result">
	<legend>Results</legend>
	<b>Count: </b><cfoutput>#m.getReportScheduleCount('_GET_ORDERS_DATA_,_GET_MERCHANT_LISTINGS_DATA_')#</cfoutput>
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="# m.getReportScheduleCount('_GET_ORDERS_DATA_,_GET_MERCHANT_LISTINGS_DATA_')#"/&gt;
	</div>
</fieldset>
<hr class="break"/>

<div class="subtitle">Viewing: MWS Get Report Schedules</div>
<fieldset class="result">
	<legend>Results</legend>
	<cfset x = m.getReportScheduleList('_GET_ORDERS_DATA_,_GET_MERCHANT_LISTINGS_DATA_')/>
	<cfdump var="#x#">
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="# m.getReportScheduleList('_GET_ORDERS_DATA_,_GET_MERCHANT_LISTINGS_DATA_')#"/&gt;
	</div>
</fieldset>