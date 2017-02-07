package org.jaredstevens.lifemetrics.carmetricsws.db.entities;

import java.io.Serializable;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToMany;
import javax.persistence.Table;

import org.apache.log4j.Logger;

@Entity
@Table
public class User implements Serializable {
	private static final long serialVersionUID = -2643583108587251245L;
	
	public enum UserStatus {
		ACTIVE, DISABLED
	}
	
	private long id;
	private String username;
	private String password;
	private String firstName;
	private String lastName;
	private String email;
	private boolean emailVerified;
	private UserStatus status;
	private long createDate;
	private Set<Vehicle> vehicles;

    // DON'T CHANGE THIS UNLESS YOU'VE BACKED UP THE DATABASE AND KNOW WHAT YOU'RE DOING.
    // IF INCORRECTLY PERFORMED, NO ONE WILL BE ABLE TO LOG IN ANYMORE.
    private static final String salt = "What's up with YouTube? Gr8.";
	
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

	@Column(nullable=false)
	public String getUsername() {
		return this.username;
	}

	public void setUsername( String username ) {
		this.username = username;
	}

	@Column(nullable=false)
	public String getPassword() {
		return this.password;
	}

	public void setPassword( String password ) {
		this.password = password;
	}
	public void setSaltedPassword( String password )
	{
		this.password = User.getSaltedPassword(password);
	}
	public static String getSaltedPassword( String password )
	{
		String retVal = "";
		Logger log = Logger.getLogger("org.jaredstevens.lifemetrics.carmetricsws");
		try {
			String saltedPassword = password + User.salt;
			MessageDigest md = MessageDigest.getInstance("MD5");
			md.update( saltedPassword.getBytes("UTF-8"), 0, saltedPassword.length());
			retVal = new BigInteger(1,md.digest()).toString(16);
		} catch( Exception e ) {
			log.error("Unable to get MD5 instance from MessageDigest.");
		}
		return retVal;
	}
  	@Column(nullable=false)
	public String getFirstName() {
		return this.firstName;
	}

	public void setFirstName( String firstName ) {
		this.firstName = firstName;
	}

	@Column(nullable=false)
	public String getLastName() {
		return this.lastName;
	}

	public void setLastName( String lastName ) {
		this.lastName = lastName;
	}

	@Column(nullable=false)
	public String getEmail() {
		return this.email;
	}

	public void setEmail( String email ) {
		this.email= email;
	}
	@Column(nullable=false)
	public boolean getEmailVerified() {
		return this.emailVerified;
	}

	public void setEmailVerified( boolean verified ) {
		this.emailVerified = verified;
	}
	/**
	 * @return the status
	 */
	@Enumerated(EnumType.STRING)
	@Column(nullable=false)
	public UserStatus getStatus() {
		return status;
	}
	/**
	 * @param status the status to set
	 */
	public void setStatus(UserStatus status) {
		this.status = status;
	}
	/**
	 * @return the createDate
	 */
	@Column(nullable=false)
	public long getCreateDate() {
		return createDate;
	}
	/**
	 * @param createDate the createDate to set
	 */
	public void setCreateDate(long createDate) {
		this.createDate = createDate;
	}
	/**
	 * @return the vehicles
	 */
	@ManyToMany(cascade=CascadeType.ALL)
	@JoinTable(name="UserVehicle",
		joinColumns={
			@JoinColumn(name="userId")
		},
		inverseJoinColumns={
			@JoinColumn(name="vehicleId")
		}
	)
	public Set<Vehicle> getVehicles() {
		return vehicles;
	}
	/**
	 * @param vehicles the vehicles to set
	 */
	public void setVehicles(Set<Vehicle> vehicles) {
		this.vehicles = vehicles;
	}
}
