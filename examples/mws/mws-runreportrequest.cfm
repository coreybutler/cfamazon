<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Report Request <i>Results</i></div>
<fieldset class="result">
	<legend>Request Report</legend>
	<cfdump var="#m.requestReport(form.type)#" label="#form.type# Results">
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="#m.requestReport(<i>'<span id="reporttype"><cfoutput>#ucase(form.type)#</cfoutput></span>'</i>)#"/&gt;
	</div>
</fieldset>