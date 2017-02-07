package org.jaredstevens.lifemetrics.carmetricsws.utils; 

import java.lang.reflect.Field;

import javax.ejb.EJB;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

/**
 * This is here because Struts 2 apparently doesn't deal well with the EJB notations. As a result,
 * the required dependency injection doesn't work at all and you wind up getting a NullPointerException.
 * Struts runs this code (via the EJBAnnotationProcessorInterceptor class) prior to running the requested method in
 * the Action class. This code reflects the our API classes and finds the EJB annotations. It uses the 'mappedName'
 * property in the annotation to lookup the EJB via JNDI. It then sets the value of the variable.
 * 
 * This is the web site that helped me figure this out:
 * http://longsystemit.com/javablog/?p=40
 * 
 * @author jstevens
 *
 */
public class EJBAnnotationProcessor {
	public static void process(Object instance)throws Exception{
 		Field[] fields = instance.getClass().getDeclaredFields();
 		if(fields != null && fields.length > 0){
 			EJB ejb;
 			for(Field field : fields){
 				ejb = field.getAnnotation(EJB.class);
 				if(ejb != null){
 					field.setAccessible(true);
 					field.set(instance, EJBAnnotationProcessor.getEJB(ejb.mappedName()));
 				}
 			}
 		}
 	}
	
	private static Object getEJB(String mappedName) {
		Object retVal = null;
		String path = "";
		Context cxt = null;
		/**
		 * I got this string from looking at the server output log in JBOSS 7.1 (my sandbox)
		 * java:global/PhoenixEAR-1.0-SNAPSHOT/PhoenixWEB-1.0-SNAPSHOT/RuleOps!com.novell.ist.toolbox.phoenix.db.interfaces.IRuleOps
		 * java:app/PhoenixWEB-1.0-SNAPSHOT/RuleOps!com.novell.ist.toolbox.phoenix.db.interfaces.IRuleOps
		 * java:module/RuleOps!com.novell.ist.toolbox.phoenix.db.interfaces.IRuleOps
		 * java:jboss/exported/PhoenixEAR-1.0-SNAPSHOT/PhoenixWEB-1.0-SNAPSHOT/RuleOps!com.novell.ist.toolbox.phoenix.db.interfaces.IRuleOps
		 * java:global/PhoenixEAR-1.0-SNAPSHOT/PhoenixWEB-1.0-SNAPSHOT/RuleOps
		 * java:app/PhoenixWEB-1.0-SNAPSHOT/RuleOps
		 * java:module/RuleOps
		 * 
		 * On WebSphere 7, its different. Use the WS7/bin/dumpNameSpace.sh script to see the JNDI directory
		 */
		String[] paths = {
				"cell/nodes/sonicNode01/servers/server1/",
				"cell/nodes/virgoNode01/servers/server1/",
				"java:module/"
				};
		for( int i=0; i < paths.length; ++i )
		{
			try {
				path = paths[i]+mappedName;
				cxt = new InitialContext();
				retVal = cxt.lookup(path);
				if(retVal != null) break;
			} catch (NamingException e) {
				retVal = null;
			}
			System.out.println("Tried: "+path+" Result: "+retVal);
		}
		System.out.println(path+" worked");
		return retVal;
	}
}
