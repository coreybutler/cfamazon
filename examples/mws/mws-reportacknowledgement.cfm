<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Acknowlege Report</div>
<fieldset class="result">
	<legend>Results</legend>
	<cfif StructKeyExists(url,"id")>
		<cfset form.id = url.id/>
		<cfset form.ack = "true"/>
	</cfif>
	<cfif isdefined("form.fieldnames")>
		<cfdump var="#m.updateReportAcknowledgements(form.id,form.ack)#"/>
	<cfelse>
		Please provide a report ID to generate a live results.
	</cfif>
</fieldset>
<fieldset class="howto">
	<legend>How To</legend>
	<form action="<cfoutput>#CGI.PATH_INFO#</cfoutput>" method="post">
		<b>Report ID:</b><input type="text" name="id" size="20"/><br/>
		Acknowledged: <input type="radio" name="ack" id="ack1" value="true" checked="true"/><label for="ack1">Yes</label>
		<input type="radio" name="ack" value="false" id="ack2"/><label for="ack2">No</label>
		<input type="submit" value="Submit"/>
	</form>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="#m.updateReportAcknowledgements('<i>&lt;id&gt;</i>',true)#"/&gt;
	</div>
</fieldset>
<hr class="break"/>