/* Postgres pl/pgsql */

/*----------------------------------------------------------------------------------*/

/* Variable and Constants */

/* Variables */
DO $$
DECLARE
	first_name VARCHAR(10) = 'Kishan';
	last_name VARCHAR(10) = 'Modasiya';
BEGIN
	RAISE NOTICE '% %', first_name, last_name;
END $$ ;

/* Select Into */
DO $$
DECLARE 
	film_title film.title%TYPE;
BEGIN
	SELECT title FROM film INTO film_title WHERE film_id = 1;
	RAISE NOTICE '%', film_title;
END $$ ;

/* Row Types */
DO $$
DECLARE 
	film_ film%ROWTYPE;
BEGIN
	SELECT * FROM film INTO film_ WHERE film_id = 1;
	RAISE NOTICE '% - %', film_.film_id, film_.title;
END $$ ;

/* Record Type */
DO $$
DECLARE 
	rec record;
BEGIN
	SELECT * FROM film INTO rec WHERE film_id = 1;
	RAISE NOTICE '% - %', rec.film_id, rec.title;
END $$ ;

/* Constants */
DO $$
DECLARE
	val CONSTANT INT = 10;
BEGIN
	RAISE NOTICE 'Value of val - %', val;
END $$ ;

/*----------------------------------------------------------------------------------*/

/* Error and Messages */
DO $$ 
BEGIN 
  RAISE INFO 'information message %', now() ;
  RAISE LOG 'log message %', now();
  RAISE DEBUG 'debug message %', now();
  RAISE WARNING 'warning message %', now();
  RAISE NOTICE 'notice message %', now();
END $$ ;

/* Assert Statement */
DO $$
DECLARE
	person INT = 0;
BEGIN
	SELECT COUNT(*) FROM temp INTO person;
	ASSERT person > 10, 'Person not found.';
END $$ ;

/*----------------------------------------------------------------------------------*/

/* Control Structure */

/* If Else Statement */
DO $$
DECLARE
	total INT = 0;
	id_ INT = 100;
BEGIN
	SELECT SUM(amount) FROM payment INTO total GROUP BY customer_id HAVING customer_id = id_;
	IF total < 100 THEN
		RAISE NOTICE 'Payment is low';
	ELSEIF total BETWEEN 100 AND 200 THEN
		RAISE NOTICE 'Payment is medium';
	ELSE
		RAISE NOTICE 'Payment is high';
	END IF;
END $$ ;

/* Case Statement */
UPDATE employee
SET dept_name = 
  	CASE 
    	WHEN dept_name = 'IT' THEN 'Engineering'
    	WHEN dept_name = 'Finance' THEN 'Marketing'
    	ELSE 'Administration'
	END;

/* Case Expression */
SELECT emp_name, dept_name,
  CASE 
    WHEN dept_name = 'IT' THEN 'Tech'
    WHEN dept_name = 'Finance' THEN 'Sales'
    ELSE 'Other'
  END AS category
FROM employee;

/* Case Search Expression */
SELECT name, dept_name
FROM employee
WHERE 
  CASE 
    WHEN name LIKE '%Ma%' THEN 1
    WHEN dept_name LIKE '%Ma%' THEN 1
    ELSE 0
  END = 1;

/* Loop Statement */
DO $$
DECLARE
	fact INT = 1;
	counter INT = 0;
	n INT = 5;
BEGIN
	LOOP
		counter = counter + 1;
		fact = fact * counter;
		EXIT WHEN counter = n;
	END LOOP;
	RAISE NOTICE '%', fact;
END $$ ;

/* While Loop */
DO $$
DECLARE
	fact INT = 1;
	counter INT = 1;
BEGIN
	WHILE counter <= 5 LOOP
		fact = fact * counter;
		counter = counter + 1;
	END LOOP;
	RAISE NOTICE '%', fact;
END $$ ;
		
/* For Loop */
DO $$
BEGIN
	FOR counter IN REVERSE 10..1 BY 2 LOOP
		RAISE NOTICE '%', counter;
	END LOOP;
