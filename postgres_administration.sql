/* PostgreSQL Administration */

/*----------------------------------------------------------------------------------*/

/* Managing Database */

/* Create Database */
CREATE DATABASE demo
	WITH
	encoding = 'UTF8'
	owner = 'kishan'
	connection limit = 10
	template = 'kishan'
	allow_connections = true
	is_template = false

/* Active Session */
SELECT *
FROM pg_stat_activity
WHERE datname = 'Test';

/* Terminate Session */
SELECT pg_terminate_backend (pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'Test';

/* Alter Database */
ALTER DATABASE demo1 RENAME TO demo

ALTER DATABASE demo OWNER TO usr

ALTER DATABASE demo SET TABLESPACE new_ts


/* Drop Database */
DROP DATABASE demo


/* Copy DATABASE */
CREATE DATABASE demo WITH TEMPLATE 'Test'

/* Dump source database file */
pg_dump -U postgres -h localhost -W -d Test -f /home/kishan/Desktop/test.sql

/* Restore Database */
psql -U postgres -h localhost -d demo -f /home/kishan/Desktop/test.sql

/*----------------------------------------------------------------------------------*/

/* Managing Schema */

/* Create Schema */
CREATE SCHEMA private
CREATE SCHEMA IF NOT EXISTS AUTHORIZATION kishan

/* Alter Schema */
ALTER SCHEMA private RENAME TO demo
ALTER SCHEMA demo OWNER TO kishan

/* Drop Schema */
DROP SCHEMA demo

/*----------------------------------------------------------------------------------*/

/* Managing Tablespace */

/* Creating Tablespace */
CREATE TABLESPACE tb OWNER kishan LOCATION '/home/kishan/PostgreSQL'

/* Changing Tablespace */
ALTER TABLESPACE tb RENAME TO new_tb
ALTER TABLESPACE tb kishan TO postgres

/* Delete Tablespace */ 
DROP TABLESPACE IF EXISTS tb

/*----------------------------------------------------------------------------------*/

/* Role amd Privileges */

/* Create Role */
CREATE ROLE temparory SUPERUSER LOGIN
PASSWORD 'temp'
CONNECTION LIMIT 100
VALID UNTIL '2023-03-08'

/* Grant Role */
GRANT SELECT, INSERT, DELETE, UPDATE ON temp TO kishan
GRANT ALL ON test TO kishan
GRANT ALL ON ALL TABLES IN SCHEMA "public" TO temparory

/* Revoke Role */
REVOKE ALL ON ALL TABLES IN SCHEMA "public" FROM temparory

/* Alter Role */
ALTER ROLE demo RENAME TO test

/* Drop Role */
REASSIGN OWNED BY test TO temparory
DROP OWNED BY test
DROP ROLE test

/*----------------------------------------------------------------------------------*/

/* Backup and Restore Database */

/* Backup */
pg_dump -U postgres -h localhost -d Test -F T -f Test.tar
PGPASSFILE = .pgpass pg_dumpall -U postgres -h localhost -f all.tar

/* Restore */
psql -U postgres -h localhost -d temp -f Test.dump
pg_restore -U postgres -h localhost -d demo Test.tar

/*----------------------------------------------------------------------------------*/
