package org.jaredstevens.lifemetrics.carmetricsws.webservice;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;

import javax.ejb.EJB;

import org.apache.commons.io.IOUtils;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.Vehicle;
import org.jaredstevens.lifemetrics.carmetricsws.db.interfaces.IVehicleService;
import org.jaredstevens.lifemetrics.carmetricsws.utils.Utils;

import com.opensymphony.xwork2.ActionSupport;

public class VehicleAPI extends APIBase {
	private static final long serialVersionUID = 8647752365049332178L;
	@EJB(mappedName="VehicleService")
	private IVehicleService vehicleService;

	private String vehicleId;
	private String nickName;
	private String year;
	private String make;
	private String model;
	private String userId;
	private String imageData;
	private String transactionQueryId;

	private long transactionId;
	private Vehicle vehicle;
	private List<Vehicle> vehicleList;
	public String getVehicleById()
	{
		String retVal = ActionSupport.SUCCESS;
		long vehicleId = -1;
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		this.vehicle = this.vehicleService.getVehicleById(vehicleId);
		return retVal;
	}
	
	public String getVehiclesByUserId()
	{
		String retVal = ActionSupport.SUCCESS;
		long userId = -1;
		if(Utils.isPositiveNum(this.getUserId())) userId = Long.parseLong(this.getUserId());
		this.vehicleList = this.vehicleService.getVehiclesByUserId(userId, 0, 20);
		return retVal;
	}
	public String getVehiclesAfterTransactionId()
	{
		String retVal = ActionSupport.SUCCESS;
		long userId = -1;
		long transactionId = -1;
		if(Utils.isPositiveNum(this.getUserId())) userId = Long.parseLong(this.getUserId());
		if(Utils.isPositiveNum(this.getTransactionQueryId())) transactionId = Long.parseLong(this.getTransactionQueryId());
		if(transactionId >= 0 && userId > 0 ) {
			this.vehicleList = this.vehicleService.getVehiclesAfterTransactionId(transactionId, userId);
			this.setTransactionId(this.vehicleService.getLastTransactionId(userId));
		}
		return retVal;
	}
	public String getLastTransactionId()
	{
		String retVal = ActionSupport.SUCCESS;
		long userId = -1;
		if(Utils.isPositiveNum(this.getUserId())) userId = Long.parseLong(this.getUserId());
		this.setTransactionId(this.vehicleService.getLastTransactionId(userId));
		return retVal;
	}
	public String addUserToVehicle()
	{
		String retVal = ActionSupport.SUCCESS;
		long userId = -1;
		long vehicleId = -1;
		if(Utils.isPositiveNum(this.getUserId())) userId = Long.parseLong(this.getUserId());
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		this.setTransactionId(this.vehicleService.addUserToVehicle(vehicleId, userId));
		return retVal;
	}
	public String removeUserFromVehicle()
	{
		String retVal = ActionSupport.SUCCESS;
		long userId = -1;
		long vehicleId = -1;
		if(Utils.isPositiveNum(this.getUserId())) userId = Long.parseLong(this.getUserId());
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		this.setTransactionId(this.vehicleService.removeUserFromVehicle(vehicleId, userId));
		return retVal;
	}
	
	/**
	 * Save a vehicle. Returns a vehicle record on success.
	 * @param long vehicleId
	 * @param long userId
	 * @param int year
	 * @param String make
	 * @param String model
	 * @param String nickName
	 * @param ByteArray imageData
	 * @return Vehicle vehicle, TransactionId
	 */
	public String save()
	{
		String retVal = ActionSupport.SUCCESS;
		long vehicleId = -1;
		int year = -1;
		long userId = -1;
		String imageData = null;
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		if(Utils.isPositiveNum(this.getYear())) year = Integer.parseInt(this.getYear());
		if(Utils.isPositiveNum(this.getUserId())) userId = Long.parseLong(this.getUserId());
		if(this.getImageData() != null && this.getImageData().length() > 0) imageData = this.getImageData(); 
		
		long txId = this.vehicleService.save(vehicleId, userId, this.getNickName(), year, this.getMake(), this.getModel(), imageData);
		if(txId > 0L) {
			Vehicle vehicle = this.vehicleService.getVehicleByTransactionId(txId);
			this.setVehicle(vehicle);
			this.setTransactionId(txId);
		} else this.setVehicle(null);
		return retVal;
	}
	public String uploadImage()
	{
		String retVal = ActionSupport.SUCCESS;
		long vehicleId = -1;
		long txId = 0L;
		String imageData = null;
		imageData = this.getImageData();
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		if(vehicleId > 0 && imageData.length() > 0)
			txId = this.vehicleService.uploadImage(vehicleId, imageData);
		if(txId > 0L) {
			Vehicle vehicle = this.vehicleService.getVehicleByTransactionId(txId);
			this.setVehicle(vehicle);
			this.setTransactionId(txId);
		} else this.setVehicle(null);
		return retVal;
	}
	
	public String remove()
	{
		String retVal = ActionSupport.SUCCESS;
		long vehicleId = -1;
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		long transactionId = this.vehicleService.remove(vehicleId);
		this.setTransactionId(transactionId);
		return retVal;
	}
	/**
	 * @return the userService
	 */
	public IVehicleService getVehicleService() {
		return this.vehicleService;
	}
	/**
	 * @param userService the userService to set
	 */
	public void setVehicleService(IVehicleService vehicleService) {
		this.vehicleService = vehicleService;
	}
	/**
	 * @return the vehicleId
	 */
	public String getVehicleId() {
		return vehicleId;
	}
	/**
	 * @param vehicleId the vehicleId to set
	 */
	public void setVehicleId(String vehicleId) {
		this.vehicleId = vehicleId;
	}
	/**
	 * @return the nickName
	 */
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
	public String getYear() {
		return year;
	}
	/**
	 * @param year the year to set
	 */
	public void setYear(String year) {
		this.year = year;
	}
	/**
	 * @return the make
	 */
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
	public String getImageData() {
		return imageData;
	}
	/**
	 * @param image the image to set
	 */
	public void setImageData(String imageData) {
		this.imageData = imageData;
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
	 * @return the transactionQueryId
	 */
	public String getTransactionQueryId() {
		return transactionQueryId;
	}

	/**
	 * @param transactionQueryId the transactionQueryId to set
	 */
	public void setTransactionQueryId(String transactionQueryId) {
		this.transactionQueryId = transactionQueryId;
	}

	/**
	 * @return the transactionId
	 */
	public long getTransactionId() {
		return transactionId;
	}

	/**
	 * @param transactionId the transactionId to set
	 */
	public void setTransactionId(long transactionId) {
		this.transactionId = transactionId;
	}

	/**
	 * @return the vehicle
	 */
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
	 * @return the vehicleList
	 */
	public List<Vehicle> getVehicleList() {
		return vehicleList;
	}
	/**
	 * @param vehicleList the vehicleList to set
	 */
	public void setVehicleList(List<Vehicle> vehicleList) {
		this.vehicleList = vehicleList;
	}
}
