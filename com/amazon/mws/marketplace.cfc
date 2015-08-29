<cfcomponent hint="Merchant Web Service Methods" extends="com.amazon.factory" output="false">

	<!--- Basic object properties --->
	<cfproperty name="baseurl" hint="The base URL used to construct requests." type="string" />
	<cfproperty name="signaturemethod" hint="Which HMAC hash algorithm is being used to calculate your signature, either SHA256 or SHA1." type="string" default="SHA1" />
	<cfproperty name="merchantid" hint="Merchant ID" type="string" />
	<cfproperty name="marketplaceid" hint="Marketplace ID" type="string" />
	<cfproperty name="useragent" type="string" default="My Company/1.0 (Language=ColdFusion; Library=CFAmazon)" />
	<cfproperty name="enum" type="struct" hint="Enumeration of different types."/>


	
	<!--- Initialize the object --->
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="accessKeyID" type="string" required="true" hint="Your Checkout by Amazon Access Key ID"/>
		<cfargument name="secretKeyID" type="string" required="true" hint="Your Checkout by Amazon Secret Access Key"/>
		<cfargument name="merchantID" type="string" required="true" hint="Your Merchant ID"/>
		<cfargument name="marketplaceID" type="string" required="true" hint="Your Marketplace ID"/>
		<cfargument name="location" type="string" required="false" default="US" hint="US,UK,Germany,France,Japan,China,Canada"/>
		<cfscript>
			//Populate default properties
			this.baseurl 			= "https://mws.amazonservices.com";
			this.useragent 			= "My Company/1.0 (Language=ColdFusion; Library=CFAmazon; Host="&CGI.SERVER_NAME&")";
			this.signaturemethod	="HmacSHA256";
			this.signatureversion	=2;
			this.version			="2009-01-01";
			this.showXmlResponse 	= false;
			this.debug 				= false;
				
			//Enumerations
			this.enum = StructNew();
			this.enum.FeedType = StructNew();
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_DATA_','Product Feed');
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_RELATIONSHIP_DATA_','Relationships Feed');
			StructInsert(this.enum.FeedType,'_POST_ITEM_DATA_','Single Format Item Feed');
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_OVERRIDES_DATA_','Shipping Override Feed');
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_IMAGE_DATA_','Product Images Feed');
			StructInsert(this.enum.FeedType,'_POST_PRODUCT_PRICING_DATA_','Pricing Feed');
			StructInsert(this.enum.FeedType,'_POST_INVENTORY_AVAILABILITY_DATA_','Inventory Feed');
			StructInsert(this.enum.FeedType,'_POST_ORDER_ACKNOWLEDGEMENT_DATA_','Order Acknowledgement Feed');
			StructInsert(this.enum.FeedType,'_POST_ORDER_FULFILLMENT_DATA_','Order Fulfillment Feed');
			StructInsert(this.enum.FeedType,'_POST_FULFILLMENT_ORDER_REQUEST_DATA_','FBA Shipment Injection Fulfillment Feed');
			StructInsert(this.enum.FeedType,'_POST_FULFILLMENT_ORDER_CANCELLATION_REQUEST_DATA_','FBA Shipment Injection Cancellation Feed');
			StructInsert(this.enum.FeedType,'_POST_PAYMENT_ADJUSTMENT_DATA_','Order Adjustment Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_LISTINGS_DATA_','Flat File Listings Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_ORDER_ACKNOWLEDGEMENT_DATA_','Flat File Order Acknowledgement Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_FULFILLMENT_DATA_','Flat File Order Fulfillment Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_PAYMENT_ADJUSTMENT_DATA_','Flat File Order Adjustment Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_INVLOADER_DATA_','Flat File Inventory Loader Feed');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_CONVERGENCE_LISTINGS_DATA_','Flat File Music Loader File');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_BOOKLOADER_DATA_','Flat File Book Loader File');
			StructInsert(this.enum.FeedType,'_POST_FLAT_FILE_PRICEANDQUANTITYONLY_UPDATE_DATA_','Flat File Price and Quantity Update File');
			StructInsert(this.enum.FeedType,'_POST_UIEE_BOOKLOADER_DATA_','UIEE Inventory File');
			
			this.enum.Schedule = StructNew();
			StructInsert(this.enum.Schedule,'_15_MINUTES_','Every 15 minutes');
			StructInsert(this.enum.Schedule,'_30_MINUTES_','Every 30 minutes');
			StructInsert(this.enum.Schedule,'_1_HOUR_','Every hour');
			StructInsert(this.enum.Schedule,'_2_HOURS_','Every 2 hours');
			StructInsert(this.enum.Schedule,'_4_HOURS_','Every 4 hours');
			StructInsert(this.enum.Schedule,'_8_HOURS_','Every 8 hours');
			StructInsert(this.enum.Schedule,'_12_HOURS_','Every 12 hours');
			StructInsert(this.enum.Schedule,'_1_DAY_','Every day');
			StructInsert(this.enum.Schedule,'_2_DAYS_','Every 2 days');
			StructInsert(this.enum.Schedule,'_72_HOURS_','Every 3 days');
			StructInsert(this.enum.Schedule,'_7_DAYS_','Every 7 days');
			StructInsert(this.enum.Schedule,'_14_DAYS_','Every 14 days');
			StructInsert(this.enum.Schedule,'_15_DAYS_','Every 15 days');
			StructInsert(this.enum.Schedule,'_30_DAYS_','Every 30 days');
			StructInsert(this.enum.Schedule,'_NEVER_','Delete a previously created report schedule');
			
			this.enum.Error = StructNew();
			StructInsert(this.enum.Error,'AccessDenied','Client tried connecting to MWS through HTTP rather than HTTPS.');
			StructInsert(this.enum.Error,'AccessToFeedProcessingResultDenied','Insufficient privileges to access the feed processing result.');
			StructInsert(this.enum.Error,'AccessToReportDenied','Insufficient privileges to access the requested report.');
			StructInsert(this.enum.Error,'ContentMD5Missing','The Content-MD5 header value was missing.');
			StructInsert(this.enum.Error,'ContentMD5DoesNotMatch','The calculated MD5 hash value doesn�t match the provided Content-MD5 value.');
			StructInsert(this.enum.Error,'FeedCanceled','Returned for a request for a processing report of a canceled feed.');
			StructInsert(this.enum.Error,'FeedProcessingResultNoLongerAvailable','The feed processing result is no longer available for download.');
			StructInsert(this.enum.Error,'FeedProcessingResultNotReady','Processing report not yet generated.');
			StructInsert(this.enum.Error,'InputDataError','Feed content contained errors.');
			StructInsert(this.enum.Error,'InternalError','Unspecified server error occurred.');
			StructInsert(this.enum.Error,'InvalidFeedSubmissionId','Provided Feed Submission Id was invalid.');
			StructInsert(this.enum.Error,'InvalidAction','The action was invalid.');
			StructInsert(this.enum.Error,'InvalidFeedType','Submitted Feed Type was invalid.');
			StructInsert(this.enum.Error,'InvalidParameterValue','Provided query parameter was invalid. For example, the format of the Timestamp parameter was malformed.');
			StructInsert(this.enum.Error,'InvalidQueryParameter','Superfluous parameter submitted.');
			StructInsert(this.enum.Error,'InvalidReportId','Provided Report Id was invalid.');
			StructInsert(this.enum.Error,'InvalidReportType','Submitted Report Type was invalid.');
			StructInsert(this.enum.Error,'InvalidRequest','The request was invalid.');
			StructInsert(this.enum.Error,'InvalidScheduleFrequency','Submitted schedule frequency was invalid.');
			StructInsert(this.enum.Error,'MissingClientTokenId','Either the Merchant Id or Marketplace Id parameter was empty or missing.');
			StructInsert(this.enum.Error,'MissingParameter','Required parameter was missing from the query.');
			StructInsert(this.enum.Error,'ReportNoLongerAvailable','The specified report is no longer available for download.');
			StructInsert(this.enum.Error,'ReportNotReady','Report not yet generated.');
			StructInsert(this.enum.Error,'SignatureDoesNotMatch','The provided request signature does not match the server''s calculated signature value.');
			StructInsert(this.enum.Error,'UserAgentHeaderLanguageAttributeMissing','The User-Agent header Language attribute was missing.');
			StructInsert(this.enum.Error,'UserAgentHeaderMalformed','The User-Agent value did not comply with the expected format. See the topic, User-Agent Header.');
			StructInsert(this.enum.Error,'UserAgentHeaderMaximumLengthExceeded','The User-Agent value exceeded 500 characters.');
			StructInsert(this.enum.Error,'UserAgentHeaderMissing','The User-Agent header value was missing.');
			
			this.enum.ReportType = StructNew();	
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_OPEN_LISTINGS_DATA_','Open Listings Report');
			StructInsert(this.enum.ReportType,'_GET_MERCHANT_LISTINGS_DATA_','Merchant Listings Report');
			StructInsert(this.enum.ReportType,'_GET_MERCHANT_LISTINGS_DATA_LITE_','Merchant Listings Lite Report');
			StructInsert(this.enum.ReportType,'_GET_MERCHANT_LISTINGS_DATA_LITER_','Merchant Listings Liter Report');
			StructInsert(this.enum.ReportType,'_GET_MERCHANT_CANCELLED_LISTINGS_DATA_','Canceled Listings Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ACTIONABLE_ORDER_DATA_','Unshipped Orders Report');
			StructInsert(this.enum.ReportType,'_GET_ORDERS_DATA_','Scheduled XML Order Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ORDER_REPORT_DATA_','Scheduled Flat File Order Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ORDERS_DATA_','Flat File Order Report');
			StructInsert(this.enum.ReportType,'_GET_CONVERGED_FLAT_FILE_ORDER_REPORT_DATA_','Flat File Order Report');
			StructInsert(this.enum.ReportType,'_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_','Flat File Settlement Report');
			StructInsert(this.enum.ReportType,'_GET_V2_SETTLEMENT_REPORT_DATA_XML_','XML Settlement Report');
			StructInsert(this.enum.ReportType,'_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_','Flat File V2 Settlement Report');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ALL_ORDERS _DATA_BY_LAST_UPDATE_','Flat File All Orders Report by Last Update');
			StructInsert(this.enum.ReportType,'_GET_FLAT_FILE_ALL_ORDERS _DATA_BY_ORDER_DATE_','Flat File All Orders Report by Order Date');
			StructInsert(this.enum.ReportType,'_GET _XML_ALL_ORDERS _DATA_BY_LAST_UPDATE_','XML All Orders Report by Last Update');
			StructInsert(this.enum.ReportType,'_GET _XML_ALL_ORDERS _DATA_BY_ORDER_DATE_','XML All Orders Report by Order Date');
			StructInsert(this.enum.ReportType,'_GET_AFN_INVENTORY_DATA_','FBA Inventory Report');
			StructInsert(this.enum.ReportType,'_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_','FBA Fulfilled Shipments Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_','FBA Returns Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CUSTOMER_SHIPMENT_SALES_DATA_','FBA Customer Shipment Sales Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CUSTOMER_SHIPMENT_PROMOTION_DATA_','FBA Promotions Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CURRENT_INVENTORY_DATA_','FBA Daily Inventory History Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_MONTHLY_INVENTORY_DATA_','FBA Monthly Inventory History Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_','FBA Received Inventory Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_INVENTORY_SUMMARY_DATA_','FBA Inventory Event Detail Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_INVENTORY_ADJUSTMENTS_DATA_','FBA Inventory Adjustments Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_INVENTORY_AGE_DATA_','FBA Inventory Age Report');
			StructInsert(this.enum.ReportType,'_GET_FBA_FULFILLMENT_CUSTOMER_SHIPMENT_REPLACEMENT_DATA_','FBA Replacements Report');
			StructInsert(this.enum.ReportType,'_GET_NEMO_MERCHANT_LISTINGS_DATA_','Product Ads Listings Report');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_DAILY_DATA_TSV_','Product Ads Daily Performance by SKU Report, flat file');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_DAILY_DATA_XML_','Product Ads Daily Performance by SKU Report, XML');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_WEEKLY_DATA_TSV_','Product Ads Weekly Performance by SKU Report, flat file');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_WEEKLY_DATA_XML_','Product Ads Weekly Performance by SKU Report, XML');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_MONTHLY_DATA_TSV_','Product Ads Monthly Performance by SKU Report, flat file');
			StructInsert(this.enum.ReportType,'_GET_PADS_PRODUCT_PERFORMANCE_OVER_TIME_MONTHLY_DATA_XML_','Product Ads Monthly Performance by SKU Report, XML');
			
			this.enum.OrderStatus = StructNew();
			StructInsert(this.enum.OrderStatus,"Pending","Order has been placed but payment has not been authorized. Not ready for shipment.");
			StructInsert(this.enum.OrderStatus,"Unshipped","Payment has been authorized and order is ready for shipment, but no items in the order have been shipped.");
			StructInsert(this.enum.OrderStatus,"PartiallyShipped","One or more (but not all) items in the order have been shipped.");
			StructInsert(this.enum.OrderStatus,"Shipped","All items in the order have been shipped.");
			StructInsert(this.enum.OrderStatus,"Canceled","The order was canceled.");
			StructInsert(this.enum.OrderStatus,"Unfillable","The order cannot be fulfilled. This state applies only to Amazon-fulfilled orders that were not placed on Amazon's retail website.");
			
			this.enum.FulfillmentChannel = StructNew();
			StructInsert(this.enum.FulfillmentChannel,"AFN","Fulfilled by Amazon");
			StructInsert(this.enum.FulfillmentChannel,"MFN","Fulfilled by Seller");
			
			//Set defaults
			switch(arguments.location){
				case 'UK':
					setBaseurl("https://mws.amazonservices.co.uk");
					break;
				case 'Germany':
					setBaseurl("https://mws.amazonservices.de");
					break;
				case 'France':
					setBaseurl("https://mws.amazonservices.fr");
					break;
				case 'Japan':
					setBaseurl("https://mws.amazonservices.jp");
					break;
				case 'Canada':
					setBaseurl("https://mws.amazonservices.cn");
					break;
			}			
		
			//Invoke the parent object initialization method
			super.init(arguments.accessKeyId,arguments.secretKeyId,arguments.merchantId);
			setMarketplaceId(arguments.marketplaceID);
		</cfscript>
	</cffunction>

	

	<!--- PRIMARY API METHODS --->
	
	<!--- Feeds --->
	<cffunction name="submitFeed" hint="The SubmitFeed operation uploads a file for processing together with the necessary metadata to process the file. Returns a struct with the following keys: FeedSubmissionId, FeedType, SubmittedDate, and FeedProcessingStatus." access="public" output="false" returntype="any">
		<cfargument name="FeedContent" type="string" hint="The actual content of the feed itself, in XML or flat file format. You must include the FeedContent in the body of the HTTP request." required="true" />
		<cfargument name="FeedType" type="string" hint="The FeedType being submitted, which indicates how the data should be processed." required="true" />
		<cfscript>
			var qs 	= "Action=SubmitFeed";
			var r	= StructNew();
			var xml = "";
			var i	= 0;
			
			//Validate the feed type
			if (not StructKeyExists(this.enum.feedtype,arguments.FeedType))
				super.throwError("InvalidFeedType",this.enum.error.InvalidFeedType);
			
			//Add parameters to query string	
			qs = listappend(qs,"FeedType="&arguments.FeedType,"&");
	
			//Send resuest & parse XML response
			xml = sendRequest(getSignedURL(qs),"POST",arguments.FeedContent);
	
			//Clean the response
			for(i=1; i lte arraylen(xml.SubmitFeedResult.FeedSubmissionInfo.XmlChildren); i=i+1)
				StructInsert(r,xml.SubmitFeedResult.FeedSubmissionInfo.XmlChildren[i].XmlName,xml.SubmitFeedResult.FeedSubmissionInfo.XmlChildren[i].XmlText);
			StructInsert(r,'FeedTypeDescription',this.enum.FeedType[r.FeedType]);
			StructInsert(r,'RequestId',xml.ResponseMetadata.RequestId.XmlText);
			if(this.showXmlResponse)
				StructInsert(r,'XmlResponse',xml);
			
			return r;
		</cfscript>
	</cffunction>

	<cffunction name="getFeedSubmissionList" hint="The GetFeedSubmissionList operation returns the total list of feed submissions within the previous 90 days that match the query parameters. Returns a struct with the following keys: NextToken, HasNext, FeedSubmissionId, FeedType, SubmittedDate, FeedProcessingStatus" access="public" output="false" returntype="any">
		<cfargument name="FeedSubmissionIdList" type="string" hint="A structured list of feed submission IDs. If you pass in explicit IDs in this call, the other conditions, if specified, will be ignored." default="All" required="false" />
		<cfargument name="MaxCount" type="numeric" hint="Maximum number of feed submissions to return in the list. If you specify a number greater than 100, the call will be rejected." default="10" required="false" />
		<cfargument name="FeedTypeList" type="string" hint="A structured list of one or more FeedType constants by which to filter feed submissions." default="All Types" required="false" />
		<cfargument name="FeedProcessingStatusList" type="string" hint="A structured list of one or more feed processing statuses by which to filter feed submissions. Valid values are: SUBMITTED, IN_PROGRESS, CANCELLED, DONE" default="All" required="false" />
		<cfargument name="SubmittedFromDate" type="date" hint="The earliest submission date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00""). Defaults to 30 days ago." required="false" />
		<cfargument name="SubmittedToDate" type="date" hint="The latest submission date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00"")." required="false" />
		<cfscript>
			var qs 		= "Action=GetFeedSubmissionList";
			var idList 	= iif(arguments.FeedSubmissionIdList is "all", DE(''), DE(arguments.FeedSubmissionIdList));
			var typeList= iif(arguments.FeedTypeList is "All Types", DE(''), DE(arguments.FeedTypeList));
			var status	= iif(arguments.FeedProcessingStatusList is "All", DE(''), DE(arguments.FeedProcessingStatusList));
			var i		= 0;
			var n		= 0;
			var out		= StructNew();
			var xml	= "";
			var tmp		= StructNew();
			
			
			//Specify any additional filters to narrow the results
			if(not StructKeyExists(arguments,"SubmittedFromDate"))
				arguments.SubmittedFromDate = dateadd("d",-30,now());
			if(not StructKeyExists(arguments,"SubmittedToDate"))
				arguments.SubmittedToDate = now();
			qs = listappend(qs,"SubmittedFromDate="&formatdate(arguments.SubmittedFromDate),"&");
			qs = listappend(qs,"SubmittedToDate="&formatdate(arguments.SubmittedToDate),"&");
			if(arguments.MaxCount lte 1)
				qs = listappend(qs,"MaxCount=1","&");
			else if(arguments.MaxCount gte 10)
				qs = listappend(qs,"MaxCount=10","&");
			else
				qs = listappend(qs,"MaxCount="&arguments.MaxCount,"&");
			
			//Create query request properties for each submission ID/type
			for(i=1; i lte listlen(idList); i=i+1)
				qs = listappend(qs,'FeedSubmissionIdList.Id.'&i&"="&trim(listgetat(idList,i)),"&");
			for(i=1; i lte listlen(typeList); i=i+1) {
				if (not StructKeyExists(this.enum.feedtype,listgetat(typeList,i)))
					throw("InvalidFeedType",this.enum.error.InvalidFeedType);
				qs = listappend(qs,'FeedTypeList.Type.'&i&"="&trim(listgetat(typeList,i)),"&");
			}
			for(i=1; i lte listlen(status); i=i+1)
				qs = listappend(qs,'FeedProcessingStatusList.Status.'&i&"="&trim(listgetat(status,i)),"&");

			//Get XML result
			xml = sendRequest(getSignedURL(qs,"GET"),"GET");

			//Make the object "pretty"
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"hasNext",lcase(trim(xml.GetFeedSubmissionListResult.HasNext.XmlText)) is "true");
			if(out.hasNext)
				StructInsert(out,"nextToken",trim(xml.GetFeedSubmissionListResult.NextToken.XmlText));
			StructInsert(out,"FeedSubmissions",StructNew());
			for(i=1; i lte arraylen(xml.GetFeedSubmissionListResult.XmlChildren);i=i+1){
				if (xml.GetFeedSubmissionListResult.XmlChildren[i].XmlName is "FeedSubmissionInfo"){
					tmp = StructNew();
					for(n=1;n lte arraylen(xml.GetFeedSubmissionListResult.XmlChildren[i].XmlChildren);n=n+1){
						if(xml.GetFeedSubmissionListResult.XmlChildren[i].XmlChildren[n].XmlName is not "FeedSubmissionId")
							StructInsert(tmp,xml.GetFeedSubmissionListResult.XmlChildren[i].XmlChildren[n].XmlName,xml.GetFeedSubmissionListResult.XmlChildren[i].XmlChildren[n].XmlText);
					}
					StructInsert(out.FeedSubmissions,xml.GetFeedSubmissionListResult.XmlChildren[i].FeedSubmissionId.XmlText,tmp);
				}
			}

			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getFeedSubmissionListByNextToken" hint="The GetFeedSubmissionListByNextToken operation returns a list of feed submissions that match the query parameters, using the NextToken, which was supplied by a previous call to either GetFeedSubmissionListByNextToken or a call to GetFeedSubmissionList, where the value of HasNext was true in that previous call. Returns a struct with the following keys: NextToken, HasNext, FeedSubmissionId, FeedType, SubmittedDate, FeedProcessingStatus." access="public" output="false" returntype="struct">
		<cfargument name="NextToken" type="string" hint="Token returned in a previous call to either GetFeedSubmissionList or GetFeedSubmissionListByNextToken when the value of HasNext was true." required="true" />
		<cfscript>
			var qs	= "Action=GetFeedSubmissionListByNextToken&NextToken="&trim(arguments.NextToken);
			var xml	= getRequestDetail(qs);//var xml	= sendRequest(getSignedURL(qs));
			var out	= StructNew();
			var tmp	= StructNew();
			var i	= 0;
			var n	= 0;
