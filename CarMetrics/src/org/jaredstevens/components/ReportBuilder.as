package org.jaredstevens.components
{
	import flash.data.SQLResult;
	import flash.events.SQLEvent;
	
	import mx.collections.ArrayCollection;
	
	import org.jaredstevens.db.MileageDAO;
	import org.jaredstevens.valueobjects.MileageRecord;

	public class ReportBuilder
	{
		public var error:Boolean;
		public var errorMessage:String;
		public var results:Array;
		
		public function ReportBuilder()
		{
			results = null;
		}

		public function getMileage( vehicleId:int, startDate:Date, endDate:Date, conn:MileageDAO, callback:Function ):void
		{
			this.results = null;
			conn.getRecords( vehicleId, startDate, endDate,
				function ( e:SQLEvent ):void
				{
					getMileageCallback( e, callback ); 
				}
			);
		}
		
		private function getMileageCallback( e:SQLEvent, callback:Function ):void
		{
			var results:SQLResult = e.target.getResult();
			
			// Get the data
			if( results.data != null )
			{
				for( var index:String in results.data )
				{
					if( this.results == null ) this.results = new Array();
					this.results.push( MileageDAO.recordFactory( results.data[index] ) );
				}
			}
			
			callback( e );
		}
		
		/**
		 * There are a few weird things we need to do here. We need to account for some edge cases.
		 * 1. Normal fillup
		 * 2. Top off
		 * 3. Partial fillup
		 * Partial fillups are especially annoying because they affect two records instead of just one.
		 * In order to handle these cases, we need the following information:
		 * 1. Standard deviation for miles traveled, noted as STDEVMT (Standard Deviation Miles Traveled)
		 * 2. Standard deviation for a vehicle's fuel capacity, noted as STDEVFP (Standard Deviation Fuel Purchased)
		 * 3. Fuel purchased noted as FP
		 * 4. Miles traveled noted as MT
		 * Here is how this logic will work for the numbered cases above:
		 * 1. Normal Fillup : MPG = MT / FP
		 * 2. Top off : MPG = MT / FP
		 * 3. Partial fillup : This is evident if the following cases occur
		 *   CASE: FP is outside of STDEV range for typical fuel purchased but mileage is within its range
		 *     MPG = MT / previous FP
		 *   CASE: MT is outside of STDEV range for typical vehicle range, but FP is within its range
		 *     MPG = MT / previous FP
		 */
		
		/**
		 * This method processes the data that came back from the database into something a mx chart can consume.
		 * @todo Break this into more methods
		 * @return ArrayCollection
		 */
		public function getMPGReportData():ArrayCollection
		{
			var retVal:ArrayCollection = new ArrayCollection();
			var averageFP:Number = 0; // FP = Fuel Purchased
			var averageMT:Number = 0; // MT = Miles Traveled
			var varianceFP:Number = 0;
			var varianceMT:Number = 0;
			var stddevFP:Number = 0;
			var stddevMT:Number = 0;
			var mileageRecord1:MileageRecord;
			var mileageRecord2:MileageRecord;
			
			// Make sure we have results to process
			if( this.results != null ) {
				var index:int = 0;
				// Find averages
				for( index = 0; index < this.results.length; ++index ) {
					if( index + 1 >= this.results.length ) break;
					mileageRecord1 = this.results[index]; // Newest record, with larger odometer reading
					mileageRecord2 = this.results[index+1]; // Older record
					
					// Sum the different values
					averageFP += mileageRecord1.fuelVolume;
					averageMT += mileageRecord1.odometer - mileageRecord2.odometer;
				}
				
				// Find the average (or mean)
				// We have to subtract one from the length because we can't count one of the records because we can't
				// get miles traveled for it. This is because the user hasn't entered an entry telling us how far they
				// got on that tank of gas (because it hasn't happened yet).
				averageFP = averageFP / (this.results.length - 1);
				averageMT = averageMT / (this.results.length - 1);
				
				// Find the variance
				for( index = 0; index < this.results.length; ++index ) {
					if( index + 1 >= this.results.length ) break;
					mileageRecord1 = this.results[index]; // Newest record, with larger odometer reading
					mileageRecord2 = this.results[index+1]; // Older record
					
					varianceFP += Math.pow(mileageRecord1.fuelVolume - averageFP, 2);
					varianceMT += Math.pow(mileageRecord1.odometer - mileageRecord2.odometer - averageMT, 2);
				}
				
				// Doing a sampe (that's where the -1 comes from) because this dataset doesn't represent all fillups
				varianceFP = varianceFP / (this.results.length - 1);
				varianceMT = varianceMT / (this.results.length - 1);
				
				// Find the STDDEV
				stddevFP = Math.sqrt(varianceFP);
				stddevMT = Math.sqrt(varianceMT);
				
				// Populate dataProvider
				var milesTraveled:Number = 0;
				var fuelPurchased:Number = 0;
				var fpInRange:Boolean = false;
				var mtInRange:Boolean = false;
				for( index = 0; index < this.results.length; ++index ) {
					if( index + 1 >= this.results.length ) break;
					mileageRecord1 = this.results[index]; // Newest record, with larger odometer reading
					mileageRecord2 = this.results[index+1]; // Older record
					
					var record:Object = new Object();
					milesTraveled = mileageRecord1.odometer - mileageRecord2.odometer;
					fuelPurchased = mileageRecord1.fuelVolume;
					
					/**
					 * 1. Normal Fillup : MPG = MT / FP
					 * 2. Top off : MPG = MT / FP
					 * 3. Partial fillup : This is evident if the following cases occur
					 *   CASE: FP is outside of STDEV range for typical fuel purchased but mileage is within its range
					 *     MPG = MT / previous FP
					 *   CASE: MT is outside of STDEV range for typical vehicle range, but FP is within its range
					 *     MPG = MT / previous FP
					 */
					fpInRange = this.isInRange(fuelPurchased, averageFP, stddevFP);
					mtInRange = this.isInRange(milesTraveled, averageMT, stddevMT);
					if((fpInRange && mtInRange) || (!fpInRange && !mtInRange)) {
						record.milesPerTank = milesTraveled;
						record.mileage = milesTraveled / fuelPurchased;
					} else if((fpInRange && !mtInRange) || (!fpInRange && mtInRange)) {
						record.milesPerTank = milesTraveled;
						record.mileage = milesTraveled / mileageRecord2.fuelVolume;
					}
					record.date = mileageRecord1.date;
					retVal.addItem( record );
				}
			}
			return retVal;
		}
		
		private function isInRange( value:Number, mean:Number, stddev:Number ):Boolean {
			var lowBound:Number = mean - stddev;
			var highBound:Number = mean + stddev;
			var retVal:Boolean;
			if(value >= lowBound) retVal = true;
			return retVal;
		}
		
		public function getMPGAverage():Number
		{
			var retVal:Number = 0;
			var maxMiles:int = 0;
			var minMiles:int = 0;
			var fuelVolumeTotal:Number = 0;
			
			// Make sure we have results to process
			if( this.results != null )
			{
				for( var index:int = 0; index < this.results.length; ++index )
				{
					if( index == 0 )
					{
						minMiles = this.results[index].odometer;
						maxMiles = this.results[index].odometer;
					}
					if( minMiles > this.results[index].odometer ) minMiles = this.results[index].odometer;
					if( maxMiles < this.results[index].odometer ) maxMiles = this.results[index].odometer;
					
					// We want to skip that last fuel entry. We're calculating differences in mileage,
					// but using the number of gallons on each fillup. As a result, if we count the very
					// last fillup, it skews the numbers because WE DON'T KNOW HOW MANY MILES WERE TRAVELED.
					if( index+1 < this.results.length )
						fuelVolumeTotal += this.results[index].fuelVolume;
				}
				retVal = (maxMiles - minMiles) / fuelVolumeTotal;
			}
			return retVal;
		}
	}
}