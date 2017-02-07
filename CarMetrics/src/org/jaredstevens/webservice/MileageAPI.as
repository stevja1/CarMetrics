package org.jaredstevens.webservice
{
	import flash.net.URLVariables;

	public class MileageAPI extends CarMetricsWS
	{
		private static var className:String = "MileageAPI";
		public function MileageAPI()
		{
			super();
		}
		public static function getMileageById(mileageId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "getMileageById";
			var params:URLVariables = new URLVariables();
			params.mileageId = mileageId;
			CarMetricsWS.makeRequest(MileageAPI.className, method, params, successCallback, errorCallback);
		}
		public static function getMileageByVehicleId(vehicleId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "getMileageByVehicleId";
			var params:URLVariables = new URLVariables();
			params.vehicleId = vehicleId;
			CarMetricsWS.makeRequest(MileageAPI.className, method, params, successCallback, errorCallback);
		}
		public static function getMileageAfterTransactionId(transactionId:int, vehicleId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "getMileageAfterTransactionId";
			var params:URLVariables = new URLVariables();
			params.transactionQueryId = transactionId;
			params.vehicleId = vehicleId;
			CarMetricsWS.makeRequest(MileageAPI.className, method, params, successCallback, errorCallback);
		}
		public static function save(mileageId:int, vehicleId:int, fillupDate:Date, fuelVolume:Number, fuelPrice:Number, odometer:int, latitude:Number, longitude:Number, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "save";
			var params:URLVariables = new URLVariables();
			params.mileageId = mileageId;
			params.fillupDate = fillupDate.time;
			params.vehicleId = vehicleId;
			params.fuelVolume = fuelVolume;
			params.fuelPrice = fuelPrice;
			params.odometer = odometer;
			params.latitude = latitude;
			params.longitude = longitude;
			CarMetricsWS.makeRequest(MileageAPI.className, method, params, successCallback, errorCallback);
		}
		public static function remove(mileageId:int, successCallback:Function, errorCallback:Function):void
		{
			var method:String = "remove";
			var params:URLVariables = new URLVariables();
			params.mileageId = mileageId;
			CarMetricsWS.makeRequest(MileageAPI.className, method, params, successCallback, errorCallback);
		}
	}
}