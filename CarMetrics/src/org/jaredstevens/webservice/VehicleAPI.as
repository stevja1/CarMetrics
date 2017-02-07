package org.jaredstevens.webservice
{
	import flash.filesystem.File;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;

	public class VehicleAPI extends CarMetricsWS
	{
		private static var className:String = "VehicleAPI";
		public function VehicleAPI()
		{
			super();
		}
		
		public static function getVehicleById(vehicleId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "getVehicleById";
			var params:URLVariables = new URLVariables();
			params.vehicleId = vehicleId;
			CarMetricsWS.makeRequest(VehicleAPI.className, method, params, successCallback, errorCallback);
		}
		
		public static function getVehiclesByUserId(userId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "getVehiclesByUserId";
			var params:URLVariables = new URLVariables();
			params.userId = userId;
			CarMetricsWS.makeRequest(VehicleAPI.className, method, params, successCallback, errorCallback);
		}
		public static function getVehiclesAfterTransactionId(transactionId:int, userId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "getVehiclesAfterTransactionId";
			var params:URLVariables = new URLVariables();
			params.transactionQueryId = transactionId;
			params.userId = userId;
			CarMetricsWS.makeRequest(VehicleAPI.className, method, params, successCallback, errorCallback);
		}
		public static function save(vehicleId:int, userId:int, nickName:String, year:int, make:String, model:String, imageData:ByteArray,
			successCallback:Function, errorCallback:Function, progressCallback:Function=null):void
		{
			var method:String = "save";
			var params:URLVariables = new URLVariables();
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encodeBytes(imageData);
			params.vehicleId = vehicleId;
			params.userId = userId;
			params.nickName = nickName;
			params.year = year;
			params.make = make;
			params.model = model;
			params.imageData = encoder.toString();
			CarMetricsWS.makeRequest(VehicleAPI.className, method, params, successCallback, errorCallback, progressCallback);
		}
		public static function uploadImage(vehicleId:int, imageData:ByteArray, successCallback:Function, errorCallback:Function, progressCallback:Function=null):void
		{
			var method:String = "saveVehicleImage";
			var params:URLVariables = new URLVariables();
			params.vehicleId = vehicleId;
			params.imageData = imageData;
			CarMetricsWS.uploadImage(VehicleAPI.className, method, params, successCallback, errorCallback, progressCallback);
		}
		public static function remove(vehicleId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "remove";
			var params:URLVariables = new URLVariables();
			params.vehicleId = vehicleId;
			CarMetricsWS.makeRequest(VehicleAPI.className, method, params, successCallback, errorCallback);
		}
	}
}