package org.jaredstevens.lifemetrics.carmetricsws.db.services;
import java.util.List;

import javax.ejb.Remote;
import javax.ejb.Stateless;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceContextType;
import javax.persistence.Query;

import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User.UserStatus;
import org.jaredstevens.lifemetrics.carmetricsws.db.interfaces.IUserService;

/**
 * @author jstevens
 *
 */
@Stateless(name="UserService",mappedName="UserService")
@Remote
public class UserService implements IUserService {
	@PersistenceContext(unitName="LifeMetricsPU",type=PersistenceContextType.TRANSACTION)
	private EntityManager em;
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public User getUserById(long userId) {
		User retVal = null;
		if(userId > 0)
		{
			retVal = (User)this.getEm().find(User.class, userId);
		}
		return retVal;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public User authenticate(String username, String password)
	{
		User retVal = null;
		String saltedPassword = User.getSaltedPassword(password);
		UserStatus status = UserStatus.ACTIVE;
		String sql = "SELECT u FROM User u WHERE u.username=:username AND u.password=:password AND u.status=:status";
		Query q = this.getEm().createQuery(sql);
		q.setParameter("username", username);
		q.setParameter("password", saltedPassword);
		q.setParameter("status", status);
		try {
			retVal = (User)q.getSingleResult();
		} catch(NoResultException e){
		}
		return retVal;
	}
	
	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public User getUserByUsername( String username ) {
		User retVal = null;
		String sql;
		sql = "SELECT u FROM User u WHERE u.username=:username ORDER BY u.id ASC";
		Query q = this.getEm().createQuery(sql);
		q.setParameter("username", username);
		retVal = (User)q.getSingleResult();
		return retVal;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public User getUserByEmail( String email ) {
		User retVal = null;
		String sql;
		sql = "SELECT u FROM User u WHERE u.email=:email ORDER BY u.id ASC";
		Query q = this.getEm().createQuery(sql);
		q.setParameter("email", email);
		retVal = (User)q.getSingleResult();
		return retVal;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public List<User> getUsers( int startIndex, int resultCount ) {
		List<User> retVal = null;
		String sql;
		sql = "SELECT u FROM User u ORDER BY u.id ASC";
		Query q = this.getEm().createQuery(sql);
		q.setFirstResult(startIndex);
		q.setMaxResults(resultCount);
		retVal = (List<User>)q.getResultList();
		return retVal;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public User save(long userId, String username, String password, String firstName, String lastName, String email,
			boolean emailVerified, UserStatus status) {
		User user = null;
		if(userId > 0)
			user = (User)this.em.find(User.class, userId);
		if(user == null) {
			user = new User();
			user.setCreateDate(System.currentTimeMillis()/1000);
		}
		user.setUsername(username);
		user.setSaltedPassword(password);
		user.setFirstName(firstName);
		user.setLastName(lastName);
		user.setEmail(email);
		user.setEmailVerified(emailVerified);
		user.setStatus(status);
		this.getEm().persist(user);
		return user;
	}

	@TransactionAttribute(TransactionAttributeType.REQUIRED)
	public boolean remove(long userId) {
		boolean retVal = false;
		if(userId > 0) {
			User user = null;
			user = (User)this.getEm().find(User.class, userId);
			if(user != null) this.getEm().remove(user);
			if(this.getEm().find(User.class, userId) == null) retVal = true;
		}
		return retVal;
	}

	/**
	 * @return the em
	 */
	public EntityManager getEm() {
		return em;
	}

	/**
	 * @param em the em to set
	 */
	public void setEm(EntityManager em) {
		this.em = em;
	}
}
