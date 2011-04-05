<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Feeds <i>(All)</i></div>
<cfscript>
	obj = m.getFeedSubmissionList();
	list= obj.FeedSubmissions;
	i=0;
	/*while(obj.hasNext and i lte 2){
		i=i+1;
		obj = m.getFeedSubmissionListByNextToken(obj.nextToken);
		StructAppend(list,obj.FeedSubmissions);
	}*/
	obj = m.getFeedSubmissionListByNextToken(obj.nextToken);
</cfscript>
<!--- <cfdump var="#list#"> --->
<cfdump var="#obj#"><cfabort>
<fieldset class="result">
	<legend>Results</legend>
	<cfset x = StructKeyArray(list)/>
	<cfloop from="1" to="#arraylen(x)#" step="1" index="i">
		<cfoutput>#x[i]#: #x[i].FeedType# (#x[i].FeedProcessingStatus#)</cfoutput>
	</cfloop>
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
<pre>&lt;cfscript&gt;
	obj = m.getFeedSubmissionList();
	list= obj.FeedSubmissions;
	
	while(obj.hasNext){
		obj = m.getFeedSubmissionListByNextToken(obj.NextToken);
		StructAppend(list,obj.FeedSubmissions);
	}
&lt;/cfscript&gt;</pre>
	</div>
</fieldset>