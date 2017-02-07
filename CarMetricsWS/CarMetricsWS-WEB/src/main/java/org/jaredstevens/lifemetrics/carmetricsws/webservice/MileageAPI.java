package org.jaredstevens.lifemetrics.carmetricsws.webservice;

import java.math.BigDecimal;
import java.util.List;

import javax.ejb.EJB;

import org.jaredstevens.lifemetrics.carmetricsws.db.entities.Mileage;
import org.jaredstevens.lifemetrics.carmetricsws.db.interfaces.IMileageService;
import org.jaredstevens.lifemetrics.carmetricsws.utils.Utils;

import com.opensymphony.xwork2.ActionSupport;

public class MileageAPI extends APIBase {
	private static final long serialVersionUID = 1L;
	@EJB(mappedName="MileageService")
	private IMileageService mileageService;
	
	private String mileageId;
	private String fillupDate;
	private String fuelVolume;
	private String fuelPrice;
	private String odometer;
	private String latitude;
	private String longitude;
	private String vehicleId;
	private String transactionQueryId;
	
	private long transactionId;
	private Mileage mileage;
	private List<Mileage> mileageList;
	
	public String getMileageById()
	{
		String retVal = ActionSupport.SUCCESS;
		long mileageId = -1;
		if(Utils.isPositiveNum(this.getMileageId())) mileageId = Long.parseLong(this.getMileageId());
		this.mileage = this.mileageService.getMileageById(mileageId);
		return retVal;
	}
	public String getMileageByVehicleId()
	{
		String retVal = ActionSupport.SUCCESS;
		long vehicleId = -1;
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		this.mileageList = this.mileageService.getMileageByVehicleId(vehicleId, 0, 50);
		return retVal;
	}
	public String getMileageAfterTransactionId()
	{
		String retVal = ActionSupport.SUCCESS;
		long transactionId = -1;
		long vehicleId = -1;
		if(Utils.isPositiveNum(this.getTransactionQueryId())) transactionId = Long.parseLong(this.getTransactionQueryId());
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		if(transactionId >= 0 && vehicleId > 0) {
			this.mileageList = this.mileageService.getMileageAfterTransactionId(transactionId, vehicleId);
			this.setTransactionId(this.mileageService.getLastTransactionId(vehicleId));
		}
		return retVal;
	}
	public String getLastTransactionId()
	{
		String retVal = ActionSupport.SUCCESS;
		long vehicleId = -1;
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		if(vehicleId > 0)
			this.setTransactionId(this.mileageService.getLastTransactionId(vehicleId));
		return retVal;
	}
	public String save()
	{
		String retVal = ActionSupport.SUCCESS;
		long mileageId = -1;
		long vehicleId = -1;
		long fillupDate = -1;
		BigDecimal fuelVolume = null;
		BigDecimal fuelPrice = null;
		int odometer = -1;
		int latitude = 0;
		int longitude = 0;
		if(Utils.isPositiveNum(this.getMileageId())) mileageId = Long.parseLong(this.getMileageId());
		if(Utils.isPositiveNum(this.getVehicleId())) vehicleId = Long.parseLong(this.getVehicleId());
		if(Utils.isPositiveNum(this.getFillupDate())) fillupDate = Long.parseLong(this.getFillupDate());
		if(this.getFuelVolume().length() > 0) fuelVolume = new BigDecimal(this.getFuelVolume());
		if(this.getFuelPrice().length() > 0) fuelPrice = new BigDecimal(this.getFuelPrice());
		if(Utils.isPositiveNum(this.getOdometer())) odometer = Integer.parseInt(this.getOdometer());
		
		latitude = Integer.parseInt(this.getLatitude());
		longitude = Integer.parseInt(this.getLongitude());
		if(Utils.isPositiveNum(this.getFillupDate())) fillupDate = Long.parseLong(this.getFillupDate());
		long txId = this.mileageService.save(mileageId, vehicleId, fillupDate, fuelVolume, fuelPrice, odometer, latitude, longitude);
		if(txId > 0L) {
			Mileage mileage = this.mileageService.getMileageByTransactionId(txId);
			this.setMileage(mileage);
			this.setTransactionId(txId);
		} else this.setMileage(null);
		return retVal;
	}
	public String remove()
	{
		String retVal = ActionSupport.SUCCESS;
		long mileageId = -1;
		if(Utils.isPositiveNum(this.getMileageId())) mileageId = Long.parseLong(this.getMileageId());
		this.setTransactionId(this.mileageService.remove(mileageId));
		return retVal;
	}
	
	/**
	 * @return the userService
	 */
	public IMileageService getMileageService() {
		return mileageService;
	}
	/**
	 * @param userService the userService to set
	 */
	public void setMileageService(IMileageService mileageService) {
		this.mileageService = mileageService;
	}
	/**
	 * @return the mileageId
	 */
	public String getMileageId() {
		return mileageId;
	}
	/**
	 * @param mileageId the mileageId to set
	 */
	public void setMileageId(String mileageId) {
		this.mileageId = mileageId;
	}
	/**
	 * @return the fillupDate
	 */
	public String getFillupDate() {
		return fillupDate;
	}
	/**
	 * @param fillupDate the fillupDate to set
	 */
	public void setFillupDate(String fillupDate) {
		this.fillupDate = fillupDate;
	}
	/**
	 * @return the fuelVolume
	 */
	public String getFuelVolume() {
		return fuelVolume;
	}
	/**
	 * @param fuelVolume the fuelVolume to set
	 */
	public void setFuelVolume(String fuelVolume) {
		this.fuelVolume = fuelVolume;
	}
	/**
	 * @return the fuelPrice
	 */
	public String getFuelPrice() {
		return fuelPrice;
	}
	/**
	 * @param fuelPrice the fuelPrice to set
	 */
	public void setFuelPrice(String fuelPrice) {
		this.fuelPrice = fuelPrice;
	}
	/**
	 * @return the odometer
	 */
	public String getOdometer() {
		return odometer;
	}
	/**
	 * @param odometer the odometer to set
	 */
	public void setOdometer(String odometer) {
		this.odometer = odometer;
	}
	public String getLatitude() {
		return latitude;
	}
	public void setLatitude(String latitude) {
		this.latitude = latitude;
	}
	public String getLongitude() {
		return longitude;
	}
	public void setLongitude(String longitude) {
		this.longitude = longitude;
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
	 * @return the mileage
	 */
	public Mileage getMileage() {
		return mileage;
	}
	/**
	 * @param mileage the mileage to set
	 */
	public void setMileage(Mileage mileage) {
		this.mileage = mileage;
	}
	/**
	 * @return the mileageList
	 */
	public List<Mileage> getMileageList() {
		return mileageList;
	}
	/**
	 * @param mileageList the mileageList to set
	 */
	public void setMileageList(List<Mileage> mileageList) {
		this.mileageList = mileageList;
	}
}