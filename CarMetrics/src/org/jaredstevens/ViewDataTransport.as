package org.jaredstevens
{
	import org.jaredstevens.db.MaintenanceDAO;
	import org.jaredstevens.db.MileageDAO;
	import org.jaredstevens.db.TransactionDAO;
	import org.jaredstevens.db.VehiclesDAO;

	public class ViewDataTransport
	{
		public static const EDIT_VEHICLE:String = "edit vehicle";
		public static const ADD_VEHICLE:String = "add vehicle";
		public static const PIT_STOP:String = "pit stop";
		public static const LOG_MAINTENANCE:String = "log maintenance";
		public static const REPORTS:String = "reports";
		public static const SETTINGS:String = "settings";
		
		public var vehiclesDAO:VehiclesDAO;
		public var mileageDAO:MileageDAO;
		public var maintenanceDAO:MaintenanceDAO;
		public var transactionDAO:TransactionDAO;
		public var action:String;
		public var id:int;
		
		public function ViewDataTransport()
		{
			this.vehiclesDAO = null;
			this.mileageDAO = null;
			this.maintenanceDAO = null;
			this.transactionDAO = null;
			this.action = "";
			this.id = -1;
		}
	}
}