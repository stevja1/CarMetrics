package org.jaredstevens.lifemetrics.carmetricsws.db.interfaces;

import java.math.BigDecimal;
import java.util.List;

import javax.ejb.Remote;

import org.jaredstevens.lifemetrics.carmetricsws.db.entities.Mileage;

@Remote
public interface IMileageService {
	public Mileage getMileageById( long mileageId );
	public List<Mileage> getMileageByVehicleId( long vehicleId, int startIndex, int resultCount );
	public List<Mileage> getMileageAfterTransactionId(long transactionId, long vehicleId);
	public long getLastTransactionId(long vehicleId);
	public Mileage getMileageByTransactionId(long transactionId);
	public long save(long mileageId, long vehicleId, long fillupDate, BigDecimal fuelVolume, BigDecimal fuelPrice, int odometer, int latitude, int longitude);
	public long remove( long mileageId );
}
