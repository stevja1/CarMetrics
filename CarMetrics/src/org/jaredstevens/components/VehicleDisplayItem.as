package org.jaredstevens.components
{
	
	import flash.utils.ByteArray;
	
	import org.jaredstevens.skins.bluesteel.VehicleDisplayItemSkin;
	
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class VehicleDisplayItem extends SkinnableComponent
	{
		[SkinPart(required="true")] 
		public var nickNameDisplay:Label;
		
		[SkinPart(required="true")]
		public var vehicleInfoDisplay:Label;
		
		[SkinPart(required="true")]
		public var thumbnailDisplay:Image;

		[Bindable]
		public var vehicleId:int;
		
		[Bindable]
		public var nickName:String;
		
		[Bindable]
		public var make:String;
		
		[Bindable]
		public var model:String;
		
		[Bindable]
		public var year:String;
		
		[Bindable]
		public var imageData:ByteArray;
		
		/**
		 * @todo Set the skin with a stylesheet somewhere with the rest of the skin
		 */
		public function VehicleDisplayItem()
		{
			super();
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