END $$ ;

/* Exit */
DO $$
BEGIN
	FOR counter IN REVERSE 10..1 BY 2 LOOP
		EXIT WHEN counter < 5;
		RAISE NOTICE '%', counter;
	END LOOP;
END $$ ;

/* Continue */
DO $$
BEGIN
	FOR counter IN REVERSE 10..1 BY 2 LOOP
		CONTINUE WHEN counter = 4;
		RAISE NOTICE '%', counter;
	END LOOP;
END $$ ;

/*----------------------------------------------------------------------------------*/

/* Exception Handling */
DO $$
BEGIN
  SELECT * FROM fil;
EXCEPTION
  WHEN SQLSTATE '42P01' THEN
      RAISE NOTICE 'There was an ERROR. %', SQLERRM;
END $$ ;

/*----------------------------------------------------------------------------------*/

/* User Defined Function */

/* Create Function */
CREATE FUNCTION get_film_title(id INT)
RETURNS film.title%TYPE
LANGUAGE plpgsql
AS
$$
DECLARE
	film_title film.title%TYPE;
BEGIN
	SELECT title FROM film INTO film_title WHERE film_id = id;
	RETURN film_title;
END $$ ;

SELECT get_film_title (10);

/* Function Parameter modes */
CREATE OR REPLACE FUNCTION get_stat (OUT min_amount int, OUT max_amount int, OUT avg_amount int)
LANGUAGE plpgsql
AS
$$
BEGIN
	SELECT MIN(amount), MAX(amount), AVG(amount) FROM payment INTO min_amount, max_amount, avg_amount;
END $$ ;

SELECT get_stat();
SELECT * FROM get_stat();

CREATE OR REPLACE FUNCTION in_out (IN x int, OUT y int, INOUT z int)
LANGUAGE plpgsql
AS
$$
BEGIN
	RAISE NOTICE '%, %, %', x, y, z;
	y = x * 10;
	RAISE NOTICE '%, %, %', x, y, z;
	z = y * z;
	RAISE NOTICE '%, %, %', x, y, z;
END $$ ;

SELECT * FROM in_out (10, 10)

CREATE OR REPLACE FUNCTION myfunction (INOUT x int, INOUT y int)
LANGUAGE plpgsql
AS
$$
BEGIN
	x = x*10;
	y = y*5;
END $$;

SELECT * FROM myfunction(10,5);

/* Function Overloading */
CREATE OR REPLACE FUNCTION myfunction (INOUT x int)
LANGUAGE plpgsql
AS
$$
BEGIN
	x = x*10;
END $$;

/* Function that returns table */
CREATE OR REPLACE FUNCTION get_country (country_ INT)
RETURNS TABLE (city_id int,
			  city_name varchar,
			  country_id int,
			  country_name varchar )
LANGUAGE plpgsql
AS
$$
BEGIN
	RETURN QUERY
		SELECT ci.city_id, ci.city, co.country_id, co.country FROM city ci 
		JOIN country co USING (country_id) WHERE ci.country_id = country_;
END $$ ;

SELECT * FROM get_country (44);

CREATE OR REPLACE get_country (country_ INT)
RETURNS TABLE (city_id int,
			  city_name varchar,
			  country_id int,
			  country_name varchar )
LANGUAGE plpgsql
AS
$$
DECLARE
	rec record;
BEGIN
	FOR rec IN (
		SELECT ci.city_id, ci.city, co.country_id, co.country FROM city ci 
		JOIN country co USING (country_id) WHERE ci.country_id = country_ ) LOOP
		city_id = rec.city_id;
		city_name = rec.city;
		country_id = rec.country_id;
		country_name = rec.country;
		RETURN NEXT;
	END LOOP;
END $$ ;

/*----------------------------------------------------------------------------------*/

