package org.jaredstevens.valueobjects
{
	public class TransactionRecord
	{
		[Bindable]
		public var id:int;
		[Bindable]
		public var tableName:String;
		[Bindable]
		public var tableId:int;
		[Bindable]
		public var serverId:int;
		[Bindable]
		public var action:String;
		
		public function TransactionRecord( id:int=-1, tableName:String="", tableId:int=-1, serverId:int=-1, action:String="" )
		{
			this.id = id;
			this.tableName = tableName;
			this.tableId = tableId;
			this.serverId = serverId;
			this.action = action;
		}
		
		public static function initializeFromObject( transaction:Object ):TransactionRecord
		{
			var retVal:TransactionRecord = null;
			if(transaction.hasOwnProperty('id') && transaction.hasOwnProperty('tableName')
				&& transaction.hasOwnProperty('tableId') && transaction.hasOwnProperty('serverId')
				&& transaction.hasOwnProperty('action'))
			{
				retVal = new TransactionRecord(transaction.id, transaction.tableName, transaction.tableId, transaction.serverId, transaction.action);
			}
			return retVal;
		}
	}
}