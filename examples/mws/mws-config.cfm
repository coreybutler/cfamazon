<cfscript>
	merchantId='@MERCHANT';
	awsAccessId='@AWSID'; //Initialize with AWS Access Key (Not CBA Access Key!)
	awsSecret='@MWSSECRET';
	marketId='@MARKETPLACEID';
	
	//Create Marketplace Object
	m = createObject("component","com.amazon.mws.marketplace");
	m.init(awsAccessId,awsSecret,merchantId,marketId);
</cfscript>





<!--- The remainder of code on this page is purely for formatting easily readable examples --->
<style>
	.alert {border:2px solid gold;background:maroon;color:#ffffff;padding:8px;font-size:smalllfont-weight:bold;}
	.code {
		padding: 6px;
		border: 1px dashed navy;
		font-family:Courier,Serif;
		background:#ffffcc;
		margin:12px 0px 12px 0px;
	}
	.code h3 {margin:0px 0px 6px 0px;}
	.result,.howto {float:right;margin:5px;padding:12px;border:1px solid #dddddd;width:42%;display:table-cell;}
	legend {font-weight:bold;font-size:large;}
	.staticscroll{overflow:scroll;}
	.nav {
		padding:12px;
		margin:6px;
		background:navy;
		color:#ffffff;
		border:1px solid #666;
		font-family:Arial;
		font-weight:bold;
		-moz-border-radius: 8px;
		-webkit-border-radius: 8px;
		border-radius: 8px;
	}
	.nav a {text-decoration:none;color:#eeeeee;margin-right:22px;}
	.nav a:hover {text-decoration:underline; color:#ffffff;}
	.subtitle {
		margin: 0px 0px 25px 30px;
		background:#336699;
		border:1px solid navy;
		padding:4px;
		color:#ffffff;
		width:25%;
		font-size:larger;
		-moz-border-radius: 8px;
		-webkit-border-radius: 8px;
		border-radius: 8px;
		font-family:Arial;
		text-shadow:-1px -1px #555;
	}
	.break {
		height:0px;
		width:0px;
		clear:both;
		margin:12px 0px 12px 0px;
		border:1px solid red;
	}
</style>

<cffunction name="includeconfig">
	<cfset var out = ""/>
<cfsavecontent variable="out"><pre>&lt;script&gt;
	merchantId='@MERCHANT';
	awsAccessId='@AWSID'; //Initialize with AWS Access Key (Not CBA Access Key!)
	awsSecret='@MWSSECRET';
	marketId='@MARKETPLACEID';

	//Create Marketplace Object
	m = createObject("component","com.amazon.mws.marketplace");
	m.init(awsAccessId,awsSecret,merchantId,marketId);
&lt;/script&gt;</pre></cfsavecontent>
	<cfreturn out/>
</cffunction>

<cffunction name="dump">
	<cfargument name="x">
	<cfdump var="#arguments.x#">
</cffunction>
<div class="nav">
	<a href="./index.cfm">Home</a>
	<!--- <a href="./examples/mws/mws-submitfeed.cfm">SubmitFeed</a>
	<a href="./examples/mws/mws-getfeedsubmissionlist.cfm">GetFeedSubmission...</a>
	<a href="./examples/mws/mws-reportrequest.cfm">Reports</a> --->
</div>