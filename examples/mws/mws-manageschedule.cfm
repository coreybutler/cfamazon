<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Update Report Schedule</div>
<fieldset class="result">
	<legend>Results</legend>
	<cfset x = m.manageReportSchedule('_GET_ORDERS_DATA_','_30_DAYS_')/>
	<cfdump var="#x#">
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="# m.manageReportSchedule('_GET_ORDERS_DATA_','_30_DAYS_')#"/&gt;
	</div>
</fieldset>