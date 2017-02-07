package org.jaredstevens.webservice
{
	import flash.data.SQLResult;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SQLEvent;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayList;
	import mx.utils.Base64Decoder;
	
	import org.jaredstevens.db.MileageDAO;
	import org.jaredstevens.db.VehiclesDAO;
	import org.jaredstevens.utils.Utils;
	import org.jaredstevens.valueobjects.MileageRecord;
	import org.jaredstevens.valueobjects.VehicleRecord;

	/**
	 * This class is used to query the webservice for vehicle and mileage transactions that have occured that this app
	 * isn't aware of yet. This is how stuff gets called. Entry point is this.getChangesFromServer()
	 * 1. Call this.vehiclesDAO.getVehicles() -- Not sure what this is for
	 * 2. Call this.getVehicleTransactions() -- This fetches new transactions from the server
	 * 3. Call this.processVehicleTransactions() -- If we got a response from the server, process the new vehicle
	 *   transactions into the local database.
	 * 4. Call this.saveResult() -- If we saved everything successfully, this method checks to see if we've saved all
	 *   of the vehicles that have come back. If we have, it queries the web service for new mileage transactions.
	 * 5. Call this.getMileageTransactions() -- Fetch a list of vehicles. Loop through the list and query the
	 *   webservice for mileage transactions for that vehicle.
	 * 6. Call this.getMileageForVehicle() -- Calls the webservice to get mileage transactions.
	 * 7. Call this.processMileageTransactions() -- If the webservice returns successfully, we call this method to save
	 *   the mileage transactions to the database.
	 */
	public class SyncRemoteData
	{
		public var vehiclesDAO:VehiclesDAO;
		public var mileageDAO:MileageDAO;
		private var vehicleCount:int;
		private var mileageCount:int;
		private var vehicleTxId:int;
		private var mileageTxId:int;
		private var successCallback:Function;
		private var errorCallback:Function;
		
		public function SyncRemoteData(vehiclesDAO:VehiclesDAO, mileageDAO:MileageDAO)
		{
			this.vehiclesDAO = vehiclesDAO;
			this.mileageDAO = mileageDAO;
			this.vehicleTxId = 0;
			this.mileageTxId = 0;
		}
		
		public function getChangesFromServer(successCallback:Function, errorCallback:Function):void
		{
			this.successCallback = successCallback;
			this.errorCallback = errorCallback;
			var vehicleTxId:String = Utils.getSavedProperty("vehicleTransactionId");
			if(vehicleTxId != null && vehicleTxId.length > 0) this.vehicleTxId = int(vehicleTxId);
			var mileageTxId:String = Utils.getSavedProperty("mileageTransactionId");
			if(mileageTxId != null && mileageTxId.length > 0) this.mileageTxId = int(mileageTxId);
			
			this.vehiclesDAO.getVehicles(
				// Query database to figure out the most recent vehicle transaction id
				function(e:SQLEvent):void {
					var results:SQLResult = e.target.getResult();
					var vehicleList:ArrayList = new ArrayList();
					var vehicle:VehicleRecord;
					for(var index:String in results.data)
					{
						vehicle = VehicleRecord.initializeFromObject(results.data[index]);
						vehicleList.addItem(vehicle);
					}
					// Now that we have data, call the web service
					getVehicleTransactions(processVehicleTransactions, errorVehicleTransactions);
				}
			);
		}
		
		private function getVehicleTransactions(success:Function, error:Function):void
		{
			var userId:int = int(Utils.getSavedProperty("userId"));
			VehicleAPI.getVehiclesAfterTransactionId(this.vehicleTxId, userId, success, error);
		}
		
		private function processVehicleTransactions( e:Event ):void
		{
			var vehicleList:ArrayList = new ArrayList();
			var rawVehicle:Object;
			var response:Object;
			var imageData:ByteArray = new ByteArray();
			if(e.currentTarget.data.length > 0 ) response = CarMetricsWS.parseResponse(e.currentTarget.data);
			if(response.vehicleList.length <= 0) {
				// There aren't any new vehicle transactions to sync
				// See if we have any new mileage transactions...
				this.getMileageTransactions();
			}
			for each(rawVehicle in response.vehicleList)
			{
				// Increment this to indicate that we've received a vehicle transaction that needs to be saved.
				this.vehicleCount++;
				// Load a generic image if nothing comes back
				if(rawVehicle.image == null || rawVehicle.image.length <= 0)
					Utils.loadGenericImage(imageData);
				else {
					var decoder:Base64Decoder = new Base64Decoder();
					decoder.decode(rawVehicle.image);
					imageData = decoder.toByteArray();
				}
				this.vehiclesDAO.saveRemoteVehicle(rawVehicle.id, rawVehicle.nickName, rawVehicle.year, rawVehicle.make, rawVehicle.model, imageData, function(e:SQLEvent):void {
					// Update vehicle transaction id
					Utils.saveProperty("vehicleTransactionId", String(response.transactionId));
					saveVehicleResult(e);
					e.currentTarget.removeEventListener(e.type, arguments.callee);
				});
			}
		}

		private function errorVehicleTransactions(e:IOErrorEvent):void
		{
			e.currentTarget.removeEventListener(e.type, arguments.callee);
		}
		
		private function saveVehicleResult(e:SQLEvent):void
		{
			// Decrement this to show that we've successfully saved a vehicle in our queue.
			this.vehicleCount--;
			// If we've processed all of the vehicles that came back from the web service, fetch the new mileage data.
			if(this.vehicleCount == 0) this.getMileageTransactions();
		}
		
		private function getMileageTransactions():void
		{
			this.vehiclesDAO.getVehicles(function(e:SQLEvent):void {
				var result:SQLResult = e.target.getResult();
				for each(var rawVehicle:Object in result.data) {
					if(rawVehicle.hasOwnProperty("serverId") && rawVehicle.serverId > 0)
					{
						getMileageForVehicle(rawVehicle.id, rawVehicle.serverId);
					}
				}
				e.currentTarget.removeEventListener(e.type, arguments.callee);
			});
		}
		
		/**
		 * Gets the new mileage transactions for a vehicle from the web service. The first parameter is the vehicleId
		 * from our local vehicle database in SQLite. The second parameter references a vehicleId of the same vehicle
		 * but stored on the server. We query mileage data from the server based on the server's vehicleId. When it
		 * comes back, we save that mileage data to our local database using the local vehicleId.
		 * @param int vehicleId Contains the vehicleId (local id) for a vehicle we want to save mileage for.
		 * @param int vehicleServerId Contains the vehicleServerId for a vehicle that we want mileage data for.
		 */
		private function getMileageForVehicle(vehicleId:int, vehicleServerId:int):void
		{
			MileageAPI.getMileageAfterTransactionId(this.mileageTxId, vehicleServerId, function(e:Event):void {
					processMileageTransactions(e, vehicleId);
					e.currentTarget.removeEventListener(e.type, arguments.callee);
				}, errorMileageTransactions
			);
		}
		
		/**
		 * Process mileage transactions from the server so that they are in our local database.
		 * The first parameter is the event that was dispatched when we received data back from the server.
		 * The vehicleId is the local database's vehicleId value for the vehicle tied to this record. Don't forget to
		 * tie this mileage record to the server's vehicleId (stored locally as serverVehicleId). Otherwise it will
		 * jack up the database relationships.
		 * @param Event e
		 * @param int vehicleId
		 * @return void
		 */
		private function processMileageTransactions(e:Event, vehicleId:int):void
		{
			var response:Object;
			var mileageRecord:MileageRecord;
			if(e.currentTarget.hasOwnProperty("data") && e.currentTarget.data.length > 0 )
				response = CarMetricsWS.parseResponse(e.currentTarget.data);
			if(response != null && response.mileageList.length > 0) {
				for each(var rawMileage:Object in response.mileageList)	{
					// Increment this to show that we've received a mileage record that needs processing
					this.mileageCount++;
					var fillupDate:Date = new Date();
					fillupDate.setTime(rawMileage.fillupDate);
					var latitude:Number = rawMileage.latitude / 1000000;
					var longitude:Number = rawMileage.longitude / 1000000;
					mileageRecord = new MileageRecord(-1, rawMileage.id, vehicleId, fillupDate, rawMileage.fuelVolume, rawMileage.odometer, rawMileage.fuelPrice, rawMileage.latitude, rawMileage.longitude);
					this.mileageDAO.saveRemotePitStop(mileageRecord, function(e:SQLEvent):void {
						// Update vehicle transaction id
						var mtxId:String = Utils.getSavedProperty("mileageTransactionId");
						if(mtxId != null && int(mtxId) < response.transactionId)
							Utils.saveProperty("mileageTransactionId", String(response.transactionId));
						saveMileageResult(e);
						e.currentTarget.removeEventListener(e.type, arguments.callee);
					});
				}
			} else {
				// There weren't any mileage transactions to sync for this vehicle... move along...
				this.successCallback();
			}
		}
		
		private function errorMileageTransactions(e:IOErrorEvent):void
		{
			e.currentTarget.removeEventListener(e.type, arguments.callee);
		}

		private function saveMileageResult(e:SQLEvent):void
		{
			// Decrement this to show that we've successfully saved a vehicle in our queue.
			this.mileageCount--;
			// If we've processed all of the vehicles that came back from the web service, fetch the new mileage data.
			if(this.mileageCount == 0) this.successCallback();
		}
	}
}