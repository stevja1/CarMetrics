package org.jaredstevens.valueobjects
{
	import org.jaredstevens.utils.Utils;

	public class MileageRecord
	{
		[Bindable]
		public var id:int;
		[Bindable]
		public var serverId:int;
		[Bindable]
		public var vehicleId:int;
		[Bindable]
		public var date:Date;
		[Bindable]
		public var fuelVolume:Number;
		[Bindable]
		public var odometer:int;
		[Bindable]
		public var fuelPrice:Number;
		[Bindable]
		public var latitude:Number;
		[Bindable]
		public var longitude:Number;
		
		public function MileageRecord( id:int=-1, serverId:int=-1, vehicleId:int=-1, date:Date=null, fuelVolume:Number=-1, odometer:int=-1, fuelPrice:Number=-1, latitude:Number=0, longitude:Number=0 )
		{
			this.id = id;
			this.serverId = serverId;
			this.vehicleId = vehicleId;
			this.date = date;
			this.fuelVolume = fuelVolume;
			this.odometer = odometer;
			this.fuelPrice = fuelPrice;
			this.latitude = latitude;
			this.longitude = longitude;
		}
		public static function initializeFromObject( mileage:Object ):MileageRecord
		{
			var retVal:MileageRecord = null;
			var date:Date;
			if(mileage.hasOwnProperty('id') && mileage.hasOwnProperty('serverId')
				&& mileage.hasOwnProperty('vehicleId') && mileage.hasOwnProperty('date')
				&& mileage.hasOwnProperty('fuelVolume') && mileage.hasOwnProperty('odometer')
				&& mileage.hasOwnProperty('fuelPrice') && mileage.hasOwnProperty('latitude')
				&& mileage.hasOwnProperty('longitude'))
			{
				if( mileage.date is Date ) date = mileage.date;
				else date = Utils.buildDate(mileage.date);
				retVal = new MileageRecord(mileage.id, mileage.serverId, mileage.vehicleId, mileage.date, mileage.fuelVolume, mileage.odometer, mileage.fuelPrice, mileage.latitude, mileage.longitude);
			}
			return retVal;
		}
	}
}