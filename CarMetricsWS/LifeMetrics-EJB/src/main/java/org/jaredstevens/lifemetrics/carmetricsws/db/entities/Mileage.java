package org.jaredstevens.lifemetrics.carmetricsws.db.entities;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.Table;

@Entity
@Table
public class Mileage implements Serializable {
	private static final long serialVersionUID = -2643583108587251245L;
	
	private long id;
	private long fillupDate;
	private BigDecimal fuelVolume;
	private BigDecimal fuelPrice;
	private int odometer;
	private int latitude;
	private int longitude;
	private Vehicle vehicle;
	private List<MileageTransaction> transactions;

	/**
	 * @return the id
	 */
	@Id
	@GeneratedValue(strategy = GenerationType.TABLE)
	public long getId() {
		return id;
	}
	/**
	 * @param id the id to set
	 */
	public void setId(long id) {
		this.id = id;
	}
	/**
	 * @return the fillupDate
	 */
	@Column(nullable=false)
	public long getFillupDate() {
		return fillupDate;
	}
	/**
	 * @param fillupDate the fillupDate to set
	 */
	public void setFillupDate(long fillupDate) {
		this.fillupDate = fillupDate;
	}
	/**
	 * @return the fuelVolume
	 */
	@Column(precision = 7, scale = 3)
	public BigDecimal getFuelVolume() {
		return fuelVolume;
	}
	/**
	 * @param fuelVolume the fuelVolume to set
	 */
	public void setFuelVolume(BigDecimal fuelVolume) {
		this.fuelVolume = fuelVolume;
	}
	/**
	 * @return the fuelPrice
	 */
	@Column(precision = 6, scale = 3)
	public BigDecimal getFuelPrice() {
		return fuelPrice;
	}
	/**
	 * @param fuelPrice the fuelPrice to set
	 */
	public void setFuelPrice(BigDecimal fuelPrice) {
		this.fuelPrice = fuelPrice;
	}
	/**
	 * @return the odometer
	 */
	@Column(nullable=false)
	public int getOdometer() {
		return odometer;
	}
	/**
	 * @param odometer the odometer to set
	 */
	public void setOdometer(int odometer) {
		this.odometer = odometer;
	}
	@Column(nullable=false)
	public int getLatitude() {
		return latitude;
	}
	public void setLatitude(int latitude) {
		this.latitude = latitude;
	}
	@Column(nullable=false)
	public int getLongitude() {
		return longitude;
	}
	public void setLongitude(int longitude) {
		this.longitude = longitude;
	}
	/**
	 * @return the vehicle
	 */
	@ManyToOne(optional=false)
	@JoinColumn(name="vehicleId", nullable=false, updatable=false)
	public Vehicle getVehicle() {
		return vehicle;
	}
	/**
	 * @param vehicle the vehicle to set
	 */
	public void setVehicle(Vehicle vehicle) {
		this.vehicle = vehicle;
	}
	/**
	 * @return the transactions
	 */
	@OneToMany(mappedBy="mileage")
	@OrderBy("id ASC")
	public List<MileageTransaction> getTransactions() {
		return transactions;
	}
	/**
	 * @param transactions the transactions to set
	 */
	public void setTransactions(List<MileageTransaction> transactions) {
		this.transactions = transactions;
	}
}