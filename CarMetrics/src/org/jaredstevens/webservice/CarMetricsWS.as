package org.jaredstevens.webservice
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.hamcrest.core.throws;

	public class CarMetricsWS
	{
		private static var SERVICE_URL:String = "http://api.jaredstevens.org/CarMetricsWS/conduit/";
//		private static var SERVICE_URL:String = "http://192.168.100.15:8080/CarMetricsWS/conduit/";
//		private static var SERVICE_URL:String = "http://localhost:8080/CarMetricsWS/conduit/";
//		private static var SERVICE_URL:String = "http://192.168.100.4:8080/CarMetricsWS/conduit/";
		private static var protocol:String = "text";
		
		public static function makeRequest( classname:String, method:String, params:URLVariables,
			successCallback:Function, failureCallback:Function, progressCallback:Function=null ):void
		{
			var url:String = CarMetricsWS.SERVICE_URL+classname+"."+method+".action";
			var service:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			service.data = params;
			service.method = URLRequestMethod.POST;
			if( progressCallback != null )
				loader.addEventListener(ProgressEvent.PROGRESS, progressCallback);
			loader.addEventListener(Event.COMPLETE, successCallback);
			loader.addEventListener(IOErrorEvent.IO_ERROR, failureCallback);
			loader.load(service);
		}

		public static function uploadImage( classname:String, method:String, params:URLVariables,
											successCallback:Function, failureCallback:Function, progressCallback:Function=null ):void
		{
			var url:String = CarMetricsWS.SERVICE_URL+classname+"."+method+".input";
			var service:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			service.data = params;
			service.method = URLRequestMethod.POST;
			//			service.contentType = "application/octet-stream";
			service.contentType = "multipart/form-data";
			if( progressCallback != null )
				loader.addEventListener(ProgressEvent.PROGRESS, progressCallback);
			loader.addEventListener(Event.COMPLETE, successCallback);
			loader.addEventListener(IOErrorEvent.IO_ERROR, failureCallback);
			loader.load(service);
		}
		
		public static function makeRequest_OLD( classname:String, method:String, params:Object, successCallback:Function,
			failureCallback:Function ):AsyncToken
		{
			var service:HTTPService = new HTTPService();
			if(service == null) return null;
			var url:String = CarMetricsWS.SERVICE_URL+classname+"."+method+".action";
			service.url = url;
			service.resultFormat = CarMetricsWS.protocol;
			service.addEventListener(ResultEvent.RESULT, successCallback);
			service.addEventListener(FaultEvent.FAULT, failureCallback);
			var token:AsyncToken = service.send(params);
			return token;
		}
		
		public static function parseResponse( response:String ):Object
		{
			var retVal:Object = null;
			try {
				retVal = JSON.parse(response);
			} catch( e:Error ) {
			}
			return retVal;
		}
	}
}