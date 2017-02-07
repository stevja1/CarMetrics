package org.jaredstevens.itemrenderers
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.formatters.DateTimeFormatter;
	
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class PitStopDisplayItemRenderer extends LabelItemRenderer
	{
		private const PADDING:Number = 10;
		private const GAP:Number = 5;
		
		private var mileageId:int;
		
		private var dateLabel:StyleableTextField;
		private var fuelVolumeLabel:StyleableTextField;
		private var odometerLabel:StyleableTextField;
		private var fuelPriceLabel:StyleableTextField;
		
		public function PitStopDisplayItemRenderer()
		{
			//TODO: implement function
			super();
			this.percentWidth = 100;
		}
		
		/**
		 * @private
		 *
		 * Override this setter to respond to data changes
		 */
		override public function set data(value:Object):void
		{
			super.data = value;
			this.labelDisplay.text = '';
			// the data has changed.  push these changes down in to the 
			// subcomponents here
			if(value == null) return;
			if( value.hasOwnProperty('id') )
			{
				this.mileageId = value.id;
			} else this.mileageId = -1;
			if( value.hasOwnProperty('date') )
			{
				var formatter:DateTimeFormatter = new DateTimeFormatter;
				var dateString:String = "";
				formatter.dateTimePattern = "d MMM. yyyy";
				dateString = formatter.format( value.date );
				this.dateLabel.text = dateString;
			} else this.dateLabel.text = '';
			if( value.hasOwnProperty('odometer') )
			{
				this.odometerLabel.text = String( value.odometer );
			} else this.odometerLabel.text = "0";
			if( value.hasOwnProperty('fuelPrice') )
			{
				this.fuelPriceLabel.text = String( value.fuelPrice );
			} else this.fuelPriceLabel.text = "";
			if( value.hasOwnProperty('fuelVolume') )
			{
				this.fuelVolumeLabel.text = String( value.fuelVolume );
			} else this.fuelVolumeLabel.text = "";

			invalidateDisplayList();
		} 
		
		/**
		 * @private
		 * 
		 * Override this method to create children for your item renderer 
		 */	
		override protected function createChildren():void
		{
			super.createChildren();
			// create any additional children for your item renderer here
			if( !this.dateLabel )
			{
				this.dateLabel = new StyleableTextField();
				this.dateLabel.setStyle('color', 0xe6dfd8);
				this.dateLabel.setStyle("fontAntiAliasType", AntiAliasType.NORMAL);
				this.dateLabel.setStyle("fontGridFitType", GridFitType.NONE);
				this.dateLabel.editable = false;
				this.dateLabel.selectable = false;
				this.dateLabel.multiline = false;
				this.dateLabel.wordWrap = false;
				addChild( this.dateLabel );
			}
			if( !this.odometerLabel )
			{
				this.odometerLabel = new StyleableTextField();
				this.odometerLabel.setStyle('color', 0xe6dfd8);
				this.odometerLabel.setStyle("fontAntiAliasType", AntiAliasType.NORMAL);
				this.odometerLabel.setStyle("fontGridFitType", GridFitType.NONE);
				this.odometerLabel.editable = false;
				this.odometerLabel.selectable = false;
				this.odometerLabel.multiline = false;
				this.odometerLabel.wordWrap = false;
				this.addChild( this.odometerLabel );
			}
			if( !this.fuelVolumeLabel )
			{
				this.fuelVolumeLabel = new StyleableTextField();
				this.fuelVolumeLabel.setStyle('color', 0xe6dfd8);
				this.fuelVolumeLabel.setStyle("fontAntiAliasType", AntiAliasType.NORMAL);
				this.fuelVolumeLabel.setStyle("fontGridFitType", GridFitType.NONE);
				this.fuelVolumeLabel.editable = false;
				this.fuelVolumeLabel.selectable = false;
				this.fuelVolumeLabel.multiline = false;
				this.fuelVolumeLabel.wordWrap = false;
				this.addChild( this.fuelVolumeLabel );
			}
			if( !this.fuelPriceLabel )
			{
				this.fuelPriceLabel = new StyleableTextField();
				this.fuelPriceLabel.setStyle('color', 0xe6dfd8);
				this.fuelPriceLabel.setStyle("fontAntiAliasType", AntiAliasType.NORMAL);
				this.fuelPriceLabel.setStyle("fontGridFitType", GridFitType.NONE);
				this.fuelPriceLabel.editable = false;
				this.fuelPriceLabel.selectable = false;
				this.fuelPriceLabel.multiline = false;
				this.fuelPriceLabel.wordWrap = false;
				this.addChild( this.fuelPriceLabel );
			}
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the item renderer 
		 * sizes itself. For performance reasons, do not call 
		 * super.measure() unless you need to.
		 */ 
		override protected function measure():void
		{
			super.measure();
			// measure all the subcomponents here and set measuredWidth, measuredHeight, 
			// measuredMinWidth, and measuredMinHeight
			measuredWidth = 
				PADDING + this.dateLabel.getPreferredBoundsWidth() +
				GAP + this.odometerLabel.getPreferredBoundsWidth() +
				GAP + this.fuelVolumeLabel.getPreferredBoundsWidth() + 
				GAP + this.fuelPriceLabel.getPreferredBoundsWidth() + PADDING;
			
			measuredHeight = Math.max(
				dateLabel.getPreferredBoundsHeight(),
				odometerLabel.getPreferredBoundsHeight(),
				fuelVolumeLabel.getPreferredBoundsHeight(),
				fuelPriceLabel.getPreferredBoundsHeight()
			);
			
			measuredMinWidth = measuredWidth;
			measuredMinHeight = measuredHeight;
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the background is drawn for 
		 * item renderer.  For performance reasons, do not call 
		 * super.drawBackground() if you do not need to.
		 */
		override protected function drawBackground(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			super.drawBackground(unscaledWidth, unscaledHeight);
			// do any drawing for the background of the item renderer here      		
			// Choose green or red for the background color based on the stock's change value.
//			var backgroundColors:Array = [0x191919, 0x343434];
			
			// Create a matrix to rotate the background gradient 90 degrees.
//			var matrix:Matrix = new Matrix();
//			matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
			
			// Draw the gradient background.
//			graphics.beginGradientFill(GradientType.LINEAR, backgroundColors, [1.0, 1.0], [0, 255], matrix);
//			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
//			graphics.endFill();
		}
		
		/**
		 * @private
		 *  
		 * Override this method to change how the background is drawn for this 
		 * item renderer. For performance reasons, do not call 
		 * super.layoutContents() if you do not need to.
		 */
		override protected function layoutContents(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			// layout all the subcomponents here
			var vOffset:int = Math.max( this.dateLabel.getPreferredBoundsHeight(), this.odometerLabel.getPreferredBoundsHeight(), this.fuelVolumeLabel.getPreferredBoundsHeight(), this.fuelPriceLabel.getPreferredBoundsHeight() ) / 2;
			var middle:int = unscaledHeight / 2 - vOffset;
			var paddedWidth:int = unscaledWidth - (this.PADDING + this.GAP + this.GAP + this.GAP + this.PADDING);
			
			// 35%
			var dateWidth:int = Math.floor(paddedWidth * .35);
			
			// 25%
			var odometerWidth:int = Math.floor(paddedWidth * .25);
			
			// 20%
			var fuelVolumeWidth:int = Math.floor(paddedWidth * .2);
			var fuelPriceWidth:int = Math.floor(paddedWidth * .2);
			
			var hOffset:int = this.PADDING;
			this.setElementPosition( this.dateLabel, hOffset + (dateWidth - this.dateLabel.getPreferredBoundsWidth()), middle );
			
			hOffset += (dateWidth + this.GAP);
			this.setElementPosition( this.odometerLabel, hOffset + (odometerWidth - this.odometerLabel.getPreferredBoundsWidth()), middle );
			
			hOffset += (odometerWidth + this.GAP);
			this.setElementPosition( this.fuelVolumeLabel, hOffset + (fuelVolumeWidth - this.fuelVolumeLabel.getPreferredBoundsWidth()), middle );
			
			hOffset += (fuelVolumeWidth + this.GAP);
			this.setElementPosition( this.fuelPriceLabel, hOffset + (fuelPriceWidth - this.fuelPriceLabel.getPreferredBoundsWidth()), middle );
		}
		
	}
}