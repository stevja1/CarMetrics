package org.jaredstevens.lifemetrics.carmetricsws.db.entities;

import java.io.Serializable;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.JoinColumn;
import javax.persistence.Lob;
import javax.persistence.ManyToMany;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.Table;

@Entity
@Table
public class Vehicle implements Serializable {
	private static final long serialVersionUID = -2643583108587251245L;
	
	private long id;
	private String nickName;
	private int year;
	private String make;
	private String model;
	private String image;
	private Set<User> users;
	private Set<Mileage> mileageList;
	private Set<VehicleTransaction> transactions;

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
	 * @return the nickName
	 */
	@Column(nullable=false)
	public String getNickName() {
		return nickName;
	}
	/**
	 * @param nickName the nickName to set
	 */
	public void setNickName(String nickName) {
		this.nickName = nickName;
	}
	/**
	 * @return the year
	 */
	@Column(nullable=false)
	public int getYear() {
		return year;
	}
	/**
	 * @param year the year to set
	 */
	public void setYear(int year) {
		this.year = year;
	}
	/**
	 * @return the make
	 */
	@Column(nullable=false)
	public String getMake() {
		return make;
	}
	/**
	 * @param make the make to set
	 */
	public void setMake(String make) {
		this.make = make;
	}
	/**
	 * @return the model
	 */
	@Column(nullable=false)
	public String getModel() {
		return model;
	}
	/**
	 * @param model the model to set
	 */
	public void setModel(String model) {
		this.model = model;
	}
	/**
	 * @return the image
	 */
	@Lob
	@Column(nullable=false,length=65536)
	public String getImage() {
		return this.image;
	}
	/**
	 * @param image the image to set
	 */
	public void setImage(String image) {
		this.image = image;
	}
	/**
	 * @return the users
	 */
	@ManyToMany(cascade=CascadeType.ALL)
	@JoinTable(name="UserVehicle",
		joinColumns={
			@JoinColumn(name="vehicleId")
		},
		inverseJoinColumns={
			@JoinColumn(name="userId")
		}
	)
	public Set<User> getUsers() {
		return users;
	}
	/**
	 * @param users the users to set
	 */
	public void setUsers(Set<User> users) {
		this.users = users;
	}
	/**
	 * @return the mileageList
	 */
	@OneToMany(mappedBy="vehicle")
	public Set<Mileage> getMileageList() {
		return mileageList;
	}
	/**
	 * @param mileageList the mileageList to set
	 */
	public void setMileageList(Set<Mileage> mileageList) {
		this.mileageList = mileageList;
	}
	/**
	 * @return the transactions
	 */
	@OneToMany(mappedBy="vehicle")
	@OrderBy("id ASC")
	public Set<VehicleTransaction> getTransactions() {
		return transactions;
	}
	/**
	 * @param transactions the transactions to set
	 */
	public void setTransactions(Set<VehicleTransaction> transactions) {
		this.transactions = transactions;
	}
}