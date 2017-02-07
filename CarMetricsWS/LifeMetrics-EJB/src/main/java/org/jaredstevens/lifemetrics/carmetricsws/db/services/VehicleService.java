package org.jaredstevens.lifemetrics.carmetricsws.db.services;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.ejb.Remote;
import javax.ejb.Stateless;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceContextType;
import javax.persistence.Query;

import org.jaredstevens.lifemetrics.carmetricsws.db.entities.TransactionType;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.Vehicle;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.VehicleTransaction;
import org.jaredstevens.lifemetrics.carmetricsws.db.interfaces.IVehicleService;

@Stateless(name="VehicleService",mappedName="VehicleService")
@Remote
public class VehicleService implements IVehicleService {
	@PersistenceContext(unitName="LifeMetricsPU",type=PersistenceContextType.TRANSACTION)
	private EntityManager em;

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public Vehicle getVehicleById(long vehicleId) {
		Vehicle retVal = null;
		retVal = (Vehicle)this.getEm().find(Vehicle.class, vehicleId);
		return retVal;
	}

	/**
	 * @todo Need to figure out how to do this join
	 */
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public List<Vehicle> getVehiclesByUserId(long userId, int startIndex, int resultCount) {
		List<Vehicle> retVal = null;
		String sql;
		sql = "SELECT v FROM Vehicle v LEFT JOIN v.users u WHERE u.id=:userId ORDER BY v.id ASC";
		Query q = this.getEm().createQuery(sql);
		q.setParameter("userId", userId);
		q.setFirstResult(startIndex);
		q.setMaxResults(resultCount);
		retVal = (List<Vehicle>)q.getResultList();
		return retVal;
	}
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public List<Vehicle> getVehiclesAfterTransactionId(long transactionId, long userId)
	{
		List<Vehicle> retVal = null;
		String sql = "SELECT DISTINCT v FROM Vehicle v LEFT JOIN v.transactions vt LEFT JOIN v.users u WHERE u.id=:userId AND vt.id > :transactionId";
		Query q = this.getEm().createQuery(sql);
		q.setParameter("userId", userId);
		q.setParameter("transactionId", transactionId);
		retVal = (List<Vehicle>)q.getResultList();
		return retVal;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long getLastTransactionId(long userId)
	{
		long retVal = 0L;
		VehicleTransaction vt;
		String sql = "SELECT vt FROM Vehicle v LEFT JOIN v.users u LEFT JOIN v.transactions vt WHERE u.id=:userId ORDER BY vt.id DESC";
		Query q = this.getEm().createQuery(sql);
		q.setMaxResults(1);
		q.setParameter("userId", userId);
		try {
			vt = (VehicleTransaction)q.getSingleResult();
			retVal = vt.getId();
		} catch(NoResultException e) {
			// There were no records to return.
		}
		return retVal;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public Vehicle getVehicleByTransactionId(long transactionId) {
		Vehicle retVal = null;
		String sql = "SELECT v FROM Vehicle v LEFT JOIN v.transactions vt WHERE vt.id=:transactionId";
		Query q = this.getEm().createQuery(sql);
		q.setParameter("transactionId",transactionId);
		retVal = (Vehicle)q.getSingleResult();
		return retVal;
	}
	/**
	 * @todo Need to search the list of users to see if this user is already associated with this vehicle.
	 * @param vehicleId
	 * @param userId
	 * @return
	 */
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long addUserToVehicle(long vehicleId, long userId)
	{
		long transactionId = -1;
		Vehicle vehicle = null;
		if(vehicleId > 0 && userId > 0)
		{
			User user = null;
			user = this.getEm().find(User.class, userId);
			vehicle = this.getEm().find(Vehicle.class, vehicleId);
			Set<User> users = vehicle.getUsers();
			if(users.size() > 0) {
				users.add(user);
			} else {
				users = new HashSet<User>();
				users.add(user);
			}
			vehicle.setUsers(users);
			this.getEm().persist(vehicle);
			transactionId = this.logTransaction(vehicle.getId(), TransactionType.UPDATE);
		}
		return transactionId;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long removeUserFromVehicle(long vehicleId, long userId)
	{
		long transactionId = -1;
		Vehicle vehicle = null;
		if(vehicleId > 0 && userId > 0)
		{
			vehicle = this.getEm().find(Vehicle.class, vehicleId);
			Set<User> users = vehicle.getUsers();
			if(users.size() > 0) {
				/* @todo Search for the user */
				/*
				User user = null;
				users.remove(user);
				vehicle.setUsers(users);
				this.getEm().persist(vehicle);
				transactionId = this.logTransaction(vehicle.getId(), TransactionType.DELETE);
				*/
			}
		}
		return transactionId;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long save(long vehicleId, long userId, String nickName, int year, String make, String model, String imageData) {
		Vehicle vehicle = null;
		if(vehicleId > 0)
			vehicle = this.getEm().find(Vehicle.class, vehicleId);
		if(vehicle == null)
			vehicle = new Vehicle();
		
		Set<User> users = null;
		if(userId > 0) {
			User user = null;
			user = this.getEm().find(User.class, userId);
			users = new HashSet<User>();
			users.add(user);
		}
		vehicle.setNickName(nickName);
		vehicle.setYear(year);
		vehicle.setMake(make);
		vehicle.setModel(model);
		vehicle.setUsers(users);
		vehicle.setImage(imageData);
		this.getEm().persist(vehicle);
		
		TransactionType action;
		if(vehicle.getId() == vehicleId) action = TransactionType.UPDATE;
		else action = TransactionType.INSERT;
		
		long transactionId = this.logTransaction(vehicle.getId(), action);
		return transactionId;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long uploadImage(long vehicleId, String imageData)
	{
		long retVal = 0L;
		Vehicle vehicle = null;
		if(vehicleId > 0) {
			vehicle = this.getEm().find(Vehicle.class, vehicleId);
			vehicle.setImage(imageData);
			this.getEm().persist(vehicle);
			
			TransactionType action;
			action = TransactionType.UPDATE;
			long transactionId = this.logTransaction(vehicle.getId(), action);
			retVal = transactionId;
		}
		return retVal;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long logTransaction(long vehicleId, TransactionType action)
	{
		VehicleTransaction transaction = new VehicleTransaction();
		Vehicle vehicle = this.getEm().find(Vehicle.class, vehicleId);
		transaction.setVehicle(vehicle);
		transaction.setAction(action);
		this.getEm().persist(transaction);
		return transaction.getId();
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public long remove(long vehicleId) {
		long retVal = -1L;
		if(vehicleId > 0) {
			Vehicle vehicle = null;
			vehicle = (Vehicle)this.getEm().find(Vehicle.class, vehicleId);
			if(vehicle != null) this.getEm().remove(vehicle);
			if(this.getEm().find(Vehicle.class, vehicleId) == null)
				retVal = this.logTransaction(vehicleId, TransactionType.DELETE);
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
