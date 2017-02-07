package org.jaredstevens.utils
{
	import org.jaredstevens.components.DateRange;

	public class DateUtils
	{
		public static const DAY:String = "day";
		public static const WEEK:String = "week";
		public static const MONTH:String = "month";
		public static const YEAR:String = "year";
		public static const NONE:String = "none";
		
		public static const daysInMonth:Array = new Array(31,28,31,30,31,30,31,31,30,31,30,31);
		
		public static const millisecondsPerSecond:int = 1000;
		public static const millisecondsPerMinute:int = 1000 * 60;
		public static const millisecondsPerHour:int = 1000 * 60 * 60;
		public static const millisecondsPerDay:int = 1000 * 60 * 60 * 24;
		public static const millisecondsPerWeek:int = 1000 * 60 * 60 * 24 * 7;

		public function DateUtils()
		{
		}
		
		public static function getDateRange( referenceDate:Date, dateOffset:int, dateOffsetType:String, dateRange:int, dateRangeType:String ):DateRange
		{
			// Initialize
			var retVal:DateRange = null;
			var internalReferenceDate:Date;
			var rangeType:String = DateUtils.NONE;
			var offsetType:String = DateUtils.NONE;
			
			// Validate input
			var granularities:Array = new Array( DateUtils.DAY, DateUtils.WEEK, DateUtils.MONTH, DateUtils.YEAR ); 
			if( granularities.indexOf( dateOffsetType ) >= 0 ) offsetType = dateOffsetType;
			if( granularities.indexOf( dateRangeType ) >= 0 ) rangeType = dateRangeType;
			if(
				(offsetType == DateUtils.NONE || rangeType == DateUtils.NONE) &&
				(dateOffset >= 0 && dateRange > 0)
			) return retVal;
			else if( dateRange == 0 ) return retVal;
			else retVal = new DateRange();
			
			// Initialize referenceDate to a date if needed and then to the beginning of the day
			// Doing a deep copy here so that we don't mess with referenceDate and affect it outside
			// this method.
			if( referenceDate == null )
			{
				internalReferenceDate = new Date();
			} else {
				internalReferenceDate = new Date( referenceDate );
			}
			
			var dayOffset:Number =
				internalReferenceDate.getHours() * DateUtils.millisecondsPerHour +
				internalReferenceDate.getMinutes() * DateUtils.millisecondsPerMinute +
				internalReferenceDate.getSeconds() * DateUtils.millisecondsPerSecond +
				internalReferenceDate.getMilliseconds();
			internalReferenceDate.setTime( internalReferenceDate.getTime() - dayOffset );
			
			/**
			 * Find the start date with the dateOffset/dateOffsetType
			 * An offset of zero means:
			 *   startDate(day) = today
			 *   startDate(week) = Sunday of this week
			 *   startDate(month) = The first day of the current month
			 *   startDate(year) = The first day of the current year
			 * An offset of one means:
			 *   startDate(day) = yesterday
			 *   startDate(week) = Sunday of last week
			 *   startDate(month) = The first day of last month
			 *   startDate(year) = The first day of last year
			 * If you want a rolling time period, use a type below the time period you want. For example:
			 *   If you want a rolling month, use a 4 week offset, (or 30 day offset)
			 *   If you want a rolling week, use a 7 day offset (that will include the same day last week as today).
			 */
			switch( dateOffsetType )
			{
				case DateUtils.DAY:
					retVal.startDate.setTime(internalReferenceDate.getTime() - (dateOffset * DateUtils.millisecondsPerDay));
					break;
				// Set start date to the beginning of the week
				// @todo Make this work
				case DateUtils.WEEK:
					// Calculate for zero offset (current week)
					retVal.startDate.setTime(internalReferenceDate.getTime() - (internalReferenceDate.getDay() * DateUtils.millisecondsPerDay));
					
					// Apply any additional offset
					retVal.startDate.setTime(retVal.startDate.getTime() - (dateOffset * DateUtils.millisecondsPerWeek));
					break;
				// This one is tricky since the offset isn't constant (28, 29, 30, 31 days in certain months).
				// @todo Account for other month offsets depending on the month (and leap year)
				case DateUtils.MONTH:
					retVal.startDate.setTime(internalReferenceDate.getTime() - (internalReferenceDate.getDate() * DateUtils.millisecondsPerDay));
					break;
				// This one is tricky since the offset isn't constant either (leap year).
				// @todo Account for offsets that span a leap year
				case DateUtils.YEAR:
					break;
				default:
					break;
			}
			
			// Find the end date with the dateRange/dateRangeType
			switch( dateRangeType )
			{
				case DateUtils.DAY:
					retVal.endDate.setTime(retVal.startDate.getTime() + (dateRange * DateUtils.millisecondsPerDay)-1);
					break;
				case DateUtils.WEEK:
					retVal.endDate.setTime(retVal.startDate.getTime() + (dateRange * DateUtils.millisecondsPerWeek)-1);
					break;
				case DateUtils.MONTH:
					break;
				case DateUtils.YEAR:
					break;
				default:
					break;
			}
			DateUtils.adjustForDSTDate( retVal.startDate );
			DateUtils.adjustForDSTDate( retVal.endDate );

			return retVal;
		}
		
		private static function adjustForDSTDate( inDate:Date ):Date
		{
			if( inDate.getHours() == 23 && inDate.getMinutes() == 0 ) inDate.setTime( inDate.getTime() + 3600000 );
			else if( inDate.getHours() == 1 && inDate.getMinutes() == 0 ) inDate.setTime( inDate.getTime() - 3600000 );
			return inDate;
		}
		
		public static function isLeapYear( year:uint ):Boolean
		{
			var retVal:Boolean = false;
			// If the year is divisible by 100 and 400 its a leap year
			if( year % 4 == 0 && year % 100 == 0 && year % 400 == 0 ) return true;
				// If the year is divisible by 4 and not by 100, its a leap year
			else if( year % 4 == 0 && year % 100 != 0 ) retVal = true;
			return retVal;
		}
	}
}