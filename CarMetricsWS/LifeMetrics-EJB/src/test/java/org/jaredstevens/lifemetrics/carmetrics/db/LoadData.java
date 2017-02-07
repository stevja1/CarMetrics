package org.jaredstevens.lifemetrics.carmetrics.db;

import static org.junit.Assert.*;

import java.math.BigDecimal;
import java.sql.Date;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User.UserStatus;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.Vehicle;
import org.jaredstevens.lifemetrics.carmetricsws.db.services.MileageService;
import org.jaredstevens.lifemetrics.carmetricsws.db.services.UserService;
import org.jaredstevens.lifemetrics.carmetricsws.db.services.VehicleService;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class LoadData {
	private EntityManager em;

	@Before
	public void setUp() throws Exception {
		// Setup an EntityManager
		EntityManagerFactory factory = Persistence.createEntityManagerFactory("LifeMetricsPU", System.getProperties());
		this.em = factory.createEntityManager();
	}

	@After
	public void tearDown() throws Exception {
		this.em.getEntityManagerFactory().close();
	}

	@Test
	public void test() {
		String message = "";
		boolean proceedFlag = true;
		this.em.getTransaction().begin();
		
		// Create a user
		UserService userDb = new UserService();
		userDb.setEm(this.em);
		User user = userDb.save(0L, "jstevens", "h0ver5", "Jared", "Stevens", "stevja1@gmail.com", true, UserStatus.ACTIVE);
		if(user == null || user.getId() <= 0) {
			message = "Couldn't save a user.";
			proceedFlag = false;
		}
		this.em.getTransaction().commit();
		
//		VehicleService vehiclesDb = new VehicleService();
//		vehiclesDb.setEm(this.em);
//		Vehicle vehicle = null;
//		long vtx = 0L;
//		if(proceedFlag)	{
//			// Create a vehicle
//			String nickName = "Pathfinder";
//			int year = 1994;
//			String make = "Nissan";
//			String model = "Pathfinder";
//			byte[] image = {0};
//			
//			vtx = vehiclesDb.save(0L, user.getId(), nickName, year, make, model, image);
//			if(vtx <= 0L) {
//				message = "Couldn't save a vehicle.";
//				proceedFlag = false;
//			}
//		}
//		
//		if(proceedFlag) {
//			vehicle = vehiclesDb.getVehicleByTransactionId(vtx);
//			if(vehicle == null) {
//				message = "Saved the vehicle, but couldn't query it by transaction id.";
//				proceedFlag = false;
//			}
//		}
//		
//		MileageService mileageDb = new MileageService();
//		mileageDb.setEm(this.em);
//		if(proceedFlag) {
//			// Add some mileage records
//			Date fillupDate = Date.valueOf("2012-02-02");
//			BigDecimal fuelVolume = new BigDecimal(18.49);
//			BigDecimal fuelPrice = new BigDecimal(3.059);
//			int odometer = 155203;
//			long mtx = mileageDb.save(0L, vehicle.getId(), fillupDate.getTime(), fuelVolume, fuelPrice, odometer);
//			if(mtx <= 0L) {
//				message = "Couldn't save a mileage record.";
//				proceedFlag = false;
//			}
//		}
//		
//		if(proceedFlag)
//			this.em.getTransaction().rollback();
//		else {
//			this.em.getTransaction().rollback();
//			fail(message);
//		}
	}

}
