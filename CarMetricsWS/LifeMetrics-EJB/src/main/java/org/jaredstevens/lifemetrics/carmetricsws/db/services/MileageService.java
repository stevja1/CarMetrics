package org.jaredstevens.lifemetrics.carmetricsws.db.services;

import java.math.BigDecimal;
import java.util.List;

import javax.ejb.Remote;
import javax.ejb.Stateless;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceContextType;
import javax.persistence.Query;

import org.jaredstevens.lifemetrics.carmetricsws.db.entities.Mileage;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.MileageTransaction;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.TransactionType;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.Vehicle;
import org.jaredstevens.lifemetrics.carmetricsws.db.interfaces.IMileageService;

@Stateless(name="MileageService",mappedName="MileageService")
@Remote
public class MileageService implements IMileageService {
	@PersistenceContext(unitName="LifeMetricsPU",type=PersistenceContextType.TRANSACTION)
	private EntityManager em;

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public Mileage getMileageById(long mileageId) {
		Mileage retVal = null;
		retVal = (Mileage)this.em.find(Mileage.class, mileageId);
		return retVal;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public List<Mileage> getMileageByVehicleId(long vehicleId, int startIndex, int resultCount) {
		List<Mileage> retVal = null;
		Vehicle vehicle = null;
		String sql;
		vehicle = (Vehicle)this.em.find(Vehicle.class, vehicleId);
		sql = "SELECT DISTINCT m FROM Mileage m WHERE m.vehicle=:vehicle ORDER BY m.id ASC";
		Query q = this.getEm().createQuery(sql);
		q.setFirstResult(startIndex);
		q.setMaxResults(resultCount);
		q.setParameter("vehicle", vehicle);
		retVal = (List<Mileage>)q.getResultList();
		return retVal;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public List<Mileage> getMileageAfterTransactionId(long transactionId, long vehicleId)
	{
		List<Mileage> retVal = null;
		Vehicle vehicle = null;
		if(vehicleId > 0) vehicle = this.getEm().find(Vehicle.class, vehicleId);
		else vehicle = new Vehicle();
		String sql = "SELECT DISTINCT m FROM Mileage m LEFT JOIN m.transactions mt WHERE mt.id > :transactionId AND m.vehicle=:vehicle";
		Query q = this.getEm().createQuery(sql);
		q.setParameter("transactionId", transactionId);
		q.setParameter("vehicle", vehicle);
		retVal = (List<Mileage>)q.getResultList();
		return retVal;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long getLastTransactionId(long vehicleId)
	{
		long retVal = 0L;
		MileageTransaction mt;
		Vehicle vehicle = null;
		vehicle = (Vehicle)this.em.find(Vehicle.class, vehicleId);
		String sql = "SELECT DISTINCT mt FROM Mileage m LEFT JOIN m.transactions mt WHERE m.vehicle=:vehicle ORDER BY mt.id DESC";
		Query q = this.getEm().createQuery(sql);
		q.setMaxResults(1);
		q.setParameter("vehicle", vehicle);
		try {
			mt = (MileageTransaction)q.getSingleResult();
			retVal = mt.getId();
		} catch(NoResultException e) {
			// There were no records to return.
		}
		return retVal;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public Mileage getMileageByTransactionId(long transactionId) {
		Mileage retVal = null;
		String sql = "SELECT DISTINCT m FROM Mileage m LEFT JOIN m.transactions mt WHERE mt.id=:transactionId";
		Query q = this.getEm().createQuery(sql);
		q.setParameter("transactionId",transactionId);
		retVal = (Mileage)q.getSingleResult();
		return retVal;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long save(long mileageId, long vehicleId, long fillupDate, BigDecimal fuelVolume, BigDecimal fuelPrice, int odometer, int latitude, int longitude) {
		Mileage mileage = null;
		if(mileageId > 0) mileage = this.getEm().find(Mileage.class, mileageId);
		if(mileage == null)
			mileage = new Mileage();
		Vehicle vehicle = null;
		if(vehicleId > 0) vehicle = this.getEm().find(Vehicle.class, vehicleId);
		else vehicle = new Vehicle();
		mileage.setFillupDate(fillupDate);
		mileage.setFuelVolume(fuelVolume);
		mileage.setFuelPrice(fuelPrice);
		mileage.setOdometer(odometer);
		mileage.setLatitude(latitude);
		mileage.setLongitude(longitude);
		mileage.setVehicle(vehicle);
		this.em.persist(mileage);
		
		TransactionType action;
		if(mileage.getId() == mileageId) action = TransactionType.UPDATE;
		else action = TransactionType.INSERT;
		
		long transactionId = this.logTransaction(mileage.getId(), action);
		return transactionId;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long logTransaction(long mileageId, TransactionType action)
	{
		MileageTransaction transaction = new MileageTransaction();
		Mileage mileage = this.getEm().find(Mileage.class, mileageId);
		transaction.setMileage(mileage);
		transaction.setAction(action);
		this.getEm().persist(transaction);
		return transaction.getId();
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long remove(long mileageId) {
		long retVal = -1;
		if(mileageId > 0) {
			Mileage mileageEntry = null;
			mileageEntry = (Mileage)this.getEm().find(Mileage.class, mileageId);
			if(mileageEntry != null) this.getEm().remove(mileageEntry);
			if(this.getEm().find(Mileage.class, mileageId) == null)
				retVal = this.logTransaction(mileageId, TransactionType.DELETE);
		}
		return retVal;
	}

	/**
	 * @return the em
	 */
	public EntityManager getEm() {
		return em;
	}

	/**
	 * @param em the em to set
	 */
	public void setEm(EntityManager em) {
		this.em = em;
	}

}
