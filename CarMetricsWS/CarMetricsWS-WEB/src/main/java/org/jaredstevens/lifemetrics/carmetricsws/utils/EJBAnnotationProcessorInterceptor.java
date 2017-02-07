package org.jaredstevens.lifemetrics.carmetricsws.utils;

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.Interceptor;

public class EJBAnnotationProcessorInterceptor implements Interceptor {
	private static final long serialVersionUID = 1L;

	public void destroy() {
		// TODO Auto-generated method stub

	}

	public void init() {
		// TODO Auto-generated method stub

	}

	public String intercept(ActionInvocation ai) throws Exception {
 		EJBAnnotationProcessor.process(ai.getAction());
 		return ai.invoke();
 	}
}
