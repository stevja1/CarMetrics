package org.jaredstevens.db
{
	/**
	 * Transactions are used to keep a running "delta" of the changes that have happened since the last sync.
	 * Whenever something changes in one of the tables, (Vehicles, Mileage, Maintenance), a record should be added
	 * to the transaction table. When a sync happens, these rows should be queried to know which rows in the
	 * cooresponding tables need to be sent to the server so they can be saved in the server's database.
	 * Once the server has accepted a new record, a transaction id will be provided. You'll want to hang on to
	 * the last one that you get from a certain API. When you go to sync again, you'll send that transaction
	 * id and the server will send back any transactions on the table that have happened since then.
	 */
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	public class TransactionDAO
	{
		public static var SAVE:String = "SAVE";
		public static var DELETE:String = "DELETE";
		
		public var conn:SQLConnection;
		
		public function TransactionDAO()
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
				"CREATE TABLE IF NOT EXISTS transactionLog ( "+
				"id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "+
				"tableName TEXT NOT NULL, "+
				"tableId INTEGER UNSIGNED NOT NULL, "+
				"serverId INTEGER UNSIGNED NOT NULL, "+
				"action TEXT NOT NULL"+
				");";
			sql.execute();
		}
		
		/**
		 * Queries a list of transactions for the provided tableName
		 * @param tableName Contains the name of the table that you want to get transactions from
		 * @param callback Contains a function that will be called when the query is complete
		 * @return void
		 */
		public function getTransactions( tableName:String, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = "SELECT * FROM transactionLog WHERE tableName LIKE @tableName ORDER BY id ASC";
			sql.parameters["@tableName"] = tableName;
			sql.execute();
		}
		
		/**
		 * Records a transaction.
		 * @param tableName Contains the name of the table you're modifying
		 * @param tableId Contains the id of the row you've modified/added/deleted
		 * @param action Indicates what happened. Use TransactionDAO.SAVE or DELETE.
		 * @param callback Function to call when transaction is recorded.
		 * @return void
		 */
		public function addTransaction( tableName:String, tableId:int, serverId:int, action:String, callback:Function ):void
		{
			/**
			 * We need to delete any other transactions that affect this tableName/tableId combo. This is because this new
			 * transaction will override any previous changes, and renders those previous changes irrelevant. If we leave
			 * them in there, a sync process will take extra time to process these redundant transactions, only to finally
			 * process the only one that matters at the end.
			 */
			this.deleteTransactionsByTableId(tableName, tableId,
				function(e:SQLEvent):void {
					var sql:SQLStatement = new SQLStatement();
					sql.sqlConnection = conn;
					sql.addEventListener(SQLErrorEvent.ERROR, error);
					if( callback == null )
						sql.addEventListener(SQLEvent.RESULT, insertResponse );
					else
						sql.addEventListener(SQLEvent.RESULT, callback );
					
					sql.text = 
					"INSERT INTO transactionLog (tableName, tableId, serverId, action) VALUES (@tableName, @tableId, @serverId, @action)";
					sql.parameters["@tableName"] = tableName;
					sql.parameters["@tableId"] = tableId;
					sql.parameters["@serverId"] = serverId;
					sql.parameters["@action"] = action;
					sql.execute();
					e.currentTarget.removeEventListener(e.type, arguments.callee);
				}
			);
		}
		
		/**
		 * Deletes transaction records by tableId and tableName. This is useful if a record in a table gets deleted
		 * because none of the transactions that apply to that record matter anymore.
		 * @param tableName The name of the affected table
		 * @param tableId The tableId of the records you want to delete
		 * @param callback A function to get called when this completes successfully
		 * @return void
		 */
		public function deleteTransactionsByTableId( tableName:String, tableId:int, callback:Function ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.deleteResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = 
				"DELETE FROM transactionLog WHERE tableName=@tableName AND tableId=@tableId AND action != 'DELETE'";
			sql.parameters["@tableName"] = tableName;
			sql.parameters["@tableId"] = tableId;
			sql.execute();
		}
 		
		/**
		 * Deletes a transaction. This doesn't roll back anything. It just removes a row from the transaction table.
		 * @param transactionId Contains the transaction id to delete
		 * @param callback Contains the function to be called when the delete operation is successful
		 * @return void
		 */
		public function deleteTransaction( transactionId:int, callback:Function = null ):void
		{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = this.conn;
			sql.addEventListener(SQLErrorEvent.ERROR, this.error);
			if( callback == null )
				sql.addEventListener(SQLEvent.RESULT, this.deleteResponse );
			else
				sql.addEventListener(SQLEvent.RESULT, callback );
			
			sql.text = 
				"DELETE FROM transactionLog WHERE id=@transactionId";
			sql.parameters["@transactionId"] = transactionId;
			sql.execute();
		}
		
		private function insertResponse( e:SQLEvent ):void
		{
			var result:SQLResult = e.target.getResult();
			trace("Insert success: "+result.lastInsertRowID);
		}

		private function deleteResponse( e:SQLEvent ):void
		{
			trace("Delete success: "+e.target.parameters["@transactionId"]);
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