package org.jaredstevens.db
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	public class MaintenanceDAO
	{
		public var conn:SQLConnection;
		
		public function MaintenanceDAO()
		{
		}

		public function open( initializedCallback:Function = null, errorCallback:Function = null ):void
		{
			if( this.conn == null )
			{
				var db:File = File.applicationStorageDirectory.resolvePath("CarMetrics.db");
				this.conn = new SQLConnection();
				this.conn.openAsync( db );
			}
			if( initializedCallback == null ) this.conn.addEventListener(SQLEvent.OPEN, this.initializeCall );
			else this.conn.addEventListener(SQLEvent.OPEN, initializedCallback );
			if( errorCallback == null ) this.conn.addEventListener(SQLErrorEvent.ERROR, this.error);
			else this.conn.addEventListener(SQLErrorEvent.ERROR, errorCallback);
		}
		
		public function initializeCall( e:SQLEvent = null, callback:Function = null ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null ) sql.addEventListener(SQLEvent.RESULT, this.initializeResponse );
			else sql.addEventListener(SQLEvent.RESULT, callback );

			sql.text = 
				"CREATE TABLE IF NOT EXISTS maintenance ( "+
				"id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "+
				"vehicleId INTEGER UNSIGNED NOT NULL, "+
				"mileage INTEGER UNSIGNED NOT NULL, "+
				"date TEXT NOT NULL, "+
				"cost REAL UNSIGNED NOT NULL, "+
				"note TEXT NOT NULL, "+
				"receiptImage TEXT NOT NULL"+ 
				");";
			sql.execute();
		}
		
		public function addMaintenanceRecord( vehicleId:int, date:Date, cost:Number, note:String, receiptImage:String, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.insertResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = 
				"INSERT INTO maintenance (vehicleId, date, cost, note, receiptImage) VALUES (@vehicleId, @date, @cost, @note, @receiptImage )";
			sql.parameters["@vehicleId"] = vehicleId;
			sql.parameters["@date"] = date;
			sql.parameters["@cost"] = cost;
			sql.parameters["@note"] = note;
			sql.parameters["@receiptImage"] = receiptImage;
			sql.execute();
		}
		
		/**
		 * @todo Make the start date and end date parameters work properly.
		 * @todo Process null values for the start and end date
		 */
		public function getMaintenanceRecords( startDate:Date, endDate:Date, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM maintenance WHERE date >= @startDate AND date <= endDate";
			sql.parameters["@startDate"] = startDate;
			sql.parameters["@endDate"] = endDate;
			sql.execute();
		}
		
		private function insertResponse( e:SQLEvent ):void
		{
		}
		
		private function initializeResponse( e:SQLEvent ):void
		{
		}
		
		private function error( e:SQLErrorEvent ):void
		{
			trace("Snap. There was an error: " + e.error.message +" (" + e.error.details + ")");
		}
	}
}