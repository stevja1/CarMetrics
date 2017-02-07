package org.jaredstevens.components
{
	import flash.display.Shape;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	
	public class SimpleLineChart extends UIComponent
	{
		private var _data:ArrayList;
		
		public var xField:String;
		public var yField:String;
		
		public function SimpleLineChart()
		{
			super();
		}
		
		public function set data( inData:ArrayList ):void
		{
			this._data = inData;
			this.invalidateDisplayList();
		}
		
		public function get data():ArrayList
		{
			return this._data;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
		}
		
		/**
		 * Finds the maximum value in the set (based on this.yValue) and returns its index in the array.
		 * If this method fails, its probably because the this.yField hasn't been set or isn't valid.
		 * If there are two values that are the same that are the maximum value, this method will return the
		 * index of the first.
		 * @todo Need to find a sane way to test this code
		 * @return String Contains the index on success, an empty string on failure.
		 */
		private function getMax():String
		{
			var retVal:String = '';
			var element:Object;
			var currentMax:Number = 0;
			var value:Number = 0;
			var indexOfMax:String = '';
			var firstLoop:Boolean = true;
			for( var index:String in this._data.source )
			{
				value = 0;
				element = this._data.source[index];
				if( this.yField.length > 0 )
				{
					if( element.hasOwnProperty( this.yField ) ) value = element[this.yField];
					if( firstLoop )
					{
						currentMax = value;
						indexOfMax = index;
						firstLoop = false;
						continue;
					}
					if( value > currentMax )
					{
						currentMax = value;
						indexOfMax = index;
					}
				}
			}
			if( indexOfMax.length > 0 ) retVal = indexOfMax;
			return retVal;
		}
		
		/**
		 * Finds the maximum value in the set (based on this.yValue) and returns its index in the array.
		 * If this method fails, its probably because the this.yField hasn't been set or isn't valid.
		 * If there are two values that are the same that are the maximum value, this method will return the
		 * index of the first.
		 * @todo Need to find a sane way to test this code
		 * @return String Contains the index on success, an empty string on failure.
		 */
		private function getMin():String
		{
			var retVal:String = '';
			var element:Object;
			var currentMin:Number = 0;
			var value:Number = 0;
			var indexOfMin:String = '';
			var firstLoop:Boolean = true;
			for( var index:String in this._data.source )
			{
				value = 0;
				element = this._data.source[index];
				if( this.yField.length > 0 )
				{
					if( element.hasOwnProperty( this.yField ) ) value = element[this.yField];
					if( firstLoop )
					{
						currentMin = value;
						indexOfMin = index;
						firstLoop = false;
						continue;
					}
					if( value < currentMin )
					{
						currentMin = value;
						indexOfMin = index;
					}
				}
			}
			if( indexOfMin.length > 0 ) retVal = indexOfMin;
			return retVal;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			this.drawChart( unscaledWidth, unscaledHeight );
		}
		
		/**
		 * We need to know the height of the component that we're drawing a chart to
		 */
		private function drawChart( chartWidth:int, chartHeight:int ):void
		{
			// Clear old data
			this.graphics.clear();
			
			// Set a line stroke
			this.graphics.lineStyle( 3, 0x565656 );
			
			// Figure out the min/max y value that we have to deal with
			var min:Number = 0;
			var max:Number = 0;
			var minIndex:String = this.getMin();
			var maxIndex:String = this.getMax();
			if( minIndex.length > 0 && maxIndex.length > 0 )
			{
				min = this._data.source[minIndex][this.yField];
				max = this._data.source[maxIndex][this.yField];
			}
			if( min == max ) return;
			
			var yRatio:Number;
			var xStepSize:int;
			if( min >= 0 ) yRatio = chartHeight / max;
			else if( min < 0 ) yRatio = chartHeight / (max - min);
			xStepSize = Math.floor( chartWidth / (this._data.length - 1) );
			
			// Iterate through the values
			var yValue:Number;
			var xValue:String;
			var xPos:int = 0;
			var yPos:int = 0;
			var firstLoop:Boolean = true;
			for( var index:String in this._data.source )
			{
				// -- Calculate how the y-value translates to our coordinate system
				yValue = this._data.source[index][this.yField];
				yPos = chartHeight - (Math.floor(yValue * yRatio));
				
				if( firstLoop )
				{
					this.graphics.moveTo( xPos, yPos );
					xPos += xStepSize;
					firstLoop = false;
					continue;
				}
				
				// -- Run a lineTo statement
				this.graphics.lineTo( xPos, yPos );
				xPos += xStepSize;
			}
		}
	}
}