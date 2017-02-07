package org.jaredstevens.webservice
{
	import flash.net.URLVariables;
	
	import mx.rpc.AsyncToken;

	public class UserAPI extends CarMetricsWS
	{
		private static var className:String = "UserAPI";
		public function UserAPI()
		{
			super();
		}
		
		public static function getUserById( userId:int, successCallback:Function, errorCallback:Function ):void
		{
			var method:String = "getUserById";
			var params:URLVariables = new URLVariables();
			params.userId = userId;
			CarMetricsWS.makeRequest(UserAPI.className, method, params, successCallback, errorCallback);
		}
		
		public static function getUserByUsername( username:String, successCallback:Function, errorCallback:Function ):void
		{
			var method:String = "getUserByUsername";
			var params:URLVariables = new URLVariables();
			params.username = username;
			CarMetricsWS.makeRequest(UserAPI.className, method, params, successCallback, errorCallback);
		}

		public static function authenticate( username:String, password:String, successCallback:Function, errorCallback:Function ):void
		{
			var method:String = "authenticate";
			var params:URLVariables = new URLVariables();
			params.username = username;
			params.password = password;
			CarMetricsWS.makeRequest(UserAPI.className, method, params, successCallback, errorCallback);
		}
		
		public static function save(userId:int, username:String, password:String, firstName:String, lastName:String,
			email:String, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "save";
			var params:URLVariables = new URLVariables();
			if(userId > 0) params.userId = userId;
			else userId = -1;
			params.username = username;
			params.password = password;
			params.firstName = firstName;
			params.lastName = lastName;
			params.email = email;
			CarMetricsWS.makeRequest(UserAPI.className, method, params, successCallback, errorCallback);
		}
		
		public static function remove(userId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "remove";
			var params:URLVariables = new URLVariables();
			if(userId < 0) return;
			params.userId = userId;
			CarMetricsWS.makeRequest(UserAPI.className, method, params, successCallback, errorCallback);
		}
	}
}