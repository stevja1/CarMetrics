-- CREATE A USER
-- The password here is an md5 hash of the string 'phoenixdevpassword'
CREATE USER 'phoenix'@'localhost' IDENTIFIED BY '945ed1f88e2fe76931f74318effcee70';
GRANT ALL PRIVILEGES ON phoenix.* TO 'phoenix'@'localhost' WITH GRANT OPTION;

-- CREATE THE DATABASE
CREATE DATABASE phoenix;
