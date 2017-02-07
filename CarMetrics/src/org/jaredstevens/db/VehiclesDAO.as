package org.jaredstevens.db
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import org.jaredstevens.utils.Utils;
	import org.jaredstevens.valueobjects.VehicleRecord;

	public class VehiclesDAO
	{
		public static var TABLENAME:String = "vehicles";
		public var conn:SQLConnection = null;
		
		public function VehiclesDAO()
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
				"CREATE TABLE IF NOT EXISTS "+VehiclesDAO.TABLENAME+" ( "+
				"id INTEGER PRIMARY KEY AUTOINCREMENT, "+
				"serverId INTEGER NOT NULL, "+
				"nickName TEXT NOT NULL, "+
				"year INTEGER UNSIGNED NOT NULL, "+
				"make TEXT NOT NULL, "+
				"model TEXT NOT NULL, "+
				"imageData BLOB NOT NULL"+
				");";			
			sql.execute();
		}
		
		public function saveVehicle( vehicleId:int, serverId:int, nickName:String, year:int, make:String, model:String, imageData:ByteArray, callback:Function = null ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.saveResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			if(vehicleId > 0) {
				sql.text = 
					"UPDATE "+VehiclesDAO.TABLENAME+" SET serverId=@serverId, nickName=@nickName, year=@year, make=@make, model=@model, imageData=@imageData WHERE id=@vehicleId";
				sql.parameters["@vehicleId"] = vehicleId;
			} else {
				// We don't insert a serverId here because how can the server have an id for this record if our local
				// table has never seen it
				sql.text = 
					"INSERT INTO "+VehiclesDAO.TABLENAME+" VALUES (NULL, @serverId, @nickName, @year, @make, @model, @imageData)";
			}
			sql.parameters["@serverId"] = serverId;
			sql.parameters["@nickName"] = nickName;
			sql.parameters["@year"] = year;
			sql.parameters["@make"] = make;
			sql.parameters["@model"] = model;
			sql.parameters["@imageData"] = imageData;
			sql.execute();
		}
		
		public function saveRemoteVehicle( serverId:int, nickName:String, year:int, make:String, model:String, imageData:ByteArray, callback:Function = null):void {
			this.getRecordByServerId(serverId, function(e:SQLEvent):void
			{
				var sql:SQLStatement = new SQLStatement();
				sql.sqlConnection = conn;
				sql.addEventListener(SQLErrorEvent.ERROR, error);
				if( callback == null )
					sql.addEventListener(SQLEvent.RESULT, saveResponse );
				else
					sql.addEventListener(SQLEvent.RESULT, callback );
				
				var result:SQLResult = e.target.getResult();
				if(result != null && result.hasOwnProperty('data') && result.data != null && result.data.length > 0) {
					var record:VehicleRecord = VehiclesDAO.recordFactory(result.data[0]);
					sql.text = 
						"UPDATE "+VehiclesDAO.TABLENAME+" SET nickName=@nickName, year=@year, make=@make, model=@model, imageData=@imageData WHERE serverId=@serverId";
					sql.parameters["@serverId"] = serverId;
				} else {
					sql.text = 
						"INSERT INTO "+VehiclesDAO.TABLENAME+" VALUES (NULL, @serverId, @nickName, @year, @make, @model, @imageData)";
				}
				sql.parameters["@serverId"] = serverId;
				sql.parameters["@nickName"] = nickName;
				sql.parameters["@year"] = year;
				sql.parameters["@make"] = make;
				sql.parameters["@model"] = model;
				sql.parameters["@imageData"] = imageData;
				sql.execute();
			});
		}

		public function updateServerId( vehicleId:int, serverId:int, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.saveResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			
			if(vehicleId > 0 && serverId > 0) {
				sql.text = 
					"UPDATE "+VehiclesDAO.TABLENAME+" SET serverId=@serverId WHERE id=@vehicleId";
				sql.parameters["@vehicleId"] = vehicleId;
				sql.parameters["@serverId"] = serverId;
				sql.execute();
			} 
		}
		
		public function deleteVehicle( vehicleId:int, callback:Function = null ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.deleteResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = 
				"DELETE FROM "+VehiclesDAO.TABLENAME+" WHERE id=@vehicleId";
			sql.parameters["@vehicleId"] = vehicleId;
			sql.execute();
		}
		
		public function getRecord( id:int, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM "+VehiclesDAO.TABLENAME+" WHERE id=@vehicleId";
			sql.parameters["@vehicleId"] = id;
			sql.execute();
		}
		
		public function getRecordByServerId( serverId:int, callback:Function):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM "+VehiclesDAO.TABLENAME+" WHERE id=@serverId";
			sql.parameters["@serverId"] = serverId;
			sql.execute();
		}
		
		public function getVehicles( callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM "+VehiclesDAO.TABLENAME;
			sql.execute();
		}
		
		/**
		 * Builds a VehicleRecord from a resultset item object. (SQLResult.data element)
		 * @param Object Contains an element from the SQLResult.data array
		 * @return VehicleRecord Returns a new VehicleRecord object on success or null on failure.
		 */
		public static function recordFactory( inRecord:Object ):VehicleRecord
		{
			var retVal:VehicleRecord = VehicleRecord.initializeFromObject(inRecord);
			return retVal;
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