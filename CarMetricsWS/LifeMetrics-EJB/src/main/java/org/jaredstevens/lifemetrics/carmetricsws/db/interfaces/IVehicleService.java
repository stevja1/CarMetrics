package org.jaredstevens.lifemetrics.carmetricsws.db.interfaces;

import java.util.List;

import javax.ejb.Remote;

import org.jaredstevens.lifemetrics.carmetricsws.db.entities.Vehicle;

@Remote
public interface IVehicleService {
	public Vehicle getVehicleById( long vehicleId );
	public List<Vehicle> getVehiclesByUserId( long userId, int startIndex, int resultCount );
	public List<Vehicle> getVehiclesAfterTransactionId(long transactionId, long userId);
	public long getLastTransactionId(long userId);
	public Vehicle getVehicleByTransactionId(long transactionId);
	public long addUserToVehicle(long vehicleId, long userId);
	public long removeUserFromVehicle(long vehicleId, long userId);
	public long save( long vehicleId, long userId, String nickName, int year, String make, String model, String imageData);
	public long uploadImage( long vehicleId, String imageData );
	public long remove( long vehicleId );
}
