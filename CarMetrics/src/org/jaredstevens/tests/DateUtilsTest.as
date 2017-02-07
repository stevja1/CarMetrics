package org.jaredstevens.tests
{
	import flexunit.framework.Assert;
	
	import org.jaredstevens.components.DateRange;
	import org.jaredstevens.utils.DateUtils;
	import org.jaredstevens.db.MileageDAO;
	import org.jaredstevens.db.VehiclesDAO;
	import org.jaredstevens.utils.DateUtils;
	
	public class DateUtilsTest
	{
		private var mileageDAO:MileageDAO;
		private var vehicleDAO:VehiclesDAO;
		
		[Before]
		public function setUp():void
		{
			this.mileageDAO = new MileageDAO();
			this.vehicleDAO = new VehiclesDAO();
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testGetDateRange():void
		{
			// 2012-05-26 19:45:17
			var referenceDate:Date = new Date( 2012, 4, 26, 19, 45, 17 );
			var dateRange:DateRange = null;
			var offset:int;
			var range:int;
			
			// Test leap year
			var leapYear:Boolean;
			leapYear = DateUtils.isLeapYear( 1600 );
			Assert.assertEquals( leapYear, true );
			leapYear = DateUtils.isLeapYear( 1700 );
			Assert.assertEquals( leapYear, false );
			leapYear = DateUtils.isLeapYear( 1800 );
			Assert.assertEquals( leapYear, false );
			leapYear = DateUtils.isLeapYear( 1900 );
			Assert.assertEquals( leapYear, false );
			leapYear = DateUtils.isLeapYear( 2000 );
			Assert.assertEquals( leapYear, true );
			leapYear = DateUtils.isLeapYear( 2004 );
			Assert.assertEquals( leapYear, true );
			leapYear = DateUtils.isLeapYear( 2016 );
			Assert.assertEquals( leapYear, true );
			
			// This should fail - a range of zero isn't allowed
			offset = 0;
			range = 0; // Ranges of zero aren't allowed - this should fail
			dateRange = DateUtils.getDateRange( referenceDate, offset, DateUtils.DAY, range, DateUtils.DAY );
			Assert.assertEquals( dateRange, null );
			
			// Should give me a date range of 1 day, starting on 5/26/2012 00:00:00.000 and ending on 5/26/2012 23:59:59.999
			offset = 0;
			range = 1;
			dateRange = DateUtils.getDateRange( referenceDate, offset, DateUtils.DAY, range, DateUtils.DAY );
			Assert.assertEquals( dateRange.startDate.getTime(), 1338012000000 );
			Assert.assertEquals( dateRange.endDate.getTime(),  1338098399999 );
			
			// Should give me a date range of 1 day, starting on 5/25/2012 00:00:00.000 and ending on 5/25/2012 23:59:59.999
			offset = 1;
			range = 1;
			dateRange = DateUtils.getDateRange( referenceDate, offset, DateUtils.DAY, range, DateUtils.DAY );
			Assert.assertEquals( dateRange.startDate.getTime(), 1337925600000 );
			Assert.assertEquals( dateRange.endDate.getTime(), 1338011999999 );

			// Should give me a date range of 7 days, starting on 5/19/2012 00:00:00.000 and ending on 5/25/2012 23:59:59.999
			offset = 7;
			range = 7;
			dateRange = DateUtils.getDateRange( referenceDate, offset, DateUtils.DAY, range, DateUtils.DAY );
			Assert.assertEquals( dateRange.startDate.getTime(), 1337407200000 );
			Assert.assertEquals( dateRange.endDate.getTime(), 1338011999999 );
			
			// Should give me a date range of 7 days, starting on 5/20/2012 00:00:00.000 and ending on 5/26/2012 23:59:59.999
			// @todo Make this work
			offset = 0;
			range = 1;
			dateRange = DateUtils.getDateRange( referenceDate, offset, DateUtils.WEEK, range, DateUtils.WEEK );
			Assert.assertEquals( dateRange.startDate.getTime(), 1337493600000 );
			Assert.assertEquals( dateRange.endDate.getTime(), 1338098399999 );
			
			// Should give me a date range of 7 days, starting on 5/13/2012 00:00:00.000 and ending on 5/19/2012 23:59:59.999
			offset = 1;
			range = 1;
			dateRange = DateUtils.getDateRange( referenceDate, offset, DateUtils.WEEK, range, DateUtils.WEEK );
			Assert.assertEquals( dateRange.startDate.getTime(), 1336888800000 );
			Assert.assertEquals( dateRange.endDate.getTime(), 1337493599999 );

			// Should give me a date range of 12 weeks, starting on 2/26/2012 00:00:00.000 and ending on 5/19/2012 23:59:59.999
			// This will test handling of daylight savings time starting on 3/11/2012
			offset = 12;
			range = 12;
			dateRange = DateUtils.getDateRange( referenceDate, offset, DateUtils.WEEK, range, DateUtils.WEEK );
			Assert.assertEquals( dateRange.startDate.getTime(), 1330239600000 );
			Assert.assertEquals( dateRange.endDate.getTime(), 1337493599999 );
			
			// 11/26/2012 19:45:17
			referenceDate = new Date( 2012, 10, 26, 19, 45, 17 );
			// Should give me a date range of 9 weeks, starting on 9/23/2012 00:00:00.000 and ending on 11/24/2012 23:59:59.999
			// Test handling of the end of DST
			offset = 9;
			range = 9;
			dateRange = DateUtils.getDateRange( referenceDate, offset, DateUtils.WEEK, range, DateUtils.WEEK );
			Assert.assertEquals( dateRange.startDate.getTime(), 1348380000000 );
			Assert.assertEquals( dateRange.endDate.getTime(), 1353826799999 );
		}
	}
}