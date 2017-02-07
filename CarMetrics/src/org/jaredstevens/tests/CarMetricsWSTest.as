package org.jaredstevens.tests
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLVariables;
	
	import flexunit.framework.Assert;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jaredstevens.webservice.CarMetricsWS;
	
	public class CarMetricsWSTest
	{		
		[Test]
		public function testMakeRequest():void
		{
			var classname:String = "UserAPI";
			var method:String = "getUserById";
			var params:URLVariables = new URLVariables();
			params.userId = 2;
			CarMetricsWS.makeRequest( classname, method, params,
				function(evt:Event):void {
					var rawResponse:Object;
					if(evt.currentTarget.data != null && evt.currentTarget.data.length > 0)
						rawResponse = CarMetricsWS.parseResponse(evt.currentTarget.data);
					if(rawResponse != null) {
						Assert.assertEquals(rawResponse.user.firstName, "Jared");
					} else Assert.assertNotNull(rawResponse);
				}, function(evt:IOErrorEvent):void {
					Assert.fail("Got a bad response.");
				});
		}
		
		[Test]
		public function testSave():void
		{
			var classname:String = "UserAPI";
			var method:String = "save";
			var params:URLVariables = new URLVariables();
			params.userId = 2;
			params.username = "jstevens";
			params.firstName = "Jared";
			params.lastName = "Stevens";
			params.email = "stevja1@yahoo.com";
			params.password = "h0ver5";
			
			CarMetricsWS.makeRequest( classname, method, params,
				function(evt:Event):void {
					var rawResponse:Object;
					if(evt.currentTarget.data != null && evt.currentTarget.data.length > 0)
						rawResponse = CarMetricsWS.parseResponse(evt.currentTarget.data);
					if(rawResponse != null) {
						Assert.assertEquals(rawResponse.user.firstName, "Jared");
					} else Assert.assertNotNull(rawResponse);
				}, function(evt:IOErrorEvent):void {
					Assert.fail("Couldn't query the server.");
				});
		}
		
		[Test]
		public function testParseResponse():void
		{
			var testJson:String = '{"id":5,"name":"Jared"}';
			var result:Object = CarMetricsWS.parseResponse(testJson);
			Assert.assertEquals(result.id, 5);
			Assert.assertEquals(result.name, "Jared");
		}
	}
}