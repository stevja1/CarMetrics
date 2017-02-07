package org.jaredstevens.components
{
	public class DateRange
	{
		private var _startDate:Date;
		private var _endDate:Date;
		
		public function DateRange( startDate:Date=null, endDate:Date=null)
		{
			if( startDate != null ) this._startDate = startDate;
			else this._startDate = null;
			if( endDate != null ) this._endDate = endDate;
			else this._endDate = null;
		}
		
		public function get startDate():Date
		{
			if( this._startDate == null ) this._startDate = new Date();
			return this._startDate;
		}
		
		public function set startDate( inDate:Date ):void
		{
			this._startDate = inDate;
		}
		
		public function get endDate():Date
		{
			if( this._endDate == null ) this._endDate = new Date();
			return this._endDate;
		}
		
		public function set endDate( inDate:Date ):void
		{
			this._endDate = inDate;
		}
	}
}