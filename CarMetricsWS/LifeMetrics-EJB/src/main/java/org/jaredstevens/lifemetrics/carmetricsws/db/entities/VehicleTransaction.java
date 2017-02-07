package org.jaredstevens.lifemetrics.carmetricsws.db.entities;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table
public class VehicleTransaction implements Serializable {
	private static final long serialVersionUID = -2643583108587251245L;
	
	private long id;
	private Vehicle vehicle;
	private TransactionType action;

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
	 * @return the action
	 */
	@Enumerated(EnumType.STRING)
	@Column(nullable=false)
	public TransactionType getAction() {
		return action;
	}
	/**
	 * @param action the action to set
	 */
	public void setAction(TransactionType action) {
		this.action = action;
	}
}