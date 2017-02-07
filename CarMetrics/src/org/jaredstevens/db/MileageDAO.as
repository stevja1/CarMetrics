package org.jaredstevens.db
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	import org.jaredstevens.utils.Utils;
	import org.jaredstevens.valueobjects.MileageRecord;
	
	import spark.formatters.DateTimeFormatter;

	public class MileageDAO
	{
		public static var TABLENAME:String = "mileage";
		public var conn:SQLConnection;
		
		public function MileageDAO()
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
				"CREATE TABLE IF NOT EXISTS "+MileageDAO.TABLENAME+" ( "+
				"id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "+
				"serverId INTEGER NOT NULL, "+
				"vehicleId INTEGER UNSIGNED NOT NULL, "+
				"date DATETIME NOT NULL, "+
				"fuelVolume REAL UNSIGNED NOT NULL, "+
				"odometer INTEGER UNSIGNED NOT NULL, "+
				"fuelPrice REAL UNSIGNED NOT NULL, "+
				"latitude REAL NOT NULL, "+
				"longitude REAL NOT NULL "+
				");";
			sql.execute();
		}
				
		public function savePitStop( record:MileageRecord, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
			
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.saveResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			
			if(record.id > 0) {
				sql.text = 
					"UPDATE "+MileageDAO.TABLENAME+" SET vehicleId=@vehicleId,serverId=@serverId,date=@date,fuelVolume=@fuelVolume,odometer=@odometer,fuelPrice=@fuelPrice,latitude=@latitude,longitude=@longitude WHERE id=@mileageId";
				sql.parameters["@mileageId"] = record.id;
			} else {
				sql.text = 
					"INSERT INTO "+MileageDAO.TABLENAME+" (vehicleId, serverId, date, fuelVolume, odometer, fuelPrice, latitude, longitude) "+
					"VALUES ( @vehicleId, @serverId, @date, @fuelVolume, @odometer, @fuelPrice, @latitude, @longitude )";
			}
			
			var dateString:String = "";
			dateFormatter.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			dateString = dateFormatter.format( record.date );

			sql.parameters["@vehicleId"] = record.vehicleId;
			sql.parameters["@serverId"] = record.serverId;
			sql.parameters["@date"] = dateString;
			sql.parameters["@fuelVolume"] = record.fuelVolume;
			sql.parameters["@odometer"] = record.odometer;
			sql.parameters["@fuelPrice"] = record.fuelPrice;
			sql.parameters["@latitude"] = record.latitude;
			sql.parameters["@longitude"] = record.longitude;
			sql.execute();
		}
		
		public function saveRemotePitStop( record:MileageRecord, callback:Function ):void
		{
			this.getRecordByServerId(record.serverId, function(e:SQLEvent):void {
				var result:SQLResult = e.target.getResult();
				var sql:SQLStatement = new SQLStatement();
				if(result != null && result.hasOwnProperty('data') && result.data != null && result.data.length > 0) {
					sql.text = 
						"UPDATE "+MileageDAO.TABLENAME+" SET vehicleId=@vehicleId,date=@date,fuelVolume=@fuelVolume,odometer=@odometer,fuelPrice=@fuelPrice,latitude=@latitude,longitude=@longitude WHERE serverId=@serverId";
				} else {
					sql.text = 
						"INSERT INTO "+MileageDAO.TABLENAME+" (vehicleId, serverId, date, fuelVolume, odometer, fuelPrice, latitude, longitude) "+
						"VALUES ( @vehicleId, @serverId, @date, @fuelVolume, @odometer, @fuelPrice, @latitude, @longitude )";
				}
				var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
				
				sql.sqlConnection = conn;
				sql.addEventListener(SQLErrorEvent.ERROR, error);
				if( callback == null )
					sql.addEventListener(SQLEvent.RESULT, saveResponse );
				else
					sql.addEventListener(SQLEvent.RESULT, callback );
				
				var dateString:String = "";
				dateFormatter.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
				dateString = dateFormatter.format( record.date );
				
				sql.parameters["@vehicleId"] = record.vehicleId;
				sql.parameters["@serverId"] = record.serverId;
				sql.parameters["@date"] = dateString;
				sql.parameters["@fuelVolume"] = record.fuelVolume;
				sql.parameters["@odometer"] = record.odometer;
				sql.parameters["@fuelPrice"] = record.fuelPrice;
				sql.parameters["@latitude"] = record.latitude;
				sql.parameters["@longitude"] = record.longitude;
				sql.execute();
			});
		}

		public function updateServerId( mileageId:int, serverId:int, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.saveResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			
			if(mileageId > 0 && serverId > 0) {
				sql.text = 
					"UPDATE "+MileageDAO.TABLENAME+" SET serverId=@serverId WHERE id=@mileageId";
				sql.parameters["@mileageId"] = mileageId;
				sql.parameters["@serverId"] = serverId;
				sql.execute();
			} 
		}
		
		public function updateVehicleServerId( vehicleId:int, vehicleServerId:int, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.saveResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			
			if(vehicleId > 0 && vehicleServerId > 0) {
				sql.text = 
					"UPDATE "+MileageDAO.TABLENAME+" SET vehicleServerId=@vehicleServerId WHERE vehicleId=@vehicleId";
				sql.parameters["@vehicleServerId"] = vehicleServerId;
				sql.parameters["@vehicleId"] = vehicleId;
				sql.execute();
			} 
		}
		
		/**
		 * Builds a MileageRecord from a resultset item object. (SQLResult.data element)
		 * @param Object Contains an element from the SQLResult.data array
		 * @return MileageRecord Returns a new MileageRecord object on success or null on failure.
		 */
		public static function recordFactory( inRecord:Object ):MileageRecord
		{
			var retVal:MileageRecord = MileageRecord.initializeFromObject(inRecord);
			return retVal;
		}
		
		public function deletePitStop( recordId:int, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.deleteResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );

			sql.text = "DELETE FROM "+MileageDAO.TABLENAME+" WHERE id=@mileageId";
			sql.parameters["@mileageId"] = recordId;
			sql.execute();
		}
		
		public function getRecords( vehicleId:int, startDate:Date, endDate:Date, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM "+MileageDAO.TABLENAME+" WHERE vehicleId=@vehicleId";
			sql.parameters["@vehicleId"] = vehicleId;
			
			if( startDate != null && endDate != null )
			{
				sql.text += " AND date >= @startDate";
				sql.parameters["@startDate"] = startDate;
				sql.text += " AND date <= @endDate";
				sql.parameters["@endDate"] = endDate;
			}
			sql.text += " ORDER BY odometer DESC";
			sql.execute();
		}

		public function getRecordsByVehicleServerId( vehicleServerId:int, startDate:Date, endDate:Date, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM "+MileageDAO.TABLENAME+" WHERE vehicleServerId=@vehicleServerId";
			sql.parameters["@vehicleServerId"] = vehicleServerId;
			
			if( startDate != null && endDate != null )
			{
				sql.text += " AND date >= @startDate";
				sql.parameters["@startDate"] = startDate;
				sql.text += " AND date <= @endDate";
				sql.parameters["@endDate"] = endDate;
			}
			sql.text += " ORDER BY odometer DESC";
			sql.execute();
		}
		
		public function getRecord( recordId:int, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM "+MileageDAO.TABLENAME+" WHERE id=@mileageId";
			sql.parameters["@mileageId"] = recordId;
			sql.execute();
		}
		
		public function getRecordByServerId( serverId:int, callback:Function):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM "+MileageDAO.TABLENAME+" WHERE serverId=@serverId";
			sql.parameters["@serverId"] = serverId;
			sql.execute();
		}

		public function getMPG( callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT vehicleId, MAX(odometer), MIN(odometer), SUM(fuelVolume) FROM "+MileageDAO.TABLENAME+" GROUP BY vehicleId";
			sql.execute();
		}
		
		private function saveResponse( e:SQLEvent ):void
		{
		}
		
		private function deleteResponse( e:SQLEvent ):void
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