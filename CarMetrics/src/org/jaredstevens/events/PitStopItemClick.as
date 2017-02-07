package org.jaredstevens.events
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	
	public class PitStopItemClick extends Event
	{
		public static const ITEM_CLICKED:String = "itemClicked";
		public var recordId:int;
		public function PitStopItemClick( type:String, bubbles:Boolean=false, cancelable:Boolean=false, recordId:int=0 )
		{
			super( type, bubbles, cancelable );
			this.recordId = recordId;
		}
	}
}