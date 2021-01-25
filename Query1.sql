USE sql_store;

SELECT *
From customers
WHERE state = 'VA' && birth_date = '1986-03-28'
ORDER BY first_name;

USE sql_store;
SELECT *, quantity*unit_price AS new_price
From order_items
WHERE product_id IN (1,2,3);

SELECT *
From products
WHERE quantity_in_stock IN (49,38,72);

SELECT *
From customers
WHERE birth_date BETWEEN '1990-01-01' AND '2020-01-01';


SELECT *
From customers
WHERE address LIKE '%TRAIL%' OR address LIKE '%AVENUE%';

SELECT *
From customers
WHERE phone LIKE '%9';

SELECT *
From customers
WHERE first_name REGEXP 'ELKA|AMBUR';

SELECT *
From customers
WHERE last_name REGEXP 'EY$|ON$';

SELECT *
From customers
WHERE last_name REGEXP '^MY|SE';


SELECT *
From customers
WHERE last_name REGEXP 'B[RU]';

SELECT *
From orders
WHERE shipped_date IS NULL;


SELECT *
From order_items
WHERE order_id = 2
ORDER BY quantity*unit_price DESC;


SELECT *
From customers
ORDER BY points DESC
LIMIT 3;


SELECT oi.order_id, oi.product_id, oi.quantity, oi.unit_price
From order_items oi
JOIN products p 
     ON oi.product_id = p.product_id;
     
SELECT p.product_id, p.name, oi.quantity
FROM products p
LEFT JOIN order_items oi
	ON p.product_id = oi.product_id 
ORDER BY product_id;
     
SELECT o.order_date, o.order_id, c.first_name, s.name AS shippers, os.name
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
LEFT JOIN shippers s
	ON o.shipper_id = s.shipper_id
LEFT JOIN order_statuses as os
	ON o.status = os.order_status_id;

    


     
USE sql_invoicing;

SELECT p.date, c.name AS client, p.amount, pm.name
FROM payments p
JOIN clients c
     USING (client_id)
JOIN payment_methods pm 
     ON p.payment_method = pm.payment_method_id;
     
     
USE sql_store;

SELECT *
FROM shippers s
CROSS JOIN products p;

SELECT customer_id, first_name, points, 'Bronze' AS type
FROM customers
WHERE points < 2000
UNION
SELECT customer_id, first_name, points, 'Silver' AS type
FROM customers
WHERE points BETWEEN 2000 AND 3000
UNION
SELECT customer_id, first_name, points, 'Gold' AS type
FROM customers
WHERE points >= 3000
ORDER BY first_name;

USE sql_inventory;
INSERT INTO products (name, quantity_in_stock, unit_price)
VALUES (' name5',50, 1.50),
	('name6', 150, 2.50),
    ('name7', 250, 3.50);
    
update products set name = trim(name);
    
UPDATE customers
SET points = points + 50
WHERE birth_date < '1990-01-01';

    
UPDATE orders
SET comments = 'gold customers'
WHERE customer_id IN
				(SELECT customer_id
				FROM customers
				WHERE points > 3000);

USE sql_invoicing;

(SELECT
	name,
	LENGTH(name) AS total_char
FROM clients
GROUP BY name
ORDER BY LENGTH(name) ASC, name 
LIMIT 1)
UNION
(SELECT 
	name,
	LENGTH(name) AS total_char
FROM clients
ORDER BY LENGTH(name) DESC, name
LIMIT 1);

SELECT first_name
FROM customers
WHERE first_name NOT REGEXP  '^[aeiou].*[aeiou]$';
-- ^			// start of string
-- [aeiou]			// a single vowel
-- .			// any characted...
-- *			// ...repeated any number of times
-- [aeiou]			// another vowel
-- $			// end of string
SELECT first_name
FROM customers
WHERE first_name NOT REGEXP  '^[aeiou]' OR '[aeiou]$';


SELECT customer_id,first_name
FROM customers
WHERE points > 1000
ORDER BY customer_id ASC;


USE sql_invoicing;

SELECT p.date, pm.name,
SUM(p.amount) AS total_payments
FROM payments p
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id
GROUP BY p.date, pm.name
ORDER BY p.date, pm.name DESC;

USE sql_store;
SELECT c.customer_id, c.first_name, c.state, SUM(oi.quantity * oi.unit_price) AS total
FROM customers c
JOIN orders o
	USING (customer_id)
CROSS JOIN order_items oi
	USING (order_id)
WHERE c.state IN ('VA', 'MA','CO')
GROUP BY c.customer_id,c.first_name, c.state
HAVING total > 100;

SELECT pm.name, SUM(p.amount) AS total
FROM payments p
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id
GROUP BY pm.name WITH ROLLUP;



