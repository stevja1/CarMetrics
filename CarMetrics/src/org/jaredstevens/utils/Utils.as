package org.jaredstevens.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	import spark.formatters.NumberFormatter;

	public class Utils
	{
		public function Utils()
		{
		}
		
		public static function loadGenericImage( bytes:ByteArray ):void {
			var file:File = new File("app:/assets/images/DefaultVehicleThumbnail.jpg");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			fs.readBytes(bytes);
			fs.close();
		}
		
		public static function getSavedProperty( propertyName:String ):String
		{
			var cache:SharedObject;
			var retVal:String = "";
			cache = SharedObject.getLocal("CarMetrics");
			if(cache.data[propertyName] != undefined)
				retVal = cache.data[propertyName];
			return retVal;
		}
		
		/**
		 * @todo Encrypt this stuff
		 */
		public static function saveProperty( propertyName:String, value:String ):Boolean
		{
			var cache:SharedObject;
			var retVal:Boolean = true;
			cache = SharedObject.getLocal("CarMetrics");
			cache.data[propertyName] = value;
			cache.flush(256);
			return retVal;
		}
		
		/**
		 * Converts a date in the string format yyyy-MM-dd HH:mm:ss to a date object, since the guys that
		 * wrote the standard AS3 date object were apparently too lazy to do this themselves.
		 * If we yyyy-MM-dd is just in the string, we create a date for that date at 00:00 in the morning.
		 * If the date string provided is empty or isn't parsable, a Date object containing the current
		 * date is returned.
		 * Because the format used in the parameter doesn't have any timezone information in it, the
		 * current timezone is used.
		 * @param String inDate Contains a date to parse in yyyy-MM-dd HH:mm:ss format.
		 * @return Date A date object set to the values in the parameter, or a date object representing
		 * the current time.
		 */
		public static function buildDate( inDate:String ):Date
		{
			var dayPart:String = "";
			var timePart:String = "";
			var dayParts:Array;
			var timeParts:Array;
			
			var year:int = -1;
			var month:int = -1;
			var day:int = -1;
			
			var hour:int = -1;
			var minute:int = -1;
			var second:int = -1;

			var retVal:Date;

			var dateParts:Array = inDate.split(' ');
			if( dateParts.length == 2 )
			{
				dayPart = dateParts[0];
				timePart = dateParts[1];
			}
			if( dayPart.length > 0 ) dayParts = dayPart.split('-');
			if( timePart.length > 0 ) timeParts = timePart.split(':');
			if( dayParts.length > 0 )
			{
				year = parseInt(dayParts[0]);
				month = parseInt(dayParts[1])-1;
				day = parseInt(dayParts[2]);
			}
			if( timeParts.length > 0 )
			{
				hour = parseInt(timeParts[0]);
				minute = parseInt(timeParts[1]);
				second = parseInt(timeParts[2]);
			}
			if( year > 0 && month >= 0 && day > 0 && hour >= 0 && minute >= 0 && second >= 0 )
				retVal = new Date( year, month, day, hour, minute, second );
			else if( year > 0 && month >= 0 && day > 0 )
				retVal = new Date( year, month, day );
			else retVal = new Date();
			return retVal;
		}
		
		/**
		 * This is used to automagically add commas and decimal points to numbers inside of text fields.
		 * Use the 'change' event on a text field to call a function that calls this function. Make sure
		 * you do a selectRange on the text field to move the carot to the end of the field after you set
		 * the new value. 
		 * @param String text The number you want to reformat
		 * @return String the formatted number
		 */
		public static function formatNumberField( text:String, trailingZeros:Boolean = true, commas:Boolean = true ):String
		{
//			var text:String = e.currentTarget.text;
			var num:int = 0;
			
			// Get rid of decimal point and commas
			text = text.replace( /[\.,]/g, '' );
			num = parseInt(text);
			var result:String = text;
			
			// Get rid of leading zeros
			text = String( num );
			
			// Add the decimal in the correct place
			if( trailingZeros )
			{
				if( num < 10 && num > -10 ) result = '0.0' + num;
				else if( num < 100 && num > -100 ) result = '0.' + num;
				else if( num >= 100 || num <= -100 )
				{
					result = text.substr( 0, text.length - 2 );
					result += '.' + text.substr( text.length - 2, 2 );
				}
			}
			
			// Add comma separators to make it pretty
			var formatter:NumberFormatter = new NumberFormatter();
			if( trailingZeros )
			{
				formatter.trailingZeros = true;
				formatter.fractionalDigits = 2;
			}
			result = formatter.format( result );
			
			// Set the text field with the new value and set the carat at the end of the field
//			e.currentTarget.text = result;
//			e.currentTarget.selectRange( e.currentTarget.text.length, e.currentTarget.text.length);
			return result;
		}
		
		public static function log( message:String ):void
		{
			var date:Date = new Date();
			trace( '[' + date.getTime() + '] ' + message );
		}
	}
}