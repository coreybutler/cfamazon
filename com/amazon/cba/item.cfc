<cfcomponent hint="Represents an item." extends="com.amazon.factory" output="false">

	<cfproperty name="price" hint="The monetary cost of the item." type="numeric" />
	<cfproperty name="currencycode" hint="The currency of the price. Currently supports USD only." type="string" default="USD" />
	<cfproperty name="sku" hint="A SKU number assigned to the item." type="string" />
	<cfproperty name="quantity" hint="The quantity of this item to be purchased." type="numeric" default="1" />
	<cfproperty name="title" hint="The short description for your Item." type="string" />
	<cfproperty name="weight" hint="If defined, value must be between .01-99999.99" type="numeric" />
	<cfproperty name="weightUnit" hint="The unit weight type." type="string" default="lb" />
	<cfproperty name="description" hint="A description of the item." type="string" />
	<cfproperty name="condition" hint="The state of the item. Options include Any, Club, Collectible, New, Refurbished, Used" type="string" />
	<cfproperty name="images" hint="An array of images associated with the item." type="array" />
	<cfproperty name="shippingmethod" hint="Shipping methods." type="array" />
	<cfproperty name="promotions" hint="Promotions assigned to the item." type="array" />

	<cffunction name="init" hint="Initialize the item." access="public" output="false" returntype="void">
		<cfargument name="title" type="string" hint="The short description for your Item." required="true" />
		<cfargument name="price" type="numeric" hint="The monetary cost of the item." default="0" required="true" />
		<cfargument name="quantity" type="numeric" hint="The total number of this Item being purchased." default="1" required="false" />
		<cfscript>
			setTitle(arguments.title);
			setPrice(arguments.price);
			setQuantity(arguments.quantity);
			setCurrencyCode('USD');
			setWeightUnit('lb');
		</cfscript>
	</cffunction>	

	<cffunction name="calculateAmount" access="private" output="false" returntype="void">
		<cfscript>
			if(StructKeyExists(this,"quantity") and StructKeyExists(this,"price"))
				this.amount = this.quantity*this.price;
		</cfscript>
	</cffunction>

	<cffunction name="getPrice" access="public" output="false" returntype="numeric">
		<cfreturn this.price />
	</cffunction>

	<cffunction name="setPrice" access="public" output="false" returntype="void">
		<cfargument name="price" type="numeric" required="true" />
		<cfscript>
			this.price = arguments.price;
			calculateAmount();
		</cfscript>
	</cffunction>

	<cffunction name="getCurrencyCode" access="public" output="false" returntype="string">
		<cfreturn this.currencycode />
	</cffunction>

	<cffunction name="setCurrencyCode" access="public" output="false" returntype="void">
		<cfargument name="currencyCode" type="string" required="true" />
		<cfset this.currencycode = arguments.currencyCode />
		<cfreturn />
	</cffunction>

	<cffunction name="getSku" access="public" output="false" returntype="string">
		<cfreturn this.sku />
	</cffunction>

	<cffunction name="setSku" access="public" output="false" returntype="void">
		<cfargument name="sku" type="string" required="true" />
		<cfset this.sku = arguments.sku />
		<cfreturn />
	</cffunction>

	<cffunction name="getQuantity" access="public" output="false" returntype="numeric">
		<cfreturn this.quantity />
	</cffunction>

	<cffunction name="setQuantity" access="public" output="false" returntype="void">
		<cfargument name="quantity" type="numeric" required="true" />
		<cfscript>
			this.quantity = arguments.quantity;
			calculateAmount();
		</cfscript>
	</cffunction>

	<cffunction name="getTitle" access="public" output="false" returntype="string">
		<cfreturn this.title />
	</cffunction>

	<cffunction name="setTitle" access="public" output="false" returntype="void">
		<cfargument name="title" type="string" required="true" />
		<cfset this.title = arguments.title />
		<cfreturn />
	</cffunction>

	<cffunction name="getWeightUnit" access="public" output="false" returntype="string">
		<cfreturn this.weightUnit />
	</cffunction>

	<cffunction name="setWeightUnit" access="public" output="false" returntype="void">
		<cfargument name="weightUnit" type="string" required="true" />
		<cfset this.weightUnit = arguments.weightUnit />
		<cfreturn />
	</cffunction>
	
	<cffunction name="getWeight" access="public" output="false" returntype="string">
		<cfreturn this.weight />
	</cffunction>

	<cffunction name="setWeight" access="public" output="false" returntype="void">
		<cfargument name="weight" type="numeric" required="true" />
		<cfargument name="weightUnit" type="string" required="false" default="lb" />
		<cfscript>
			this.weight = arguments.weight;
			setWeightUnit(arguments.weightUnit);
		</cfscript>
		<cfreturn />
	</cffunction>

	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn this.description />
	</cffunction>

	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="description" type="string" required="true" />
		<cfset this.description = arguments.description />
		<cfreturn />
	</cffunction>

	<cffunction name="getCondition" access="public" output="false" returntype="string">
		<cfreturn this.condition />
	</cffunction>

	<cffunction name="setCondition" access="public" output="false" returntype="void">
		<cfargument name="condition" type="string" required="true" />
		<cfset this.condition = arguments.condition />
		<cfreturn />
	</cffunction>

	<cffunction name="getShippingmethod" access="public" output="false" returntype="array">
		<cfreturn this.shippingmethod />
	</cffunction>

	<cffunction name="setShippingmethod" access="public" output="false" returntype="void">
		<cfargument name="shippingmethod" type="array" required="true" />
		<cfset this.shippingmethod = arguments.shippingmethod />
		<cfreturn />
	</cffunction>

	<cffunction name="getPromotions" access="public" output="false" returntype="array">
		<cfreturn this.promotions />
	</cffunction>

	<cffunction name="setPromotions" access="public" output="false" returntype="void">
		<cfargument name="promotions" type="array" required="true" />
		<cfset this.promotions = arguments.promotions />
		<cfreturn />
	</cffunction>

</cfcomponent>