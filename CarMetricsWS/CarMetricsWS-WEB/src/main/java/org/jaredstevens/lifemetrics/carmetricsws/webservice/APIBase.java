package org.jaredstevens.lifemetrics.carmetricsws.webservice;

import com.opensymphony.xwork2.ActionSupport;

public class APIBase extends ActionSupport {
	private static final long serialVersionUID = 1L;
	private String result;
	private String message;
	/**
	 * @return the result
	 */
	public String getResult() {
		return result;
	}
	/**
	 * @param result the result to set
	 */
	public void setResult(String result) {
		this.result = result;
	}
	/**
	 * @return the message
	 */
	public String getMessage() {
		return message;
	}
	/**
	 * @param message the message to set
	 */
	public void setMessage(String message) {
		this.message = message;
	}
	
}
