/* PostgreSQL Basics */

/*----------------------------------------------------------------------------------*/

/* Querying data */

/* select */
SELECT * FROM ;

/* column alias */
SELECT CONCAT (first_name, ' ', last_name) as "Name" FROM person;

/* order by */
SELECT * FROM actor ORDER BY first_name, last_name;

/* select distinct */
SELECT DISTINCT country_id FROM city;

/*----------------------------------------------------------------------------------*/

/* Filtering data */

/* where */
SELECT city_id, city FROM city WHERE country_id = 44;

/* limit */ 
SELECT city_id, city FROM city WHERE country_id = 44 LIMIT 10;

/* offset */ 
SELECT city_id, city FROM city OFFSET 15 LIMIT 10;

/* fetch */ 
SELECT city_id, city FROM city OFFSET 15 FETCH FIRST 5 ROWS ONLY;

/* in */  
SELECT city_id, city FROM city WHERE country_id IN (44, 101);
SELECT city_id, city FROM city WHERE country_id NOT IN (44, 101);


/* between */
SELECT city_id, city FROM city WHERE country_id BETWEEN 1 AND 10;
SELECT city_id, city FROM city WHERE country_id NOT BETWEEN 1 AND 10;

/*----------------------------------------------------------------------------------*/

/* Joining multiple tables */

/* inner join */
SELECT city, country FROM city ci INNER JOIN country co ON ci.country_id = co.country_id;

/* right join */
SELECT f.film_id, fa.actor_id FROM film f RIGHT JOIN film_actor fa ON f.film_id = fa.film_id;

/* left join */
SELECT f.film_id, f.title, i.inventory_id FROM film f LEFT JOIN inventory i ON f.film_id = i.film_id;

/* self-join */
SELECT CONCAT(e.first_name, ' ', e.last_name) as "Employee", CONCAT(m.first_name, ' ', m.last_name) as "Manager"
FROM employee_manager e LEFT JOIN employee_manager m ON m.emp_id = e.manager_id;

/* cross join */
SELECT p.title, s.store_id FROM posts p CROSS JOIN store s;

/*----------------------------------------------------------------------------------*/

/* Grouping data */

/* group by */
SELECT customer_id, SUM(amount) FROM payment GROUP BY customer_id;

/* having */ 
SELECT customer_id, SUM(amount) FROM payment GROUP BY customer_id HAVING SUM(amount) > 200;

/*----------------------------------------------------------------------------------*/

/* Set operations */

/* union and union all */
SELECT * FROM items UNION SELECT * FROM most_sold_items;
SELECT * FROM items UNION ALL SELECT * FROM most_sold_items;

/* except */ 
SELECT * FROM most_sold_items EXCEPT SELECT * FROM items;

/* intersect */ 
SELECT * FROM most_sold_items INTERSECT SELECT * FROM items;

/*----------------------------------------------------------------------------------*/

/* Subquery */ 

/* subquery */
SELECT * FROM customer WHERE address_id IN (
	SELECT address_id FROM address WHERE city_id IN (
		SELECT city_id FROM city WHERE country_id IN (
			SELECT country_id FROM country WHERE country = 'India' )));

/* any */
SELECT title FROM film WHERE length >= ANY (
    SELECT MAX(length) FROM film INNER JOIN film_category USING(film_id)
    GROUP BY  category_id );

/* all */
SELECT title FROM film WHERE length > ALL (
	SELECT ROUND(AVG(length), 2) FROM film INNER JOIN film_category USING(film_id) GROUP BY category_id);

/* exists */
SELECT first_name, last_name FROM customer c WHERE EXISTS (
    SELECT 1 FROM payment p WHERE p.customer_id = c.customer_id AND amount > 11 );

/*----------------------------------------------------------------------------------*/

/* Modifying data */

/* insert */ 
INSERT INTO most_sold_items (product, price, discount) VALUES ('AA', 555, 5);

/* update */
UPDATE most_sold_items SET product = 'C' WHERE id = 3;

/* update join */


/* delete */
DELETE FROM most_sold_items WHERE id = 4;

/* delete join */ 


/* upsert  how to implement upsert functionality in postgres */
INSERT INTO most_sold_items (product, price, discount) VALUES ('C', 800, 5) 
ON CONFLICT (product) DO UPDATE SET price = EXCLUDED.price, discount = EXCLUDED.discount;

/*----------------------------------------------------------------------------------*/

/* Common table expression CTE */  

/* CTE */
WITH total_amount (customer_id, total_amount_per_customer) AS (
	SELECT customer_id, SUM(amount) AS total_amount_per_customer FROM payment GROUP BY customer_id),
	avg_amount (avg_amount_of_customer) AS (
		SELECT AVG(total_amount_per_customer) FROM total_amount)
SELECT customer_id, total_amount_per_customer FROM total_amount ta JOIN avg_amount aa
	ON ta.total_amount_per_customer > aa.avg_amount_of_customer;

/* recursive query using CTE */
WITH RECURSIVE emp_h AS (
	SELECT emp_id, first_name, manager_id, 1 AS lvl FROM employee_manager WHERE first_name = 'Windy'
	UNION
	SELECT m.emp_id, m.first_name, m.manager_id, e.lvl+1 as lvl FROM emp_h e JOIN employee_manager m on e.emp_id = m.manager_id)
SELECT e2.emp_id AS emp_id, e2.first_name AS Employee, m2.first_name AS Manager, e2.lvl AS level 
	FROM emp_h e2 JOIN employee_manager m2 ON e2.manager_id = m2.emp_id;

WITH RECURSIVE common AS (
	SELECT 1 AS n
	UNION
	SELECT n+1 FROM common WHERE n<10)