USE sql_hr;
SELECT *
FROM employees
WHERE salary > (
	SELECT AVG(salary) AS average
	FROM employees);
    
SELECT *
FROM clients
WHERE client_id NOT IN (
	SELECT DISTINCT client_id
	FROM invoices
);


SELECT *
FROM customers
WHERE customer_id IN (
SELECT o.customer_id
FROM order_items oi
JOIN orders o USING (order_id)
WHERE oi.product_id = 3
);

SELECT *
FROM invoices i
WHERE invoice_total > (SELECT AVG(invoice_total) as client_invoice_avg
FROM invoices
WHERE client_id = i.client_id
);

SELECT *
FROM products p
WHERE p.product_id NOT IN ( 
					SELECT DISTINCT oi.product_id 	
                    FROM order_items oi
                    WHERE p.product_id = oi.product_id
);

USE sql_invoicing;

SELECT name, (SELECT SUM(invoice_total) 
				FROM invoices
				WHERE client_id = c.client_id) AS client_invoice_sum,
				(SELECT AVG(invoice_total) 
				FROM invoices) AS client_invoice_avg,
				(SELECT client_invoice_sum - client_invoice_avg) AS diff
FROM clients c;

USE sql_store;

SELECT *
FROM 
(SELECT CONCAT(city, '(',SUBSTRING(state,1,1),')') AS CON
FROM customers
UNION
SELECT CONCAT('There are a total of ', COUNT(state), state) AS total
FROM customers
GROUP BY state) AS Cf;

(SELECT CONCAT(name,'(',SUBSTRING(name,1,1),')') AS 'CON'
FROM occupations
ORDER BY CON ASC)
UNION
(SELECT CONCAT('There are a total of ',COUNT(occupation),' ', LOWER(occupation),'s.') AS 'TOTAL'
FROM occupations
GROUP BY occupation
ORDER BY COUNT(occupation) ASC);


SELECT quantity_in_stock*unit_price AS total, COUNT(*)
FROM products
GROUP BY total
ORDER BY total DESC
LIMIT 1;

SELECT ROUND(SUM(unit_price),1), SUM(quantity_in_stock)
FROM products;

SELECT quantity_in_stock
FROM products
WHERE unit_price<1.63
ORDER BY unit_price ASC LIMIT 1;

USE sql_invoicing;

SELECT c.client_id, AVG(i.invoice_total)
FROM invoices i
JOIN clients c
USING (client_id)
GROUP BY c.client_id;
  

SELECT invoice_total
FROM invoices
WHERE invoice_id = (SELECT CEILING((COUNT(invoice_total))/2)+1 FROM invoices);

CREATE OR REPLACE VIEW balance AS
SELECT c.client_id, c.name, SUM(i.invoice_total - i.payment_total)  AS 'balance'
FROM clients c
JOIN invoices i USING (client_id)
GROUP BY c.client_id
WITH CHECK OPTION;


DELIMITER $$
CREATE PROCEDURE get_invoices_with_balance()
BEGIN 
	SELECT *, SUM(invoice_total - payment_total) AS 'balance'
	FROM invoices
	WHERE (invoice_total - payment_total) > 0
	GROUP BY invoice_id;
END$$
DELIMITER ;

USE sql_invoicing;
DELIMITER $$
CREATE PROCEDURE get_invoices_by_client
(
client INT
)
BEGIN 
	SELECT *
	FROM invoices i
	WHERE i.client_id = client;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE get_payments
(
client_id INT,
payment_method_id TINYINT
)
BEGIN 
	SELECT *
	FROM payments p
	WHERE p.client_id = IFNULL(client_id, p.client_id) AND
    p.payment_method = IFNULL(payment_method_id,p.payment_method);
END$$
DELIMITER ;









select con.contest_id,
        con.hacker_id, 
        con.name, 
        sum(total_submissions), 
        sum(total_accepted_submissions), 
        sum(total_views), sum(total_unique_views)
from contests con 
join colleges col on con.contest_id = col.contest_id 
join challenges cha on  col.college_id = cha.college_id 
left join
(select challenge_id, sum(total_views) as total_views, sum(total_unique_views) as total_unique_views
from view_stats group by challenge_id) vs on cha.challenge_id = vs.challenge_id 
left join
(select challenge_id, sum(total_submissions) as total_submissions, sum(total_accepted_submissions) as total_accepted_submissions from submission_stats group by challenge_id) ss on cha.challenge_id = ss.challenge_id
    group by con.contest_id, con.hacker_id, con.name
        having sum(total_submissions)!=0 or 
                sum(total_accepted_submissions)!=0 or
                sum(total_views)!=0 or
                sum(total_unique_views)!=0
            order by contest_id;
            
            
select '*****'