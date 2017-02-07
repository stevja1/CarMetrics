package org.jaredstevens.webservice
{
	import flash.data.SQLResult;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SQLEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flashx.textLayout.elements.BreakElement;
	
	import mx.collections.ArrayList;
	
	import org.jaredstevens.ViewDataTransport;
	import org.jaredstevens.db.MileageDAO;
	import org.jaredstevens.db.TransactionDAO;
	import org.jaredstevens.db.VehiclesDAO;
	import org.jaredstevens.utils.Utils;
	import org.jaredstevens.valueobjects.MileageRecord;
	import org.jaredstevens.valueobjects.TransactionRecord;
	import org.jaredstevens.valueobjects.VehicleRecord;
	
	/**
	 * 1. Get transactions by table
	 * 2. Loop through transactions
	 * 3. Fetch table row for transaction
	 * 4. Execute transaction against server (save/delete)
	 * 5. Update table row with new serverId if needed
	 * 6. Remove transaction from transaction table
	 * 7. GOTO 1.
	 * 
	 * This logic is complicated by the fact that DB and API calls are processed asynchronously. I do this so that
	 * the UI doesn't hang while we wait for data to come back. I'm thinking that benifit isn't worth the trouble
	 * for DB calls, as they generally come back very quickly. The API though, depending on server load, connection,
	 * and relative location to the server, can take a while to come back.
	 * Thus, the flow is this:
	 * 1. Program calls pushLocalChanges()
	 * 2. pushLocalChanges() calls getTransactions()
	 * 3. getTransactions() gets transactions that need to be synced to the server. It populates that data in the
	 *    local variables mileageTransactions and vehicleTransactions. When those transactions are fetched, it calls
	 *    flagTransactionsFinished(). It calls flagTransactionsFinished() when the mileage comes back, and again when
	 *    the vehicles come back.
	 * 4. When flagTransactionsFinished() detects that both have come back, it calls the callback, currently
	 *    cacheTransactionData().
	 * 5. cacheTransactionData() loops through the transactions and fetches the related mileage and vehicle records.
	 *    If there there are any new data, it calls startVehicleSync().
	 * 6. startVehicleSync() starts a timer that waits for the mileage and vehicle records to finish populating. When
	 *    they have, it calls saveVehicle().
	 * 7. saveVehicle() loops first through the vehicle records and sends them to the server. We actually pass
	 *    saveVehicle() as the callback function that gets called when the API comes back so that we send transactions
	 *    in order. After vehicle transactions have been processed in this manner, in order, we do the same thing
	 *    for the mileage records (also inside of saveVehicle()). The processVehicleTransaction() and
	 *    processMileageTransaction() methods are used to process those records.
	 * 8. When saveVehicle() is done, it calls the this.successCallback() that was passed in when this whole process
	 *    started
	 */
	public class SyncLocalData
	{
		public var mileageDAO:MileageDAO;
		public var vehiclesDAO:VehiclesDAO;
		public var transactionDAO:TransactionDAO;
		
		private var mileageTransactions:ArrayList;
		private var vehiclesTransactions:ArrayList;
		private var mileageRecords:ArrayList;
		private var vehicleRecords:ArrayList;
		private var mileageTransactionIndex:int;
		private var vehicleTransactionIndex:int;
		private var mileageTransactionsCached:Boolean;
		private var vehicleTransactionsCached:Boolean;
		
		private var successCallback:Function;
		private var errorCallback:Function;
		
		public function SyncLocalData( mileageDAO:MileageDAO, vehiclesDAO:VehiclesDAO, transactionDAO:TransactionDAO )
		{
			this.mileageDAO = mileageDAO;
			this.vehiclesDAO = vehiclesDAO;
			this.transactionDAO = transactionDAO;
			this.mileageTransactionIndex = 0;
			this.vehicleTransactionIndex = 0;
			this.mileageTransactionsCached = false;
			this.vehicleTransactionsCached = false;
		}
		
		public function pushLocalChanges(successCallback:Function, errorCallback:Function):void
		{
			this.successCallback = successCallback;
			this.errorCallback = errorCallback;
			this.getTransactions(this.cacheTransactionData);
		}
		
		private function cacheTransactionData():void
		{
			this.mileageRecords = new ArrayList();
			this.vehicleRecords = new ArrayList();
			var transaction:TransactionRecord = null;
			for each(transaction in this.mileageTransactions.source)
			{
				++this.mileageTransactionIndex;
				if(transaction != null) {
					this.getTransactionRecord(transaction,
						function(mileage:MileageRecord):void {
							mileageRecords.addItem(mileage);
							--mileageTransactionIndex;
						}
					);
				}
			}
			for each(transaction in this.vehiclesTransactions.source)
			{
				++this.vehicleTransactionIndex;
				if(transaction != null) {
					this.getTransactionRecord(transaction,
						function(vehicle:VehicleRecord):void {
							vehicleRecords.addItem(vehicle);
							--vehicleTransactionIndex;
						}
					);
				}
			}
			if(this.mileageTransactions.length > 0 || this.vehiclesTransactions.length > 0)
				this.startVehicleSync();
			else this.successCallback();
		}
		
		/**
		 * Fetches all of the queued transactions that need to be sent to the server
		 * @param callback Contains a callback function that should accept NO PARAMETERS. This is called
		 *   after all transactions have been populated into this.mileageTransactions and this.vehicleTransactions.
		 * @return void
		 */
		public function getTransactions(callback:Function):void
		{
			this.mileageTransactions = new ArrayList();
			this.vehiclesTransactions = new ArrayList();
			this.transactionDAO.getTransactions(MileageDAO.TABLENAME,
				function(e:SQLEvent):void {
					var result:SQLResult = e.target.getResult();
					for each(var transaction:Object in result.data)
					{
						mileageTransactions.addItem(TransactionRecord.initializeFromObject(transaction));
					}
					flagTransactionsFinished(true, false, callback);
					e.currentTarget.removeEventListener(e.type, arguments.callee);
				}
			);
			this.transactionDAO.getTransactions(VehiclesDAO.TABLENAME,
				function(e:SQLEvent):void {
					var result:SQLResult = e.target.getResult();
					for each(var transaction:Object in result.data)
					{
						vehiclesTransactions.addItem(TransactionRecord.initializeFromObject(transaction));
					}
					flagTransactionsFinished(false, true, callback);
					e.currentTarget.removeEventListener(e.type, arguments.callee);
				}
			);
		}
		
		private function startVehicleSync():void
		{
			var recordTimer:Timer = new Timer(500);
			recordTimer.addEventListener(TimerEvent.TIMER,
				function(e:TimerEvent):void {
					if(mileageRecords.length == mileageTransactions.length && mileageTransactionIndex == 0
						&& vehicleRecords.length == vehiclesTransactions.length && vehicleTransactionIndex == 0)
					{
						recordTimer.stop();
						saveVehicle();
						e.currentTarget.removeEventListener(e.type, arguments.callee);
					}
				}
			);
			recordTimer.start();
		}
		
		private function saveVehicle():void
		{
			var index:int;
			if(this.vehicleTransactionIndex < this.vehiclesTransactions.length) {
				index = this.vehicleTransactionIndex;
				
				this.processVehicleTransaction(this.vehiclesTransactions.getItemAt(index) as TransactionRecord, this.vehicleRecords.getItemAt(index) as VehicleRecord,
					function():void {
						++vehicleTransactionIndex;
						saveVehicle();
					}, function():void {
						++vehicleTransactionIndex;
						saveVehicle();
					}
				);
			} else if(this.mileageTransactionIndex < this.mileageTransactions.length) {
				index = this.mileageTransactionIndex;
				this.processMileageTransaction(this.mileageTransactions.getItemAt(index) as TransactionRecord, this.mileageRecords.getItemAt(index) as MileageRecord,
					function():void {
						++mileageTransactionIndex;
						saveVehicle();
					}, function():void {
						++mileageTransactionIndex;
						saveVehicle();
					}
				);
			} else {
				this.mileageTransactionIndex = 0;
				this.vehicleTransactionIndex = 0;
				this.successCallback();
			}
		}
		
		private function flagTransactionsFinished(mileage:Boolean, vehicle:Boolean, callback:Function):void
		{
			if(mileage) this.mileageTransactionsCached = true;
			if(vehicle) this.vehicleTransactionsCached = true;
			if(this.mileageTransactionsCached && this.vehicleTransactionsCached)
				callback();
		}
		
		/**
		 * Gets the corresponding record for a transaction
		 * @param transaction Contains the transaction you want the record for
		 * @param callback Contains a function that will be called. The function should either expect a MileageRecord
		 *   or VehicleRecord for the parameter depending on the type of transaction you passed in.
		 * @return void
		 */
		public function getTransactionRecord( transaction:TransactionRecord, callback:Function ):void
		{
			if(TransactionDAO.DELETE != transaction.action)
			{
				switch(transaction.tableName)
				{
					case MileageDAO.TABLENAME:
						this.mileageDAO.getRecord(transaction.tableId,
							function(e:SQLEvent):void {
								var result:SQLResult = e.target.getResult();
								var mileage:MileageRecord = MileageRecord.initializeFromObject(result.data[0]);
								callback(mileage);
								e.currentTarget.removeEventListener(e.type, arguments.callee);
							}
						);
						break;
					case VehiclesDAO.TABLENAME:
						this.vehiclesDAO.getRecord(transaction.tableId,
							function(e:SQLEvent):void {
								var result:SQLResult = e.target.getResult();
								var vehicle:VehicleRecord = VehicleRecord.initializeFromObject(result.data[0]);
								callback(vehicle);
								e.currentTarget.removeEventListener(e.type, arguments.callee);
							}
						);
						break;
					default:
						break;
				}
			} else callback(null);
		}
		
		public function processVehicleTransaction( transaction:TransactionRecord, record:VehicleRecord, successCallback:Function, errorCallback:Function ):void
		{
			var userId:int = int(Utils.getSavedProperty("userId"));
			if(transaction.action == TransactionDAO.SAVE) {
				/**
				 * Cases:
				 * New Vehicle
				 * Modifying existing vehicle
				 */
				VehicleAPI.save(record.serverId, userId, record.nickName, record.year, record.make, record.model, record.imageData,
					function(e:Event):void {
						// Get new server id
						var response:Object;
						var serverId:int = record.serverId;
						if(e.currentTarget.data.length > 0 ) response = CarMetricsWS.parseResponse(e.currentTarget.data);
						if(response.vehicle != null && response.vehicle.hasOwnProperty("id") && response.vehicle.id > 0)
							serverId = response.vehicle.id;
						vehiclesDAO.updateServerId(record.id, serverId, null);
						// Delete related local transaction
						transactionDAO.deleteTransaction(transaction.id);
						successCallback();
						e.currentTarget.removeEventListener(e.type, arguments.callee);
					}, function(e:IOErrorEvent):void {
						trace('Failed to save vehicle to server: '+e);
						errorCallback();
						e.currentTarget.removeEventListener(e.type, arguments.callee);
					}, this.progressEventHandler
				);
			} else if(transaction.action == TransactionDAO.DELETE && transaction.serverId > 0) {
				VehicleAPI.remove(transaction.serverId,
					function(e:Event):void {
						successCallback();
						transactionDAO.deleteTransaction(transaction.id);
						e.currentTarget.removeEventListener(e.type, arguments.callee);
					}, function(e:IOErrorEvent):void {
						errorCallback();
						e.currentTarget.removeEventListener(e.type, arguments.callee);
					}
				);
			}
		}
		
		public function processMileageTransaction( transaction:TransactionRecord, record:MileageRecord, successCallback:Function, errorCallback:Function ):void
		{
			var userId:int = int(Utils.getSavedProperty("userId"));
			if(transaction.action == TransactionDAO.SAVE) {
				// Need to get VEHICLE serverId. At this point, its 1am, and I hate async db access...
				this.vehiclesDAO.getRecord(record.vehicleId,
					function(e:SQLEvent):void {
						var result:SQLResult = e.target.getResult();
						var latitude:int = record.latitude * 1000000;
						var longitude:int = record.longitude * 1000000;
						MileageAPI.save(record.serverId, result.data[0].serverId, record.date, record.fuelVolume, record.fuelPrice, record.odometer, latitude, longitude,
							function(e:Event):void {
								var response:Object;
								var serverId:int = record.serverId;
								if(e.currentTarget.data.length > 0 ) response = CarMetricsWS.parseResponse(e.currentTarget.data);
								if(response.mileage != null && response.mileage.hasOwnProperty("id") && response.mileage.id > 0)
									serverId = response.mileage.id;
								mileageDAO.updateServerId(record.id, serverId, null);
								transactionDAO.deleteTransaction(transaction.id);
								successCallback();
								e.currentTarget.removeEventListener(e.type, arguments.callee);
							}, function(e:IOErrorEvent):void {
								trace('Failed to save vehicle to server: '+e);
								errorCallback();
								e.currentTarget.removeEventListener(e.type, arguments.callee);
							}
						);
						e.currentTarget.removeEventListener(e.type, arguments.callee);
					}
				);
			} else if(transaction.action == TransactionDAO.DELETE) {
				VehicleAPI.remove(transaction.serverId,
					function(e:Event):void {
						successCallback();
					}, function(e:IOErrorEvent):void {
						errorCallback();
					}
				);
			}
		}

		private function progressEventHandler(e:ProgressEvent):void
		{
			
		}
	}		
}