SELECT * FROM common;

/*----------------------------------------------------------------------------------*/

/* Transaction */

/* postgresql transaction */

/* Commit */ 
BEGIN TRANSACTION;
------
COMMIT TRANSACTION;

/* Rollback */
BEGIN TRANSACTION;
------
ROLLBACK TRANSACTION;

/*----------------------------------------------------------------------------------*/

/* Import and export data */

/* import csv file into table */
\copy persons(first_name, last_name, dob, email) 
FROM '/home/kishan/Downloads/persons.csv' DELIMITER ',' CSV HEADER;

/* export table to csv file */
\copy employee TO '/home/kishan/Desktop/employee.csv' DELIMITER ',' CSV HEADER;

/*----------------------------------------------------------------------------------*/

/* Managing tables */ 

/* postgresql data types */ 

/* create tables */
CREATE TABLE IF NOT EXISTS testing (
	id INT, test_name VARCHAR(10), test_score NUMERIC);	

/* select into */
SELECT city_id, city INTO india FROM city WHERE country_id = 44;
SELECT * FROM india;

/* create tables as */
CREATE TABLE action_film AS SELECT film_id, title FROM film
INNER JOIN film_category USING (film_id) WHERE category_id = 1;

/* serial */
CREATE TABLE table (id SERIAL);

/* sequences */
CREATE SEQUENCE mySeq INCREMENT BY 10 AS INT START 100;

/* identity column */
ALTER TABLE test ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY;

/* alter table */

/* rename table */
ALTER TABLE testing RENAME TO test;

/* add column */
ALTER TABLE test ADD COLUMN test_grade VARCHAR(5);

/* drop column */
ALTER TABLE test DROP COLUMN test_score;

/* change data type */
ALTER TABLE test ALTER COLUMN test_id TYPE BIGSERIAL;

/* rename column */
ALTER TABLE test RENAME COLUMN id TO test_id;

/* temporary table */
CREATE TEMP TABLE temp (id INT);

/* truncate tables */
TRUNCATE TABLE test;

/* drop table */
DROP TABLE test;

/*----------------------------------------------------------------------------------*/

/* Constraints in database */

/* primary key */
ALTER TABLE accounts ADD PRIMARY KEY (id);
ALTER TABLE accounts DROP CONSTRAINT accounts_pkey;

/* foreign key */
ALTER TABLE accounts ADD FOREIGN KEY (id) REFERENCES persons (id);
ALTER TABLE accounts DROP CONSTRAINT accounts_id_fkey;

/* check constraint */
ALTER TABLE accounts ADD CONSTRAINT balance_check CHECK (balance > 100);

/* unique constraint */
ALTER TABLE persons ADD UNIQUE (email);

/* not null constraint */
ALTER TABLE persons ALTER COLUMN name SET NOT NULL;

CREATE TABLE test (
	id BIGSERIAL,
	name VARCHAR(10) UNIQUE NOT NULL,
	date_ TIMESTAMP NOT NULL,
	t_id INT,
	salary INT CHECK (salary > 100),
	PRIMARY KEY (id),
	FOREIGN KEY (t_id) REFERENCES temp (id),
	);

/*----------------------------------------------------------------------------------*/

/* Conditional expressions and operators */

/* case */
SELECT SUM (CASE
			WHEN length > 0 AND length <= 50 THEN 1
			ELSE 0
			END) AS "Short",
		SUM (CASE
			WHEN length > 50 AND length <= 120 THEN 1
			ELSE 0
			END) AS "Medium",
		SUM (CASE
			WHEN length > 120 THEN 1
			ELSE 0
			END) AS "Large"
	FROM film;

SELECT payment_id, amount,
	CASE 
		WHEN amount > 0 AND amount < 4 THEN 'low'
		WHEN amount > 4 AND amount < 8 THEN 'medium'
		WHEN amount > 8 THEN 'high'
	END level
FROM payment;

/* coalesce */
SELECT COALESCE (NULL, NULL, 1, 2)
-- return first non null value from left side, 1.

/* null if */ 
SELECT NULLIF (1, 1) -- return NULL

SELECT NULLIF (1, 2) -- return 1, first argument

/* cast */ 
SELECT CAST ('2020-1-1 1:1' AS TIMESTAMP); -- 2020-01-01 01:01:00
SELECT CAST ('100' AS INTEGER);

/*----------------------------------------------------------------------------------*/

/* PostgreSQL recipes */

/* how to compare two tables? */
/* Using EXCEPT */
WITH cte1 AS (SELECT id, product, 'not in items' AS note FROM most_sold_items
EXCEPT
SELECT id, product, 'not in items' AS note FROM items),
cte2 AS (SELECT id, product, 'not in most_sold_items' AS note FROM items
EXCEPT
SELECT id, product, 'not in most_sold_items' AS note FROM most_sold_items)
SELECT * FROM cte1 UNION SELECT * FROM cte2;

/* Using JOIN */
SELECT id, product, 'not in most_sold_items' AS note FROM items LEFT JOIN most_sold_items USING (id, product)
WHERE most_sold_items.id IS NULL                                                                             
UNION                         
SELECT id, product, 'not in items' AS note FROM items RIGHT JOIN most_sold_items USING (id, product)
WHERE items.id IS NULL;

/* how to delete duplicate data  */
DELETE FROM basket WHERE id IN (
	SELECT id FROM (
		SELECT id, ROW_NUMBER() OVER (PARTITION BY fruit) AS row FROM basket)
	AS t WHERE t.row > 1);

/* explain statement execution plan of query */  
EXPLAIN (ANALYZE TRUE) SELECT * FROM city;

/*----------------------------------------------------------------------------------*/
