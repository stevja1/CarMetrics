package org.jaredstevens.lifemetrics.carmetricsws.db.interfaces;

import java.util.List;

import javax.ejb.Remote;

import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User;
import org.jaredstevens.lifemetrics.carmetricsws.db.entities.User.UserStatus;

@Remote
public interface IUserService {
	public User getUserById( long userId );
	public User authenticate(String username, String password);
	public User getUserByUsername( String username );
	public User getUserByEmail( String email );
	public List<User> getUsers( int startIndex, int resultCount );
	public User save( long userId, String username, String password, String firstName, String lastName, String email, boolean emailVerified, UserStatus status );
	public boolean remove( long userId );
}