dump(xml);			
			//Process results
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			StructInsert(out,"hasNext",lcase(trim(xml.GetFeedSubmissionListByNextTokenResult.HasNext.XmlText)) is "true");
			if(out.hasNext)
				StructInsert(out,"NextToken",trim(xml.GetFeedSubmissionListByNextTokenResult.NextToken.XmlText));
			StructInsert(out,"ReportSchedule",StructNew());
			for(i=1; i lte arraylen(xml.GetFeedSubmissionListByNextTokenResult.XmlChildren);i=i+1){
				if(lcase(trim(xml.GetFeedSubmissionListByNextTokenResult.XmlChildren[i].XmlName)) is "feedsubmissioninfo"){
					tmp = StructNew();
					for(n=1; n lte arraylen(xml.GetFeedSubmissionListByNextTokenResult.XmlChildren[i].XmlChildren);n=n+1){
						if (lcase(trim(xml.GetFeedSubmissionListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlName)) is not "feedsubmissionid")
							StructInsert(tmp,xml.GetFeedSubmissionListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlName,xml.GetFeedSubmissionListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlText);
					}
					StructInsert(out,xml.GetFeedSubmissionListByNextTokenResult.XmlChildren[i].FeedSubmissionId.XmlText,tmp);
				}
			}
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getFeedSubmissionCount" hint="The GetFeedsubmissionCount operation returns a count of the total number of feed submissions within the previous 90 days." access="public" output="false" returntype="numeric">
		<cfargument name="FeedTypeList" type="string" hint="A structured list of one or more FeedType constants by which to filter feed submissions." required="false" />
		<cfargument name="FeedProcessingStatusList" type="string" hint="A structured list of one or more feed processing statuses by which to filter feed submissions. Valid values are: SUBMITTED, IN_PROGRESS, CANCELLED, DONE" required="false" />
		<cfargument name="SubmittedFromDate" type="date" hint="The earliest submission date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00""). Defaults to 30 days ago." required="false" />
		<cfargument name="SubmittedToDate" type="date" hint="The latest submission date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00"")." required="false" />
		<cfscript>
			var qs = "Action=GetFeedSubmissionCount";
			var idList 	= iif(arguments.FeedSubmissionIdList is "all", DE(''), DE(arguments.FeedSubmissionIdList));
			var typeList= iif(arguments.FeedTypeList is "All Types", DE(''), DE(arguments.FeedTypeList));
			var i	= 0;
			
			//Add feed submission list (supports multiple simultaneous cancellations)
			for(i=1; i lte listlen(arguments.FeedSubmissionIdList); i=i+1)
				qs = listappend(qs,"FeedSubmissionIdList.Id."&i&"="&trim(listgetat(arguments.FeedSubmissionIdList,i)),"&");
			
			//Specify a date range
			if(not StructKeyExists(arguments,"SubmittedFromDate"))
				arguments.SubmittedFromDate = dateadd("d",-30,now());
			if(not StructKeyExists(arguments,"SubmittedToDate"))
				arguments.SubmittedToDate = now();
			qs = listappend(qs,"SubmittedFromDate="&formatdate(arguments.SubmittedFromDate),"&");
			qs = listappend(qs,"SubmittedToDate="&formatdate(arguments.SubmittedToDate),"&");
			
			//Create query request properties for each submission ID/type
			for(i=1; i lte listlen(typeList); i=i+1) {
				if (not StructKeyExists(this.enum.feedtype,listgetat(typeList,i)))
					throw("InvalidFeedType",this.enum.error.InvalidFeedType);
				qs = listappend(qs,'FeedTypeList.Type.'&i&"="&trim(listgetat(typeList,i)),"&");
			}			

			return sendRequest(getSignedURL(qs)).GetFeedSubmissionCountResult.Count.XmlText;
		</cfscript>
	</cffunction>

	<cffunction name="cancelFeedSubmissions" hint="The CancelFeedSubmissions operation cancels one or more feed submissions, returning the count of the canceled feed submissions and the feed submission information. You can specify a number to cancel of greater than one hundred, but information will only be returned about the first one hundred feed submissions in the list. To return metadata about a greater number of canceled feed submissions, you can call GetFeedSubmissionList. If feeds have already begun processing, they cannot be canceled. Returns a struct with the following keys: Count, FeedSubmissionId, FeedType, SubmittedDate, FeedProcessingStatus" access="public" output="false" returntype="struct">
		<cfargument name="FeedSubmissionIdList" type="string" hint="A structured list (comma delimited) of feed submission IDs. If you pass in explicit IDs in this call, the other conditions, if specified, will be ignored." required="false" />
		<cfargument name="FeedTypeList" type="string" hint="A structured list of one or more FeedType constants by which to filter feed submissions." default="All types" required="false" />
		<cfargument name="SubmittedFromDate" type="(component name)" hint="The earliest submission date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00""). Defaults to 30 days ago." required="false" />
		<cfargument name="SubmittedToDate" type="date" hint="The latest submission date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00"")." required="false" />
		<cfscript>
			var qs 	= "Action=CancelFeedSubmissions";
			var idList 	= iif(arguments.FeedSubmissionIdList is "all", DE(''), DE(arguments.FeedSubmissionIdList));
			var typeList= iif(arguments.FeedTypeList is "All Types", DE(''), DE(arguments.FeedTypeList));
			var i	= 0;
			var out	= StructNew();
			var xml	= "";
			
			//Add feed submission list (supports multiple simultaneous cancellations)
			for(i=1; i lte listlen(arguments.FeedSubmissionIdList); i=i+1)
				qs = listappend(qs,"FeedSubmissionIdList.Id."&i&"="&trim(listgetat(arguments.FeedSubmissionIdList,i)),"&");
			
			//Specify a date range
			if(not StructKeyExists(arguments,"SubmittedFromDate"))
				arguments.SubmittedFromDate = dateadd("d",-30,now());
			if(not StructKeyExists(arguments,"SubmittedToDate"))
				arguments.SubmittedToDate = now();
			qs = listappend(qs,"SubmittedFromDate="&formatdate(arguments.SubmittedFromDate),"&");
			qs = listappend(qs,"SubmittedToDate="&formatdate(arguments.SubmittedToDate),"&");
			
			//Create query request properties for each submission ID/type
			for(i=1; i lte listlen(typeList); i=i+1) {
				if (not StructKeyExists(this.enum.feedtype,listgetat(typeList,i)))
					throw("InvalidFeedType",this.enum.error.InvalidFeedType);
				qs = listappend(qs,'FeedTypeList.Type.'&i&"="&trim(listgetat(typeList,i)),"&");
			}
									
			//Run request
			xml = sendRequest(getSignedURL(qs));
			
			//Parse results
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"Count",xml.CancelFeedSubmissionsResult.Count.XmlText);
			StructInsert(out,"FeedSubmissionInfo",xml.CancelFeedSubmissionsResult.FeedSubmissionInfo);
			//StructInsert(out,"RequestId",xml.CancelFeedSubmissionsResult.ResponseMetadata.RequestId.XmlText);
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getFeedSubmissionResult" hint="The GetFeedSubmissionResult operation returns the feed processing report and the Content-MD5 header for the returned body. Calls to GetFeedSubmissionResult are limited to 60 requests per hour, included within the overall limit of 1,000 calls per seller account per hour. " access="public" output="false" returntype="any">
		<cfargument name="FeedSubmissionId" type="string" hint="The identifier of the feed submission to get results for. Obtained by a call to GetFeedSubmissionList." required="true" />
		<cfscript>
			var qs 	= "Action=GetFeedSubmissionResult&FeedSubmissionId="&arguments.FeedSubmissionId;
			var rslt= sendRequest(getSignedURL(qs));
			var i	= 1;
			var out	= StructNew();
			
			//Confirm th MD5 header of the result to verify it's not corrupt. Try up to 3 times.
			//The send request method automatically determines whether the MD5 hash is correct
			//and provides the results in a struct (this.md5).
			while(not this.amazonmd5.valid and i lte 3) {
				i = i+1;
				rslt = sendRequest(getSignedURL(qs));
			}
			
			//Make sure the MD5 has is valid. If not, proceed to the error.
			if (this.amazonmd5.valid)	{
				StructInsert(out,"MessageType",rslt.MessageType.XmlText);
				StructInsert(out,"MessageID",rslt.Message.MessageID.XmlText);
				StructInsert(out,"ProcessingReport",rslt.Message.ProcessingReport);
				if(this.showXmlResponse)
					StructInsert(dtl,"XmlResponse",rslt);
				
				return out;
			}
				
			super.throwError("Corrupt Document","The file appears to be corrupt. The MD5 hash could not be verified.");
		</cfscript>
	</cffunction>


	<!--- Reports --->
	<cffunction name="requestReport" hint="The RequestReport operation requests the generation of a report, which creates a report request. Reports are retained for 90 days. Calls to RequestReport are limited to 30 requests per hour, included within the overall limit of 1,000 calls per seller account per hour. Returns a struct with the following keys: ReportRequestId, ReportType, StartDate, EndDate, Scheduled, SubmittedDate, ReportProcessingStatus. The RequestReport operation returns a RequestReport response, which is an aggregated element with child elements described in the following table." access="public" output="false" returntype="struct">
		<cfargument name="ReportType" type="string" hint="The type of report to request." required="true" />
		<cfargument name="StartDate" type="date" hint="Start of a date range used for selecting the data to report. Defaults to now." required="false" />
		<cfargument name="EndDate" type="date" hint="End of a date range used for selecting the data to report. Defaults to now." required="false" />
		<cfscript>
			var qs	= "Action=RequestReport";
			var out	= StructNew();
			var xml	= "";
			var i	= 0;
			
			//Make sure the report type is valid			
			if(not StructKeyExists(this.enum.ReportType,ucase(arguments.ReportType)))
				super.throw("InvalidReportType: "&ucase(arguments.ReportType),this.enum.Errors['InvalidReportType']);
			
			//Add minimum required attributes
			if(StructKeyExists(arguments,"StartDate"))
				qs = listappend(qs,"StartDate="&ReplaceNoCase(listfirst(formatdate(arguments.StartDate),"."),"Z","","ALL"),"&");
			if(StructKeyExists(arguments,"EndDate"))
				qs = listappend(qs,"EndDate="&ReplaceNoCase(listfirst(formatdate(arguments.EndDate),"."),"Z","","ALL"),"&");
			
			qs = listappend(qs,"ReportType="&ucase(trim(arguments.ReportType)),"&");
			
			//Send request	
			xml = sendRequest(getSignedURL(qs));
			
			//Parse results
			if(this.showXMLResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			for (i=1; i lte arraylen(xml.RequestReportResult.ReportRequestInfo.XmlChildren); i=i+1)
				StructInsert(out,xml.RequestReportResult.ReportRequestInfo.XmlChildren[i].XmlName,xml.RequestReportResult.ReportRequestInfo.XmlChildren[i].XmlText);
		
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportRequestList" hint="The GetReportRequestList operation returns a list of report requests that match the query parameters. The GetReportRequestList operation returns a GetReportRequestList response, which is an aggregated element with child elements described in the following table. A struct is returned with the following keys: NextToken, HasNext, ReportRequestId, ReportType, StartDate, EndDate, Scheduled, SubmittedDate, ReportProcessingStatus." access="public" output="false" returntype="struct">
		<cfargument name="ReportRequestIdList" type="string" hint="A structured list of report request IDs. If you pass in explicit IDs in this call, the other conditions, if specified, will be ignored." default="All" required="false" />
		<cfargument name="ReportTypeList" type="string" hint="A structured ReportType list by which to filter reports." default="All Types" required="false" />
		<cfargument name="ReportProcessingStatusList" type="string" hint="A structured list of report processing statuses by which to filter report requests. ReportProcessingStatus values: SUBMITTED, IN_PROGRESS, CANCELLED, DONE, DONE_NO_DATA." required="false" default="All" />
		<cfargument name="MaxCount" type="numeric" hint="Maximum number of reports to return in the list. If you specify a number greater than 100, the call will be rejected." default="10" required="false" />
		<cfargument name="RequestedFromDate" type="date" hint="The earliest date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00""). Defaults to 90 days ago." required="false" />
		<cfargument name="RequestedToDate" type="date" hint="The most recent date you are looking for. Defaults to now." required="false" />
		<cfscript>
			var qs		= "Action=GetReportRequestList";
			var out		= StructNew();
			var idList 	= iif(arguments.ReportRequestIdList is "all", DE(''), DE(arguments.ReportRequestIdList));
			var typeList= iif(arguments.ReportTypeList is "All Types", DE(''), DE(arguments.ReportTypeList));
			var status	= iif(arguments.ReportProcessingStatusList is "All", DE(''), DE(arguments.ReportProcessingStatusList));
			var i		= 0;
			var n		= 0;
			var tmp		= StructNew();
			var xml		= "";
			
			//Specify any additional filters to narrow the results
			if(not StructKeyExists(arguments,"RequestedFromDate"))
				arguments.RequestedFromDate = dateadd("d",-30,now());
			if(not StructKeyExists(arguments,"RequestedToDate"))
				arguments.RequestedToDate = now();
			qs = listappend(qs,"RequestedFromDate="&formatdate(arguments.RequestedFromDate),"&");
			qs = listappend(qs,"RequestedToDate="&formatdate(arguments.RequestedToDate),"&");
			if(arguments.MaxCount lte 1)
				qs = listappend(qs,"MaxCount=1","&");
			else if(arguments.MaxCount gte 10)
				qs = listappend(qs,"MaxCount=10","&");
			else
				qs = listappend(qs,"MaxCount="&arguments.MaxCount,"&");
			
			//Create query request properties for each submission ID/type
			for(i=1; i lte listlen(idList); i=i+1)
				qs = listappend(qs,'ReportRequestIdList.Id.'&i&"="&trim(listgetat(idList,i)),"&");
			for(i=1; i lte listlen(typeList); i=i+1) {
				if (not StructKeyExists(this.enum.reporttype,listgetat(typeList,i)))
					throw("InvalidReportType",this.enum.error.InvalidReportType);
				qs = listappend(qs,'ReportTypeList.Type.'&i&"="&trim(listgetat(typeList,i)),"&");
			}
			for(i=1; i lte listlen(status); i=i+1)
				qs = listappend(qs,'ReportProcessingStatusList.Status.'&i&"="&trim(listgetat(status,i)),"&");
				
			//Get XML result
			xml = sendRequest(getSignedURL(qs));
			
			//Parse results
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			if(StructKeyExists(xml.GetReportRequestListResult,"ReportRequestInfo")){
				StructInsert(out,"ReportRequestInfo",StructNew());
				for(i=1; i lte arraylen(xml.GetReportRequestListResult.XmlChildren); i=i+1){
					if (trim(lcase(xml.GetReportRequestListResult.XmlChildren[i].XmlName)) is "reportrequestinfo"){
						tmp = StructNew();
						for(n=1; n lte arraylen(xml.GetReportRequestListResult.XmlChildren[i].XmlChildren); n=n+1){
							if (lcase(trim(xml.GetReportRequestListResult.XmlChildren[i].XmlChildren[n].XmlName)) is not "reportrequestid")
								StructInsert(tmp,xml.GetReportRequestListResult.XmlChildren[i].XmlChildren[n].XmlName,xml.GetReportRequestListResult.XmlChildren[i].XmlChildren[n].XmlText);
						}
						StructInsert(out.ReportRequestInfo,xml.GetReportRequestListResult.XmlChildren[i].ReportRequestId.XmlText,tmp);
					}
				}
			}
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			StructInsert(out,"hasNext",lcase(trim(xml.GetReportRequestListResult.HasNext.XmlText)) is "true");
			if(out.hasNext)
				StructInsert(out,"NextToken",trim(xml.GetReportRequestListResult.NextToken.XmlText));
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportRequestListByNextToken" hint="The GetReportRequestListByNextToken operation returns a list of report requests that match the query parameters, using the NextToken, which was supplied by a previous call to either GetReportRequestListByNextToken or a call to GetReportRequestList, where the value of HasNext was true in that previous call. The GetReportRequestListByNextToken operation returns a GetReportRequestListByNextToken response, which is an aggregated element with child elements described in the following table: NextToken, HasNext, ReportRequestId, ReportType, StartDate, EndDate, Scheduled, SubmittedDate, ReportProcessingStatus" access="package" output="false" returntype="(component name)">
		<cfargument name="NextToken" type="string" hint="Token returned in a previous call to either GetReportRequestList or GetReportRequestListByNextToken when the value of HasNext was true." required="false" />
		<cfscript>
			var qs = "Action=GetReportRequestListByNextToken&NextToken="&trim(arguments.NextToken);
			var xml= sendRequest(getSignedURL(qs));
			var out= StructNew();
			var tmp	= StructNew();
			var i	= 0;
			var n	= 0;
			
			//Process results
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			StructInsert(out,"hasNext",lcase(trim(xml.GetReportRequestListByNextTokenResult.HasNext.XmlText)) is "true");
			if(out.hasNext)
				StructInsert(out,"NextToken",trim(xml.GetReportRequestListByNextTokenResult.NextToken.XmlText));
			StructInsert(out,"ReportList",StructNew());
			for(i=1; i lte arraylen(xml.GetReportRequestListByNextTokenResult.XmlChildren);i=i+1){
				if(lcase(trim(xml.GetReportRequestListByNextTokenResult.XmlChildren[i].XmlName)) is "reportrequestinfo"){
					tmp = StructNew();
					for(n=1; n lte arraylen(xml.GetReportRequestListByNextTokenResult.XmlChildren[i].XmlChildren);n=n+1){
						if (lcase(trim(xml.GetReportRequestListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlName)) is not "reportrequestid")
							StructInsert(tmp,xml.GetReportRequestListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlName,xml.GetReportRequestListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlText);
					}
					StructInsert(out,xml.GetReportRequestListByNextTokenResult.XmlChildren[i].ReportRequestId.XmlText,tmp);
				}
			}
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportRequestCount" hint="The GetReportRequestCount returns a count of report requests." access="public" output="false" returntype="any">
		<cfargument name="ReportTypeList" type="string" hint="A structured ReportType list by which to filter reports." default="All Types" required="false" />
		<cfargument name="ReportProcessingStatusList" type="string" hint="A structured list of report processing statuses by which to filter report requests. ReportProcessingStatus values: SUBMITTED, IN_PROGRESS, CANCELLED, DONE, DONE_NO_DATA" default="All" required="false" />
		<cfargument name="RequestedFromDate" type="date" hint="The earliest date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00""). Defaults to 90 days ago." required="false" />
		<cfargument name="RequestedToDate" type="date" hint="The most recent date you are looking for. Defaults to now." required="false" />
		<cfscript>
			var qs	= "Action=GetReportRequestCount";
			var typeList= iif(arguments.ReportTypeList is "All Types", DE(''), DE(arguments.ReportTypeList));
			var status	= iif(arguments.ReportProcessingStatusList is "All", DE(''), DE(arguments.ReportProcessingStatusList));
			
			//Specify any additional filters to narrow the results
			if(not StructKeyExists(arguments,"RequestedFromDate"))
				arguments.RequestedFromDate = dateadd("d",-30,now());
			if(not StructKeyExists(arguments,"RequestedToDate"))
				arguments.RequestedToDate = now();
			qs = listappend(qs,"RequestedFromDate="&formatdate(arguments.RequestedFromDate),"&");
			qs = listappend(qs,"RequestedToDate="&formatdate(arguments.RequestedToDate),"&");
			
			for(i=1; i lte listlen(typeList); i=i+1) {
				if (not StructKeyExists(this.enum.reporttype,listgetat(typeList,i)))
					throw("InvalidReportType",this.enum.error.InvalidReportType);
				qs = listappend(qs,'ReportTypeList.Type.'&i&"="&trim(listgetat(typeList,i)),"&");
			}
			for(i=1; i lte listlen(status); i=i+1)
				qs = listappend(qs,'ReportProcessingStatusList.Status.'&i&"="&trim(listgetat(status,i)),"&");
			
			return sendRequest(getSignedURL(qs)).GetReportRequestCountResult.Count.XmlText;
		</cfscript>
	</cffunction>

	<cffunction name="cancelReportRequests" hint="The CancelReportRequests operation cancels one or more report requests, returning the count of the canceled report requests and the report request information. You can specify a number to cancel of greater than one hundred, but information will only be returned about the first one hundred report requests in the list. To return metadata about a greater number of canceled report requests, you can call GetReportRequestList. If report requests have already begun processing, they cannot be canceled. The CancelReportRequests operation returns a CancelReportRequests response, which is an aggregated element with child elements described in the following struct keys: Count, StartDate, EndDate, Scheduled, SubmittedDate, ReportProcessingStatus." access="public" output="false" returntype="struct">
		<cfargument name="ReportRequestIdList" type="string" hint="A structured list of report request IDs. If you pass in explicit IDs in this call, the other conditions, if specified, will be ignored." default="All" required="false" />
		<cfargument name="ReportTypeList" type="string" hint="A structured ReportType list by which to filter reports." default="All Types" required="false" />
		<cfargument name="ReportProcessingStatusList" type="string" hint="A structured list of report processing statuses by which to filter report requests. ReportProcessingStatus values: SUBMITTED, IN_PROGRESS, CANCELLED, DONE, DONE_NO_DATA" default="All" required="false" />
		<cfargument name="RequestedFromDate" type="date" hint="The earliest date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00""). Defaults to  90 days ago." required="false" />
		<cfargument name="RequestedToDate" type="date" hint="The most recent date you are looking for. Defaults to now." required="false" />
		<cfscript>
			var qs		= "Action=CancelReportRequests";
			var out		= StructNew();
			var idList 	= iif(arguments.ReportRequestIdList is "All", DE(''), DE(arguments.ReportRequestIdList));
			var typeList= iif(arguments.ReportTypeList is "All Types", DE(''), DE(arguments.ReportTypeList));
			var status	= iif(arguments.ReportProcessingStatusList is "All", DE(''), DE(arguments.ReportProcessingStatusList));
			var i		= 0;
			var xml		= "";
			
			//Specify any additional filters to narrow the results
			if(not StructKeyExists(arguments,"RequestedFromDate"))
				arguments.RequestedFromDate = dateadd("d",-30,now());
			if(not StructKeyExists(arguments,"RequestedToDate"))
				arguments.RequestedToDate = now();
			qs = listappend(qs,"RequestedFromDate="&formatdate(arguments.RequestedFromDate),"&");
			qs = listappend(qs,"RequestedToDate="&formatdate(arguments.RequestedToDate),"&");
			
			//Create query request properties for each report ID/type
			for(i=1; i lte listlen(idList); i=i+1)
				qs = listappend(qs,'ReportRequestIdList.Id.'&i&"="&trim(listgetat(idList,i)),"&");
			for(i=1; i lte listlen(typeList); i=i+1) {
				if (not StructKeyExists(this.enum.reporttype,listgetat(typeList,i)))
					throw("InvalidReportType",this.enum.error.InvalidReportType);
				qs = listappend(qs,'ReportTypeList.Type.'&i&"="&trim(listgetat(typeList,i)),"&");
			}
			for(i=1; i lte listlen(status); i=i+1)
				qs = listappend(qs,'ReportProcessingStatusList.Status.'&i&"="&trim(listgetat(status,i)),"&");

			//Get XML result
			xml = sendRequest(getSignedURL(qs));
		
			//Parse results
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"Count",xml.CancelReportRequestsResult.Count.XmlText);
			StructInsert(out,"ReportRequestInfo",xml.CancelReportRequestsResult.ReportRequestInfo);
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportList" hint="The GetReportList operation returns a list of reports within the previous 90 days that match the query parameters. The maximum number of results that will be returned in one call is one hundred. If there are additional results to return, HasNext will be returned in the response with a true value. To retrieve all the results, you can use the value of the NextToken parameter to call GetReportListByNextToken until HasNext is false. The GetReportList operation returns a GetReportList response, which is an aggregated element with child elements described in the following struct keys: NextToken, HasNext, ReportId, ReportType, ReportRequestId, AvailableDate, Acknowledged" access="public" output="false" returntype="struct">
		<cfargument name="ReportTypeList" type="string" hint="A structured ReportType list by which to filter reports." required="false" />
		<cfargument name="Acknowledged" type="boolean" hint="Set to true to list order reports that have been acknowledged with a prior call to UpdateReportAcknowledgements. Set to false to list order reports that have not been acknowledged." required="false" />
		<cfargument name="AvailableFromDate" type="date" hint="The earliest date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00""). Defaults to 90 days ago." required="false" />
		<cfargument name="AvailableToDate" type="date" hint="The most recent date you are looking for. Defaults to now." required="false" />
		<cfargument name="ReportRequestIdList" type="string" hint="A structured list of report request IDs. If you pass in explicit IDs in this call, the other conditions, if specified, will be ignored." default="All" required="false" />
		<cfargument name="MaxCount" type="numeric" hint="Maximum number of reports to return in the list. If you specify a number greater than 100, the call will be rejected." default="10" required="false" />
		<cfscript>
			var qs	= "Action=GetReportList";
			var idList 	= iif(arguments.ReportRequestIdList is "All", DE(''), DE(arguments.ReportRequestIdList));
			var typeList= iif(arguments.ReportTypeList is "All Types", DE(''), DE(arguments.ReportTypeList));
			var out	= StructNew();
			var tmp	= StructNew();
			var dtl	= StructNew();
			var xml	= "";
			var i	= 0;
			var n	= 0;
			
			
			//Add other arguments to request.
			for(i=1; i lte listlen(typeList); i=i+1) {
				if (not StructKeyExists(this.enum.reporttype,listgetat(typeList,i)))
					throw("InvalidReportType",this.enum.error.InvalidReportType);
				qs = listappend(qs,'ReportTypeList.Type.'&i&"="&trim(listgetat(typeList,i)),"&");
			}
			for(i=1; i lte listlen(idList); i=i+1)
				qs = listappend(qs,'ReportRequestIdList.Id.'&i&"="&trim(listgetat(idList,i)),"&");
			if (StructKeyExists(arguments,"Acknowledged"))
				qs = listappend(qs,"Acknowledged="&iif(arguments.Acknowledged is true,DE('true'),DE('false')),"&");
			if(not StructKeyExists(arguments,"AvailableFromDate"))
				arguments.AvailableFromDate = dateadd("d",-90,now());
			if(not StructKeyExists(arguments,"AvailableToDate"))
				arguments.AvailableToDate = now();
			qs = listappend(qs,"AvailableFromDate="&formatdate(arguments.AvailableFromDate),"&");
			qs = listappend(qs,"AvailableToDate="&formatdate(arguments.AvailableToDate),"&");
			if(arguments.MaxCount lte 1)
				qs = listappend(qs,"MaxCount=1","&");
			else if(arguments.MaxCount gte 10)
				qs = listappend(qs,"MaxCount=10","&");
			else
				qs = listappend(qs,"MaxCount="&arguments.MaxCount,"&");
			
			
			//Send Request
			xml = sendRequest(getSignedURL(qs));

			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			if(StructKeyExists(xml.GetReportListResult,"ReportInfo")){
				for(i=1; i lte arraylen(xml.GetReportListResult.XmlChildren); i=i+1){
					if (xml.GetReportListResult.XmlChildren[i].XmlName is "ReportInfo"){
						dtl = StructNew();
						for(n=1; n lte arraylen(xml.GetReportListResult.XmlChildren[i].XmlChildren); n=n+1){
							if (lcase(trim(xml.GetReportListResult.XmlChildren[i].XmlChildren[n].XmlName)) is not "reportid")
								StructInsert(dtl,xml.GetReportListResult.XmlChildren[i].XmlChildren[n].XmlName,xml.GetReportListResult.XmlChildren[i].XmlChildren[n].XmlText);
						}
						StructInsert(tmp,xml.GetReportListResult.XmlChildren[i].ReportId.XmlText,dtl);
					}
				}
				StructInsert(out,"ReportRequestInfo",tmp);
			}
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			StructInsert(out,"hasNext",lcase(trim(xml.GetReportListResult.HasNext.XmlText)) is "true");
			if(out.hasNext)
				StructInsert(out,"NextToken",trim(xml.GetReportListResult.NextToken.XmlText));
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportListByNextToken" hint="The GetReportListByNextToken operation returns a list of reports that match the query parameters, using the NextToken, which was supplied by a previous call to either GetReportListByNextToken or a call to GetReportList, where the value of HasNext was true in that previous call. The GetReportListByNextToken operation returns a GetReportListByNextToken response, which is an aggregated element with child elements described in the following struct keys: NextToken, HasNext, ReportId, ReportType, ReportRequestId, AvailableDate, Acknowledged" access="public" output="false" returntype="struct">
		<cfargument name="NextToken" type="string" hint="Token returned in a previous call to either GetReportList or GetReportListByNextToken when the value of HasNext was true." required="true" />
		<cfscript>
			var qs	= "Action=GetReportListByNextToken&NextToken="&trim(arguments.NextToken);
			var xml	= sendRequest(getSignedURL(qs));
			var out	= StructNew();
			var tmp	= StructNew();
			var i	= 0;
			var n	= 0;
			
			//Process results
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			StructInsert(out,"hasNext",lcase(trim(xml.GetReportListByNextTokenResult.HasNext.XmlText)) is "true");
			if(out.hasNext)
				StructInsert(out,"NextToken",trim(xml.GetReportListByNextTokenResult.NextToken.XmlText));
			StructInsert(out,"ReportList",StructNew());
			for(i=1; i lte arraylen(xml.GetReportListByNextTokenResult.XmlChildren);i=i+1){
				if(lcase(trim(xml.GetReportListByNextTokenResult.XmlChildren[i].XmlName)) is "reportinfo"){
					tmp = StructNew();
					for(n=1; n lte arraylen(xml.GetReportListByNextTokenResult.XmlChildren[i].XmlChildren);n=n+1){
						if (lcase(trim(xml.GetReportListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlName)) is not "reportid")
							StructInsert(tmp,xml.GetReportListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlName,xml.GetReportListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlText);
					}
					StructInsert(out,xml.GetReportListByNextTokenResult.XmlChildren[i].ReportId.XmlText,tmp);
				}
			}
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportCount" hint="The GetReportCount operation returns a count of reports within the previous 90 days that are available for the seller to download." access="public" output="false" returntype="numeric">
		<cfargument name="ReportTypeList" type="string" hint="A structured ReportType list (comma delimited) by which to filter reports." default="All" required="false" />
		<cfargument name="Acknowledged" type="boolean" hint="Set to true to list order reports that have been acknowledged with a prior call to UpdateReportAcknowledgements. Set to false to list order reports that have not been acknowledged." required="false" />
		<cfargument name="AvailableFromDate" type="date" hint="The earliest date you are looking for, in ISO8601 date format (for example, ""2008-07-03T18:12:22Z"" or ""2008-07-03T18:12:22.093-07:00""). Defaults to 90 days ago." required="false" />
		<cfargument name="AvailableToDate" type="date" hint="The most recent date you are looking for. Defaults to now." required="false" />
		<cfscript>
			var qs	= "Action=GetReportCount";
			var i	= 0;
			
			//Clear the default value if none is specified (forces return of All)
			if(arguments.ReportTypeList is "All")
				arguments.ReportTypeList = "";
				
			//Add other arguments
			for(i=1; i lte listlen(arguments.ReportTypeList); i=i+1){
				if(not StructKeyExists(this.enum.ReportType,trim(listgetat(arguments.ReportTypeList,i))))
					super.throw("InvalidReportType",this.enum.ReportType["InvalidReportType"]);
				qs = listappend(qs,"ReportTypeList.Type."&i&"="&trim(listgetat(arguments.ReportTypeList,i)),"&");
			}
			if(StructKeyExists(arguments,"Acknowledged"))
				qs = listappend(qs,"Acknowledged="&iif(arguments.acknowledged is true,DE('true'),DE('false')),"&");
			if(not StructKeyExists(arguments,"AvailableFromDate"))
				arguments.AvailableFromDate = dateadd("d",-90,now());
			if(not StructKeyExists(arguments,"AvailableToDate"))
				arguments.AvailableToDate = now();
			qs = listappend(qs,"AvailableFromDate="&formatdate(arguments.AvailableFromDate),"&");
			qs = listappend(qs,"AvailableToDate="&formatdate(arguments.AvailableToDate),"&");

			//Run the request			
			return sendRequest(getSignedURL(qs)).GetReportCountResult.Count.XmlText;
		</cfscript>
	</cffunction>

	<cffunction name="getReport" hint="The GetReport operation returns the contents of a report and the Content-MD5 header for the returned body. Reports are retained for 90 days from the time they have been generated." access="public" output="false" returntype="any">
		<cfargument name="ReportId" type="numeric" hint="A unique identifier of the report to download, as obtained from GetReportList or the GeneratedReportId of a ReportRequest." required="true" />
		<cfscript>
			var qs = "Action=GetReport&ReportId="&trim(arguments.ReportId);
			var rtn= sendRequest(getSignedURL(qs));

			if(not this.amazonmd5.valid)
				super.throwError("ContentMD5DoesNotMatch",this.enum.error['ContentMD5DoesNotMatch']);
			
			return rtn;
		</cfscript>
	</cffunction>

	<cffunction name="manageReportSchedule" hint="The ManageReportSchedule operation creates, updates, or deletes a report schedule for a particular report type. Currently, only order reports can be scheduled. The ManageReportSchedule operation returns a ManageReportSchedule response, which is an aggregated element with child elements described in the following struct keys: Count, ReportType, Schedule, ScheduledDate" access="public" output="false" returntype="struct">
		<cfargument name="ReportType" type="string" hint="The type of reports that you want to schedule generation of. Currently, only order reports can be scheduled." required="false" />
		<cfargument name="Schedule" type="string" hint="A string that describes how often a ReportRequest should be created. The list of enumerated values is found in the enumeration topic, Schedule. Use a value of _NEVER_ to delete a schedule." required="false" />
		<cfargument name="ScheduledDate" type="date" hint="The date when the next report is scheduled to run. Limited to no more than 366 days in the future. Defaults to now." required="false" />
		<cfscript>
			var qs	= "Action=ManageReportSchedule";
			var xml	= "";
			var out	= StructNew();
			var i	= 0;
			
			//Add other attributes to query string
			if(not StructKeyExists(this.enum.ReportType,arguments.ReportType))
				super.throwError("InvalidReportType",this.enum.Error['InvalidReportType']);
			qs = listappend(qs,"ReportType="&trim(arguments.ReportType),"&");
			if(not StructKeyExists(this.enum.Schedule,arguments.Schedule))
				super.throwError("InvalidScheduleFrequency",this.enum.Error['InvalidScheduleFrequency']);
			qs = listappend(qs,"Schedule="&trim(arguments.Schedule),"&");
			if(StructKeyExists(arguments,"ScheduledDate"))
				qs = listappend(qs,"Schedule="&formatdate(arguments.ScheduledDate),"&");
			
			//Send the request.
			xml = sendRequest(getSignedURL(qs));
			
			//Parse XML response.
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"Count",xml.ManageReportScheduleResult.Count.XmlText);
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			for(i=1; i lte arraylen(xml.ManageReportScheduleResult.XmlChildren); i=i+1)
				StructInsert(out,xml.ManageReportScheduleResult.ReportSchedule.XmlChildren[i].XmlName,xml.ManageReportScheduleResult.ReportSchedule.XmlChildren[i].XmlText);

			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportScheduleList" hint="The GetReportScheduleList operation returns a list of report schedules that match the query parameters. Currently, only order reports can be scheduled. The maximum number of results that will be returned in one call is one hundred. If there are additional results to return, HasNext will be returned in the response with a true value. To retrieve all the results, you can use the value of the NextToken parameter to call GetReportScheduleListByNextToken until HasNext is false. The GetReportScheduleList operation returns a GetReportScheduleList response, which is an aggregated element with child elements described in the following struct keys: NextToken, HasNext, ReportType, Schedule, ScheduledDate." access="public" output="false" returntype="struct">
		<cfargument name="ReportTypeList" type="string" hint="A structured ReportType list by which to filter reports. Currently, only order reports can be scheduled." default="All" required="false" />
		<cfscript>
			var qs	= "Action=GetReportScheduleList";
			var i 	= 0;
			var n 	= 0;
			var xml	= "";
			var out	= StructNew();
			var tmp	= StructNew();
			
			//Generate parameters from list
			for(i=1; i lte listlen(arguments.ReportTypeList); i=i+1){
				if(not StructKeyExists(this.enum.ReportType,trim(listgetat(arguments.ReportTypeList,i))))
					super.throwError("InvalidReportType",this.enum.Error['InvalidReportType']);
				qs = listappend(qs,"ReportTypeList.Type."&i&"="&trim(listgetat(arguments.ReportTypeList,i)),"&");
			}
			
			//Send request
			xml = sendRequest(getSignedURL(qs));
			
			//Process results
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"hasNext",trim(lcase(xml.GetReportScheduleListResult.HasNext.XmlText)) is "true");
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			if(out.hasNext)
				StructInsert(out,"NextToken",trim(xml.GetReportScheduleListResult.NextToken.XmlText));
			for(i=1; i lte arraylen(xml.GetReportScheduleListResult.XmlChildren); i=i+1){
				if (not StructKeyExists(out,"ReportSchedule"))
					StructInsert(out,"ReportSchedule",StructNew());
				if (lcase(trim(xml.GetReportScheduleListResult.XmlChildren[i].XmlName)) is "reportschedule"){
					tmp = StructNew();
					for(n=1; n lte arraylen(xml.GetReportScheduleListResult.XmlChildren[i].XmlChildren); n=n+1){
						if(lcase(trim(xml.GetReportScheduleListResult.XmlChildren[i].XmlChildren[n].XmlName)) is not "reporttype")
							StructInsert(tmp,xml.GetReportScheduleListResult.XmlChildren[i].XmlChildren[n].XmlName,xml.GetReportScheduleListResult.XmlChildren[i].XmlChildren[n].XmlText);
					}
					StructInsert(out,xml.GetReportScheduleListResult.XmlChildren[i].ReportType.XmlText,tmp);
				}					
			}
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportScheduleListByNextToken" hint="The GetReportScheduleListByNextToken operation returns a list of report schedules that match the query parameters, using the NextToken, which was supplied by a previous call to either GetReportScheduleListByNextToken or a call to GetReportScheduleList, where the value of HasNext was true in that previous call. For this release of Amazon MWS, only order reports can be scheduled, so HasNext will always be False. The GetReportScheduleListByNextToken operation returns a GetReportScheduleListByNextToken response, which is an aggregated element with child elements described in the following struct keys: NextToken, HasNext, ReportType, Schedule, ScheduledDate." access="public" output="false" returntype="struct">
		<cfargument name="NextToken" type="string" hint="Token returned in a previous call to either GetReportScheduleList or GetReportScheduleListByNextToken when the value of HasNext was true." required="true" />
		<cfscript>
			var qs	= "Action=GetReportScheduleListByNextToken&NextToken="&trim(arguments.NextToken);
			var xml	= sendRequest(getSignedURL(qs));
			var out	= StructNew();
			var tmp	= StructNew();
			var i	= 0;
			var n	= 0;
			
			//Process results
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"RequestId",xml.ResponseMetadata.RequestId.XmlText);
			StructInsert(out,"hasNext",lcase(trim(xml.GetReportScheduleListByNextTokenResult.HasNext.XmlText)) is "true");
			if(out.hasNext)
				StructInsert(out,"NextToken",trim(xml.GetReportScheduleListByNextTokenResult.NextToken.XmlText));
			StructInsert(out,"ReportSchedule",StructNew());
			for(i=1; i lte arraylen(xml.GetReportScheduleListByNextTokenResult.XmlChildren);i=i+1){
				if(lcase(trim(xml.GetReportScheduleListByNextTokenResult.XmlChildren[i].XmlName)) is "reportschedule"){
					tmp = StructNew();
					for(n=1; n lte arraylen(xml.GetReportScheduleListByNextTokenResult.XmlChildren[i].XmlChildren);n=n+1){
						if (lcase(trim(xml.GetReportScheduleListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlName)) is not "reporttype")
							StructInsert(tmp,xml.GetReportScheduleListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlName,xml.GetReportScheduleListByNextTokenResult.XmlChildren[i].XmlChildren[n].XmlText);
					}
					StructInsert(out,xml.GetReportScheduleListByNextTokenResult.XmlChildren[i].ReportType.XmlText,tmp);
				}
			}
			
			return out;
		</cfscript>
	</cffunction>

	<cffunction name="getReportScheduleCount" hint="The GetReportScheduleCount operation returns a count of report schedules. Currently, only order reports can be scheduled. " access="public" output="false" returntype="numeric">
		<cfargument name="ReportTypeList" type="string" hint="A structured ReportType list by which to filter reports. Currently, only order reports can be scheduled." default="All" required="false" />
		<cfscript>
			var qs	= "Action=GetReportScheduleCount";
			var i	= 0;
			
			//Generate parameters from list
			for(i=1; i lte listlen(arguments.ReportTypeList); i=i+1){
				if(not StructKeyExists(this.enum.ReportType,trim(listgetat(arguments.ReportTypeList,i))))
					super.throwError("InvalidReportType",this.enum.Error['InvalidReportType']);
				qs = listappend(qs,"ReportTypeList.Type."&i&"="&trim(listgetat(arguments.ReportTypeList,i)),"&");
			}
	
			return sendRequest(getSignedURL(qs)).GetReportScheduleCountResult.Count.XmlText;
		</cfscript>
	</cffunction>

	<cffunction name="updateReportAcknowledgements" hint="The UpdateReportAcknowledgements operation is an optional function that you should use only if you want Amazon to remember the Acknowledged status of your reports. UpdateReportAcknowledgements updates the acknowledged status of one or more reports. To keep track of which reports you have already received, it is a good practice to acknowledge reports after you have received and stored them successfully. Then, when you call GetReportListyou can specify to receive only reports that have not yet been acknowledged. You can also use this function to retrieve reports that have been lost, possibly because of a hard disk failure, by setting Acknowledged to false and then calling GetReportList, which returns a list of reports within the previous 90 days that match the query parameters. The UpdateReportAcknowledgements operation returns an UpdateReportAcknowledgements response, which is an aggregated element with child elements described in the following struct keys: Count, ReportId, ReportType, ReportRequestId, AvailableDate, Acknowledged AcknowledgedDate" access="public" output="false" returntype="struct">
		<cfargument name="ReportIdList" type="string" hint="A structured list of Report Ids. The maximum number of reports that can be specified is 100." required="true" />
		<cfargument name="Acknowledged" type="boolean" hint="Set to true to list reports that have been acknowledged. Set to false to list reports that have not been acknowledged." required="false" />
		<cfscript>
			var qs	= "Action=UpdateReportAcknowledgements";
			var i	= 0;
			var xml	= "";
			var out	= StructNew();
			var tmp	= StructNew();
			
			//Generate parameters
			for(i=1; i lte listlen(arguments.ReportIdList); i=i+1)
				qs = listappend(qs,"ReportIdList.Id."&i&"="&trim(listgetat(arguments.ReportIdList,i)),"&");
			qs = listappend(qs,"Acknowledged="&iif(arguments.Acknowledged is true,DE('true'),DE('false')),"&");
			
			//Send request
			xml = sendRequest(getSignedURL(qs));
			
			//Process response
			if(this.showXmlResponse)
				StructInsert(out,"XmlResponse",xml);
			StructInsert(out,"Count",xml.UpdateReportAcknowledgementsResult.Count.XmlText);
			if(out.Count gt 0){
				tmp = StructNew();
				StructInsert(out,"ReportInfo",StructNew());
				for (i=1; i lte arraylen(xml.UpdateReportAcknowledgementsResult.ReportInfo.XmlChildren);i=i+1){
					if (lcase(trim(xml.UpdateReportAcknowledgementsResult.ReportInfo.XmlChildren[i].XmlName)) is not "reportid")
						StructInsert(tmp,xml.UpdateReportAcknowledgementsResult.ReportInfo.XmlChildren[i].XmlName,xml.UpdateReportAcknowledgementsResult.ReportInfo.XmlChildren[i].XmlText);
				}				
				StructInsert(out.ReportInfo,xml.UpdateReportAcknowledgementsResult.ReportInfo.ReportId.XmlText,tmp);
			}
			
			return out;
		</cfscript>
	</cffunction>
	
	
	
	<!--- Private helper methods --->
	<cffunction name="sendRequest" access="private" output="false" returntype="xml">
		<cfargument name="uri" type="string" required="true" hint="The URL used for the request."/>
		<cfargument name="method" type="string" required="false" default="POST"/>
		<cfargument name="body" type="any" required="false" default="" hint="HTTP body of the request."/>
		<cfscript>
			var out = "";
		</cfscript>
		
		<!--- Send the request --->
		<cfhttp url="#trim(replace(arguments.uri,'Signature= ','Signature=','ONE'))#" method="#lcase(arguments.method)#" useragent="#this.useragent#">
			<cfhttpparam type="Header" name= "Accept-Encoding" value= "*" />
			<cfhttpparam type="Header" name= "TE" value= "deflate;q=0" />
			<cfif len(trim(arguments.body))>
				<cfhttpparam type="Header" name="Content-Type" value="text/xml; charset=iso-8859-1"/>
				<cfhttpparam type="Header" name="Content-MD5" value="#super.md5(arguments.body)#"/>
				<cfhttpparam type="Body" value="#arguments.body#"/>
			<cfelse>
				<cfhttpparam type="Header" name="Content-Type" value="application/x-www-form-urlencoded; charset=iso-8859-1"/>
			</cfif>
		</cfhttp>
		
		<cfscript>
			//Copy the request (typically used in troubleshooting)
			this.mwsrequest = StructCopy(arguments);
			
			//Check the MD5 hash (used to make sure file is not corrupted in transmission)
			this.amazonmd5 = StructNew();
			this.amazonmd5.valid = false;
			if (StructKeyExists(cfhttp,"Responseheader")) {
				if(StructKEyExists(cfhttp.Responseheader,"Content-MD5")) {
					this.amazonmd5.valid = trim(super.md5(cfhttp.FileContent)) is trim(cfhttp.Responseheader['Content-MD5']);
					this.amazonmd5.fromamazon = trim(cfhttp.Responseheader['Content-MD5']);
					this.amazonmd5.generated = trim(super.md5(cfhttp.FileContent));
					if (StructKeyExists(cfhttp.Responseheader,"x-amz-request-id"))
						this.amazonmd5.requestid = trim(cfhttp.Responseheader['x-amz-request-id']);
				}
			}

			
			if (isXml(cfhttp.FileContent)){
				try{
					out = XmlParse(cfhttp.FileContent).XmlRoot;
				} catch(any e){
					dump(cfhttp);
				}
				
				if(trim(lcase(out.XmlName)) is "errorresponse" and not this.debug)
					super.throwError(trim(out.Error.Code.XmlText),this.enum.error[trim(out.Error.Code.XmlText)]&'<br/><br/><u>MWS responded with the following message:<br/></u> '&out.Error.Message.XmlText);
			}
			
			return out;
		</cfscript>
	</cffunction>
	
	<cffunction name="encodeurl" hint="A special URL encoding since CF uses a slightly different URL encoding approach." access="private" returntype="string">
		<cfargument name="str" type="string"/>
		<cfreturn Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(arguments.str, ",", "%2C", "ALL"), ":", "%3A", "ALL"), " ", "%20", "ALL"),"+","%20","ALL"),"*","%2A","ALL"),"%7E","~","ALL"), "\", "%5C", "ALL"),"+", "%2B", "ALL")/>
	</cffunction>
	
	<!--- This method was kindly contributed by Glen Hamilton --->
	<cffunction name="encodeSignature" hint="A special URL encoding since CF uses a slightly different URL encoding approach this is to encode the signature variable." access="private" returntype="string">
		<cfargument name="str" type="string"/>
		<cfreturn Replace(Replace(Replace(Replace(Replace(Replace(Replace(arguments.str, "\", "%5C", "ALL"), "+", "%2B", "ALL"), ":", "%3A", "ALL"), "=", "%3D", "ALL"),"/","%2F","ALL"),"*","%2A","ALL"),"%7E","~","ALL")/>
	</cffunction>

	<cffunction name="formatdate" access="private" hint="Format dates properly for REST">
		<cfargument name="dt" type="date" required="true"/>
		<cfreturn DateFormat(arguments.dt,"yyyy-mm-dd")&"T"&TimeFormat(arguments.dt,"HH:mm:ss")&"Z"/>
	</cffunction>
	
	<cffunction name="getSignedURL" returnType="string" output="false">
		<cfargument name="querystring" type="string" hint="Query string" required="yes"/>
		<cfargument name="method" type="string" required="false" default="POST"/>
		<cfargument name="HTTPRequestURI" required="false" default="/" hint="The HTTP absolute path component of the URI up to, but not including, the query string. If empty, use a forward slash."/>
		<cfscript>
			var cqs = listsort(arguments.querystring,"textnocase","ASC","&"); //Canonical query string
			var ts = formatdate(DateConvert("local2Utc", Now()));
			var sig = "";
			var sigg= "";
			var eqs = ""; //Encoded query string
			var i 	= "";
			var cr	= chr(10);
			
			//Construct query string
			/*if (findnocase("action=submitfeed",cqs))
				cqs = listprepend(cqs,"AWSAccessKeyId="&this.accessKeyId,"&");
			else
				eqs = "AWSAccessKeyId="&this.accessKeyId;*/
			cqs = listappend(cqs,"Marketplace="&this.marketplaceId,"&");
			cqs = listappend(cqs,"Merchant="&this.merchantId,"&");
			cqs = listappend(cqs,"SignatureMethod="&this.signaturemethod,"&");
			cqs = listappend(cqs,"SignatureVersion="&this.signatureversion,"&");
			cqs = listappend(cqs,"Timestamp="&ts,"&");
			cqs = listappend(cqs,"Version="&this.version,"&");
			
			//URLEncode the canonical query string
			for (i=1; i lte listlen(cqs,"&"); i=i+1){
				if (listlen(listgetat(cqs,i,"&"),"=") gt 1)
					eqs = ListAppend(eqs,listgetat(listgetat(cqs,i,"&"),1,"=")&"="&encodeurl(listgetat(listgetat(cqs,i,"&"),2,"=")), "&");
				else
					eqs = ListAppend(eqs,listgetat(listgetat(cqs,i,"&"),1,"=")&"=", "&");
			}
			eqs = listprepend(listsort(eqs,"textnocase","ASC","&"),"AWSAccessKeyId="&this.accessKeyId,"&");
							
			//Build Signature & append to query string
			sig = listappend(sig,ucase(arguments.method),cr);
			sig = listappend(sig,rereplace(lcase(this.baseurl),"http://|https://","","ALL"),cr);
			sig = listappend(sig,lcase(arguments.HTTPRequestURI),cr);
			sig = listappend(sig,eqs,cr);
			sigg = trim(super.sign(sig,this.secretKeyId,this.signaturemethod));
			
			
			return this.baseurl&arguments.HTTPRequestURI&"?"&eqs&"&Signature="&encodeSignature(sigg);
		</cfscript>
	</cffunction>

	
	
	<!--- Debugging Methods (not relevant to production use) --->
	<cffunction name="getRequestDetail" returntype="any" output="false">
		<cfargument name="querystring" type="string" hint="Query string" required="yes"/>
		<cfargument name="method" type="string" required="false" default="POST"/>
		<cfargument name="HTTPRequestURI" required="false" default="/" hint="The HTTP absolute path component of the URI up to, but not including, the query string. If empty, use a forward slash."/>
		<cfscript>
			var dtl = StructNew();
			var _qs = StructNew();
			var cqs = listsort(arguments.querystring,"textnocase","ASC","&"); //Canonical query string
			var ts = formatdate(DateConvert("local2Utc", Now()));
			var sig = "";
			var sigg= "";
			var eqs = ""; //Encoded query string
			var i 	= "";
			var cr	= chr(10);
			
			StructInsert(_qs,"source",arguments.querystring);
			
			//Construct query string
			/*if (findnocase("action=submitfeed",cqs))
				cqs = listprepend(cqs,"AWSAccessKeyId="&this.accessKeyId,"&");
			else
				eqs = "AWSAccessKeyId="&this.accessKeyId;
			*/
			cqs = listappend(cqs,"Marketplace="&this.marketplaceId,"&");
			cqs = listappend(cqs,"Merchant="&this.merchantId,"&");
			cqs = listappend(cqs,"SignatureMethod="&this.signaturemethod,"&");
			cqs = listappend(cqs,"SignatureVersion="&this.signatureversion,"&");
			cqs = listappend(cqs,"Timestamp="&ts,"&");
			cqs = listappend(cqs,"Version="&this.version,"&");
			
			StructInsert(_qs,"source_sorted",cqs);
			
			//URLEncode the canonical query string
			for (i=1; i lte listlen(cqs,"&"); i=i+1){
				if (listlen(listgetat(cqs,i,"&"),"=") gt 1)
					eqs = ListAppend(eqs,listgetat(listgetat(cqs,i,"&"),1,"=")&"="&encodeurl(listgetat(listgetat(cqs,i,"&"),2,"=")), "&");
				else
					eqs = ListAppend(eqs,listgetat(listgetat(cqs,i,"&"),1,"=")&"=", "&");
			}
			eqs = listprepend(listsort(eqs,"textnocase","ASC","&"),"AWSAccessKeyId="&this.accessKeyId,"&");
			
			StructInsert(_qs,"encoded",eqs);
							
			//Build Signature & append to query string
			sig = listappend(sig,ucase(arguments.method),cr);
			sig = listappend(sig,rereplace(lcase(this.baseurl),"http://|https://","","ALL"),cr);
			sig = listappend(sig,lcase(arguments.HTTPRequestURI),cr);
			sig = listappend(sig,eqs,cr);
			sigg = trim(super.sign(sig,this.secretKeyId,this.signaturemethod));
			
			StructInsert(dtl,"query_string",_qs);
			StructInsert(dtl,"signature_string",sig);
			StructInsert(dtl,"signature_method",this.signaturemethod);
			StructInsert(dtl,"signature_key",sigg);
			StructInsert(dtl,"signed_url",this.baseurl&arguments.HTTPRequestURI&"?"&eqs&"&Signature="&sigg);
			setDebug(true);
			StructInsert(dtl,"result",sendRequest(dtl.signed_url));
			setDebug(false);
			
			return dtl;
		</cfscript>
	</cffunction>
	
	<cffunction name="dump" hint="Used for debugging with older versions of ColdFusion.">
		<cfargument name="x">
		<cfdump var="#arguments.x#">
		<Cfabort>
	</cffunction>
	
	
	
	<!--- Getters & Setters --->
	<cffunction name="getBaseurl" access="public" output="false" returntype="string">
		<cfreturn this.baseurl />
	</cffunction>

	<cffunction name="setBaseurl" access="public" output="false" returntype="void">
		<cfargument name="baseurl" type="string" required="true" />
		<cfset this.baseurl = arguments.baseurl />
		<cfreturn />
	</cffunction>

	<cffunction name="getAccesskey" access="public" output="false" returntype="string">
		<cfreturn this.accesskey />
	</cffunction>

	<cffunction name="setAccesskey" access="public" output="false" returntype="void">
		<cfargument name="accesskey" type="string" required="true" />
		<cfset this.accesskey = arguments.accesskey />
		<cfreturn />
	</cffunction>

	<cffunction name="getSecret" access="public" output="false" returntype="string">
		<cfreturn this.secret />
	</cffunction>

	<cffunction name="setSecret" access="public" output="false" returntype="void">
		<cfargument name="secret" type="string" required="true" />
		<cfset this.secret = arguments.secret />
		<cfreturn />
	</cffunction>

	<cffunction name="getSignatureversion" access="public" output="false" returntype="string">
		<cfreturn this.signatureversion />
	</cffunction>

	<cffunction name="setSignatureversion" access="public" output="false" returntype="void">
		<cfargument name="signatureversion" type="string" required="true" />
		<cfset this.signatureversion = arguments.signatureversion />
		<cfreturn />
	</cffunction>

	<cffunction name="getSignaturemethod" access="public" output="false" returntype="string">
		<cfreturn this.signaturemethod />
	</cffunction>

	<cffunction name="setSignaturemethod" access="public" output="false" returntype="void">
		<cfargument name="signaturemethod" type="string" required="true" />
		<cfset this.signaturemethod = arguments.signaturemethod />
		<cfreturn />
	</cffunction>

	<cffunction name="getMerchantid" access="public" output="false" returntype="string">
		<cfreturn this.merchantid />
	</cffunction>

	<cffunction name="setMerchantid" access="public" output="false" returntype="void">
		<cfargument name="merchantid" type="string" required="true" />
		<cfset this.merchantid = arguments.merchantid />
		<cfreturn />
	</cffunction>

	<cffunction name="getMarketplaceid" access="public" output="false" returntype="string">
		<cfreturn this.marketplaceid />
	</cffunction>

	<cffunction name="setMarketplaceid" access="public" output="false" returntype="void">
		<cfargument name="marketplaceid" type="string" required="true" />
		<cfset this.marketplaceid = arguments.marketplaceid />
		<cfreturn />
	</cffunction>

	<cffunction name="getUseragent" access="public" output="false" returntype="string">
		<cfreturn this.useragent />
	</cffunction>
	
	<cffunction name="setUseragent" access="public" output="false" returntype="void">
		<cfargument name="useragent" type="string" required="true" />
		<cfset this.useragent = arguments.useragent />
		<cfreturn />
	</cffunction>

	<cffunction name="getShowXmlResponse" access="public" output="false" returntype="string">
		<cfreturn this.showXmlResponse />
	</cffunction>
	
	<cffunction name="setShowXmlResponse" access="public" output="false" returntype="void">
		<cfargument name="showXmlResponse" type="boolean" required="true" />
		<cfset this.showXmlResponse = arguments.showXmlResponse />
		<cfreturn />
	</cffunction>
	
	<cffunction name="getDebug" access="public" output="false" returntype="string">
		<cfreturn this.debug />
	</cffunction>
	
	<cffunction name="setDebug" access="public" output="false" returntype="void">
		<cfargument name="debugger" type="boolean" required="true" />
		<cfset this.debug = arguments.debugger />
		<cfreturn />
	</cffunction>


</cfcomponent>
