package org.jaredstevens.components
{
	
	import org.jaredstevens.skins.bluesteel.PitStopDisplayItemSkin;
	import org.jaredstevens.utils.Utils;
	
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.formatters.DateTimeFormatter;
	import spark.formatters.NumberFormatter;
	
	
	
	public class PitStopDisplayItem extends SkinnableComponent
	{
		[SkinPart(required="true")] 
		public var dateDisplay:Label;
		
		[SkinPart(required="true")]
		public var odometerDisplay:Label;
		
		[SkinPart(required="true")]
		public var fuelVolumeDisplay:Label;

		[SkinPart(required="true")]
		public var priceDisplay:Label;

		private var internalDate:Date;
		private var internalFuelVolume:Number;
		private var internalOdometer:int;
		private var internalFuelPrice:Number;
		
		public var mileageId:int;
		[Bindable]
		public var dateString:String;
		[Bindable]
		public var fuelVolumeString:String;
		[Bindable]
		public var odometerString:String;
		[Bindable]
		public var fuelPriceString:String;
		
		private var numberFormatter:NumberFormatter;

		/**
		 * @todo Set the skin with a stylesheet somewhere with the rest of the skin
		 */
		public function PitStopDisplayItem()
		{
			super();
			this.internalDate = null;
			this.numberFormatter = new NumberFormatter();
			this.numberFormatter.trailingZeros = true;
		}
		
		public function set date( inDate:Date ):void
		{
			this.internalDate = inDate;

			var formatter:DateTimeFormatter = new DateTimeFormatter;
			var dateString:String = "";
			formatter.dateTimePattern = "d MMM. yyyy";
			dateString = formatter.format( inDate );
			this.dateString = dateString;
		}
		
		public function get date():Date
		{
			return this.internalDate;
		}
		
		public function set fuelVolume( inVolume:Number ):void
		{
			this.internalFuelVolume = inVolume;
			this.numberFormatter.fractionalDigits = 2;
			this.fuelVolumeString = this.numberFormatter.format( this.internalFuelVolume );
		}
		
		public function get fuelVolume():Number
		{
			return this.internalFuelVolume;
		}
		
		public function set odometer(value:int):void
		{
			internalOdometer = value;
			this.numberFormatter.fractionalDigits = 0;
			this.odometerString = this.numberFormatter.format( this.internalOdometer );
		}
		
		public function get odometer():int
		{
			return internalOdometer;
		}
		
		public function set fuelPrice(value:Number):void
		{
			internalFuelPrice = value;
			this.numberFormatter.fractionalDigits = 2;
			this.fuelPriceString = this.numberFormatter.format( this.internalFuelPrice );
		}
		
		public function get fuelPrice():Number
		{
			return internalFuelPrice;
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
	}
}