<h1>About CFAmazon</h1>

- [CFAmazon SlideShare Overview](http://www.slideshare.net/goldglovecb/cfamazon-7608436)
- [Creating an Amazon Payments Seller Account](https://medium.com/tech-recipes/10450941c42c)
- [Using ColdFusion with Amazon Payments](https://medium.com/tech-recipes/6a08bdcc0989)

CFAmazon is a collection of ColdFusion code wrappers and examples designed to get you started with different Amazon web services. It was originally created by [Corey Butler](http://github.com/coreybutler) to simplify working with the Amazon Payments API and Merchant Web Services.

<h2>Checkout By Amazon (CBA)</h2>
This library contains component wrappers for Checkout By Amazon. It can be used for:

<ol>
<li><b>Signing XML Carts:</b></li>
Checkout By Amazon uses XML-based carts, which must be signed and transmitted securely. The cart.cfc object provides simple CF methods for creating a cart, 
modifying its contents, generating the XML, and signing the cart. 
<li><b>Instant Payment Notification:</b></li>
Examples for using IPN are included. IPN is used to notify you of new orders, cancellations, and other events you may want to respond to. This is commonly used for logging orders in
your own system, integrating with other systems, or providing any additional custom functionality to the order process. 
<li><b>Using the Callback API:</b></li>
The Order Callback API is used to dynamically calculate taxes, shipping methods/rates, and apply custom promotional discounts.
</ol>

<h2>Marketplace Web Services</h2>
This library contains component wrappers for the MWS services from Amazon. This is a prerelease version supporting feed submissions,
reports, and scheduling. To install, simply drop the com folder in your webroot. Make sure you modify the examples to use
your own merchant ID, marketplace, access key, security key, etc. For convenience, modify mws-config.cfm (found in the mws examples)
and all of the examples should work. For feed submissions, make sure you are using valid XML according to the XSD specifications
provided by Amazon.<br/>
<i>This part of the library is in active development. Due to the size, we are requesting feedback to know how people are using it before finalizing this part of the library.</i>

<h2>Reading the code</h2><br/>
The source code and all of the examples are dependent on your configuration. I use a build file that
does a simple find/replace across all files. The following legend is provided for clarification:

<b>@ID</b>: ACCESSKEY<br/>
<b>@SECRET</b>: SECRETKEY<br/>
<b>@MERCHANT</b>: Merchant ID (ex: AEIOU1234AEIOU)<br/>
<b>@MERCHANTTOKEN</b>: Merchant TOKEN<br/>
<b>@EMAILTO</b>:IPN Notification receipient email address (demo purposes only)<br/>
<b>@EMAILFROM</b>:IPN Notification sender email address (demo purposes only)<br/>
<b>@CALLBACKURL</b>:The URL used in he Callback API

Please see the wiki for more information.
