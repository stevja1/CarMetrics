package org.jaredstevens.lifemetrics.carmetricsws.utils; 

public class Utils {
	public static boolean isPositiveNum( String inString )
	{
		boolean retVal = false;
		if(inString != null && inString.length() > 0 && Long.parseLong(inString) >= 0) retVal = true;
		return retVal;
	}
}
