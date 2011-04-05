<cfinclude template="mws-config.cfm"/>
<div class="subtitle">Viewing: MWS Feed Submission <i>Count</i></div>
<cfset count = m.getFeedSubmissionCount()/>
<fieldset class="result">
	<legend>Results</legend>
	<b>Total Feed Submissions: </b><cfoutput>#count#</cfoutput>
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
		&lt;cfdump var="#m.getFeedSubmissionCount()#"/&gt;
	</div>
</fieldset>
<hr class="break"/>


<cfset x = m.getFeedSubmissionList()/>
<div class="subtitle">Viewing: MWS Feed <i>Submissions &amp; Reports</i></div>
<fieldset class="result">
	<legend>Results</legend>
	<cfoutput>
		<b>Request ID:</b> #x.RequestId#<br/>
		<b>HasNext:</b> #x.hasNext#<br/>
		<cfif x.hasNext>
		<b>Next Token:</b> <div class="staticscroll" style="width:350px;overflow:scroll !important;border:1px dashed 999999;font-size:medium;">#x.nextToken#</div><br/><br/>
		</cfif>
	</cfoutput>
	<cfscript>
		
		//dump(x);
		a = StructKeyArray(x.FeedSubmissions);
		for (i=1; i lte arraylen(a); i=i+1){
			if(i gt 1)
				writeoutput("<br/><br/>");
			writeoutput("<a href=""./mws-getfeedsubmissionresult.cfm?id="&a[i]&""">Vew Report</a> | <a href=""./mws-cancelfeedsubmission.cfm?id="&a[i]&""">Cancel Request</a><br/>");
			dump(x.FeedSubmissions[a[i]]);
		}
	</cfscript>
</fieldset>

<fieldset class="howto">
	<legend>How To</legend>
	<cfoutput>
	<b>#m.mwsrequest.method# Request:</b><br/>
	<dd><pre>#replace(m.mwsrequest.uri,"&","<br/>&","ALL")#</pre></dd>
	</cfoutput>
	<br/><br/>
	<b>BODY (XML File)</b><br/>
	<dd><pre>NONE</pre></dd>
	<div class="code">
		<h3>Code:</h3>
		<cfoutput>#includeconfig()#</cfoutput>
		&lt;cfdump var="#m.getFeedSubmissionList()#"/&gt;
	</div>
</fieldset>