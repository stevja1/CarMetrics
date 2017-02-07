package org.jaredstevens.valueobjects
{
	import flash.utils.ByteArray;

	public class VehicleRecord
	{
		[Bindable]
		public var id:int;
		[Bindable]
		public var serverId:int;
		[Bindable]
		public var nickName:String;
		[Bindable]
		public var year:int;
		[Bindable]
		public var make:String;
		[Bindable]
		public var model:String;
		[Bindable]
		public var imageData:ByteArray;
		
		public function VehicleRecord( id:int=-1, serverId:int=-1, nickName:String="", year:int=0, make:String="", model:String="", imageData:ByteArray=null )
		{
			this.id = id;
			this.serverId = serverId;
			this.nickName = nickName;
			this.year = year;
			this.make = make;
			this.model = model;
			this.imageData = imageData;
		}
		public static function initializeFromObject( vehicle:Object ):VehicleRecord
		{
			var retVal:VehicleRecord = null;
			if(vehicle.hasOwnProperty('id') && vehicle.hasOwnProperty('serverId')
				&& vehicle.hasOwnProperty('nickName') && vehicle.hasOwnProperty('year')
				&& vehicle.hasOwnProperty('make') && vehicle.hasOwnProperty('model')
				&& vehicle.hasOwnProperty('imageData'))
			{
				retVal = new VehicleRecord(vehicle.id, vehicle.serverId, vehicle.nickName, vehicle.year, vehicle.make, vehicle.model, vehicle.imageData);
			}
			return retVal;
		}
	}
}