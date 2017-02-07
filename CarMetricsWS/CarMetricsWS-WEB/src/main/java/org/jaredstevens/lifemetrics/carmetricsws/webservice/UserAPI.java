package org.jaredstevens.lifemetrics.carmetricsws.webservice;

import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.ejb.EJB;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User.UserStatus;
import org.jaredstevens.lifemetrics.carmetricsws.db.interfaces.IUserService;
import org.jaredstevens.lifemetrics.carmetricsws.utils.Utils;

import com.opensymphony.xwork2.ActionSupport;

/**
 * @author jstevens
 *
 */
public class UserAPI extends APIBase {
	@EJB(mappedName="UserService")
	private IUserService userService;

	private static final long serialVersionUID = 1L;
	private String userId;
	private String username;
	private String password;
	private String firstName;
	private String lastName;
	private String email;
	private String status;

	private User user;
	private String devId;

	public String getUserById()
	{
		String retVal = ActionSupport.SUCCESS;
		this.setUser(userService.getUserById(Long.parseLong(this.userId)));
		return retVal;
	}
	
	public String getUserByUsername()
	{
		String retVal = ActionSupport.SUCCESS;
		User user = userService.getUserByUsername(this.getUsername());
		this.setUser(user);
		return retVal;
	}
	
	public String authenticate()
	{
		String retVal = ActionSupport.SUCCESS;
		
		// Authenticate the user
		User user = userService.authenticate(this.getUsername(), this.getPassword());
		this.setUser(user);
		
		// If the user hasn't provided a device id, construct one and include it
		if(this.getDevId() == null || this.getDevId().length() < 1) {
			byte[] devId = null;
			String value = this.getUsername()+this.getPassword()+System.currentTimeMillis();
			try {
				byte[] thingToHash = value.getBytes("UTF-8");
				MessageDigest md = MessageDigest.getInstance("MD5");
				devId = md.digest(thingToHash);
				BigInteger numericHash = new BigInteger(1, devId);
				this.setDevId(numericHash.toString(16));
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (NoSuchAlgorithmException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return retVal;
	}

	public String save()
	{
		String retVal = ActionSupport.SUCCESS;
		long userId = -1;
		UserStatus status;
		if(this.getStatus() == "ACTIVE") status = UserStatus.ACTIVE;
		else status = UserStatus.DISABLED;
		if(this.getUserId() != null && Long.parseLong(this.getUserId()) > 0)
			userId = Long.parseLong(this.getUserId());
		User user = userService.save(userId, this.getUsername(), this.getPassword(), this.getFirstName(), this.getLastName(), this.getEmail(), false, status);
		this.setUser(user);
		return retVal;
	}
	
	public String remove()
	{
		String retVal = ActionSupport.SUCCESS;
		long userId = -1;
		if(Utils.isPositiveNum(this.getUserId())) userId = Long.parseLong(this.getUserId()); 
		userService.remove(userId);
		return retVal;
	}
	
	/**
	 * @return the userService
	 */
	public IUserService getUserService() {
		return userService;
	}

	/**
	 * @param userService the userService to set
	 */
	public void setUserService(IUserService userService) {
		this.userService = userService;
	}

	/**
	 * @return the userId
	 */
	public String getUserId() {
		return userId;
	}

	/**
	 * @param userId the userId to set
	 */
	public void setUserId(String userId) {
		this.userId = userId;
	}

	/**
	 * @return the userName
	 */
	public String getUsername() {
		return username;
	}

	/**
	 * @param userName the userName to set
	 */
	public void setUsername(String username) {
		this.username = username;
	}

	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}

	/**
	 * @param password the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}

	/**
	 * @return the firstName
	 */
	public String getFirstName() {
		return firstName;
	}

	/**
	 * @param firstName the firstName to set
	 */
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	/**
	 * @return the lastName
	 */
	public String getLastName() {
		return lastName;
	}

	/**
	 * @param lastName the lastName to set
	 */
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	/**
	 * @return the email
	 */
	public String getEmail() {
		return email;
	}

	/**
	 * @param email the email to set
	 */
	public void setEmail(String email) {
		this.email = email;
	}

	/**
	 * @return the status
	 */
	public String getStatus() {
		return status;
	}

	/**
	 * @param status the status to set
	 */
	public void setStatus(String status) {
		this.status = status;
	}

	/**
	 * @return the user
	 */
	public User getUser() {
		return user;
	}

	/**
	 * @param user the user to set
	 */
	public void setUser(User user) {
		this.user = user;
	}

	/**
	 * @return the devId
	 */
	public String getDevId() {
		return devId;
	}

	/**
	 * @param devId the devId to set
	 */
	public void setDevId(String devId) {
		this.devId = devId;
	}
}