/* Store Procedures */
CREATE PROCEDURE myproc(IN p1 integer, OUT p2 integer, INOUT p3 integer) AS $$
BEGIN
  -- Modify the INOUT parameter
  p3 := p3 + 1;

  -- Perform some computation and assign the result to the OUT parameter
  p2 := p1 * p3;
END;
$$ LANGUAGE plpgsql;

CALL myproc(p1:=5, p2 :=null, p3:=10);

/*----------------------------------------------------------------------------------*/

/* Cursors */
DO $$
DECLARE 
	id_ int;
	name_ varchar(50);
	cursor1 CURSOR FOR SELECT city_id, city FROM city WHERE country_id = 44;
BEGIN
	OPEN cursor1;
	FETCH LAST cursor1 INTO id_, name_;
	LOOP
		FETCH cursor1 INTO id_, name_;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '% - %', id_, name_;
	END LOOP;
	CLOSE cursor1;
END $$ ;

CREATE TABLE auditdata (
		log_id SERIAL PRIMARY KEY,
		log_text VARCHAR(50),
		log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

/*----------------------------------------------------------------------------------*/

/* Trigger Functions */
CREATE OR REPLACE FUNCTION insert_log() 
RETURNS TRIGGER	
AS $$
DECLARE
	id_ int;
BEGIN
	INSERT INTO auditdata(log_text) VALUES ('New Person added with ID ' || new.id);
	RETURN NEW;
END; 
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER insert_log_audit
AFTER INSERT ON temp
FOR EACH ROW
EXECUTE FUNCTION insert_log();

INSERT INTO temp (id, name) VALUES (12, 'SHAWN');

SELECT * FROM temp;
SELECT * FROM auditdata;

ALTER TABLE temp DISABLE TRIGGER ALL

ALTER TABLE temp ENABLE TRIGGER ALL

/*----------------------------------------------------------------------------------*/

/* Function */

/* Aggregate Function */
SELECT AVG(amount) FROM payment
SELECT MAX(amount) FROM payment
SELECT MIN(amount) FROM payment
SELECT SUM(amount) FROM payment
SELECT COUNT(*) FROM payment

SELECT customer_id, array_agg(rental_id), array_length(array_agg(rental_id),1) as transaction, sum(return_date - rental_date) as duration 
FROM rental GROUP BY customer_id ORDER BY transaction DESC LIMIT 10;

SELECT f.title, STRING_AGG (a.first_name || ' ' || a.last_name, ', ') actors
FROM film f INNER JOIN film_actor fa USING (film_id) INNER JOIN actor a USING (actor_id) GROUP BY f.title;


/* Window Function */
SELECT EMP_NAME, DEPT_NAME, SUM(SALARY) OVER(PARTITION BY DEPT_NAME ORDER BY SALARY) FROM EMPLOYEE
SELECT *, ROUND(CUME_DIST() OVER (PARTITION BY GENDER ORDER BY SALARY)::NUMERIC ,2) FROM EMPLOYEE 																					-- CUME_DIST()
SELECT *, ROUND(PERCENT_RANK() OVER (PARTITION BY GENDER ORDER BY SALARY)::NUMERIC ,2) FROM EMPLOYEE 																				--PERCENT_RANK()
SELECT * FROM (SELECT payment_id, customer_id, staff_id, RANK() OVER(ORDER BY amount DESC) AS arank FROM payment) l WHERE arank <= 10 			--RANK()
SELECT * FROM (SELECT payment_id, customer_id, staff_id, DENSE_RANK() OVER(ORDER BY amount DESC) AS arank FROM payment) l WHERE arank <= 2 	--DENSE_RANK()
SELECT EMP_NAME, DEPT_NAME, GENDER, SALARY, LEAD(SALARY, 1, -1) OVER (PARTITION BY GENDER ORDER BY DEPT_NAME) FROM EMPLOYEE									-- LEAD()
SELECT EMP_NAME, DEPT_NAME, GENDER, SALARY, LAG(SALARY, 1, -1) OVER (PARTITION BY GENDER ORDER BY DEPT_NAME) FROM EMPLOYEE									-- LAG()
SELECT EMP_NAME, DEPT_NAME, GENDER, SALARY, ROW_NUMBER() OVER (PARTITION BY GENDER ORDER BY SALARY DESC) FROM EMPLOYEE											-- ROW_NUMBER()
SELECT EMP_NAME, DEPT_NAME, GENDER, SALARY, NTILE(3) OVER (ORDER BY SALARY) FROM EMPLOYEE																										-- NTILE()
SELECT *, NTH_VALUE(DEPT_NAME, 2) OVER (PARTITION BY GENDER ORDER BY SALARY) FROM EMPLOYEE																									-- NTH_VALUE()
SELECT DEPT_NAME, GENDER, SUM(SALARY) FROM EMPLOYEE GROUP BY GROUPING SETS((DEPT_NAME, GENDER), (DEPT_NAME), (GENDER), ())
SELECT DEPT_NAME, GENDER, SUM(SALARY) FROM EMPLOYEE GROUP BY CUBE(DEPT_NAME, GENDER)


/* Date Function */
SELECT AGE('2023-03-06','2001-12-03')													-- 21 years 3 mons 3 days
SELECT AGE(TIMESTAMP '2001-12-03')														-- 21 years 3 mons 6 days
SELECT CURRENT_DATE																						-- 2023-03-09
SELECT CURRENT_TIME 																					-- 13:38:44.521660+05:30
SELECT CURRENT_TIME(3)																				-- 13:38:44.522000+05:30
SELECT CURRENT_TIMESTAMP(2)																		-- 2023-03-09 13:38:44.52+05:30
SELECT DATE_PART('YEAR', CURRENT_TIMESTAMP)										-- 2023
SELECT DATE_TRUNC('YEAR', CURRENT_DATE)												-- 2023-01-01 00:00:00+05:30
SELECT LOCALTIME  																						-- 13:38:44.52166
SELECT LOCALTIMESTAMP																					--2023-03-09 13:38:44.52166
SELECT EXTRACT(SECOND FROM CURRENT_TIMESTAMP)									-- 44.521660
SELECT EXTRACT(MONS FROM INTERVAL '21 years 3 mons 3 days')		-- 3
SELECT TO_DATE('20120202', 'YYYYMMDD')												-- 2012-02-02
SELECT TO_DATE('12 JAN 1', 'YYMOND')													-- 2012-01-01
SELECT NOW()::DATE 																						-- 2023-03-09
SHOW TIMEZONE																									-- Asia/Kolkata
SELECT TIMEOFDAY()																						-- Thu Mar 09 13:42:10.964577 2023 IST
SELECT DATE_TRUNC('HOUR', NOW())															-- 2023-03-09 13:00:00+05:30


/* String Function */
SELECT ASCII('A')																	-- 65
SELECT CHR(65)																		-- A
SELECT CONCAT('A','B')														-- AB
SELECT CONCAT_WS(',','A','B','C')									-- A,B,C
SELECT FORMAT('HELLO %s', 'WORLD')								-- HELLO WORLD
SELECT INITCAP('hello world')											-- Hello World
SELECT LEFT('POSTGRESQL',4)												-- POST
SELECT RIGHT('POSTGRESQL',3)											--SQL
SELECT LENGTH('POSTGRESQL')												-- 10
SELECT LPAD('POSTGRES', 10, '/')									-- //POSTGRES
SELECT RPAD('POSTGRES', 10, '/')									-- POSTGRES//
SELECT TRIM('0' FROM '0000154000')								-- 154
SELECT LTRIM('000152000', '0')										-- 152000
SELECT RTRIM('000152000', '0')										-- 000152
SELECT BTRIM('000152000', '0')										-- 152
SELECT POSITION ('12' IN '4567125578')						-- 5
SELECT SUBSTRING ('POSTGRESQL', 2,3)							-- OST
SELECT REPLACE('12345','1','0')										-- 02345
SELECT MD5('POSTGRES')														-- 3844e1d819be690fa5e18b5c89281934

