<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Report (<cfoutput>#url.id#</cfoutput>)</div>
<cfdump var="#m.getReport(url.id)#"/>