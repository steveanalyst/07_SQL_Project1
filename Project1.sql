# This is needed for all below sections.
USE sakila


#1a Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM sakila.actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) as "Actor Name"
FROM sakila.actor;

#2a. You need to find the ID number, first name, and last name of an actor, 
#of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM sakila.actor
WHERE first_name="Joe"

#2b. Find all actors whose last name contain the letters GEN
SELECT first_name, last_name
FROM sakila.actor
WHERE last_name LIKE "%GEN%"

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM sakila.actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name ASC;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM sakila.country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
#so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
#as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*)
FROM sakila.actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*)
FROM sakila.actor
GROUP BY last_name
HAVING  COUNT(*)>=2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT first_name, last_name
FROM sakila.actor
WHERE first_name='GROUCHO' and last_name='WILLIAMS';

UPDATE actor
SET first_name='HARPO', last_name='WILLIAMS'
WHERE first_name='GROUCHO' and last_name='WILLIAMS';

/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
UPDATE actor 
SET first_name='GROUCHO'
WHERE first_name='HARPO';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

/* Below is information returned in the result
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
*/

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
FROM staff AS s
INNER JOIN address AS a ON s.address_id=a.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount) AS total_payment
FROM staff AS s
JOIN payment AS p ON s.staff_id=p.staff_id
GROUP BY s.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(actor_id) AS total_actors
FROM film_actor AS a
INNER JOIN film AS f ON f.film_id=a.film_id
GROUP BY f.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
# Sub query method:
SELECT COUNT(i.film_id)
FROM inventory AS i
WHERE i.film_id IN (SELECT film_id
								  FROM film AS f
								  WHERE f.title='Hunchback Impossible');

#Table Join Method:
SELECT f.title, COUNT(i.inventory_id)
FROM film f
INNER JOIN inventory i 
ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";

#Table Join simpler version:
SELECT title, COUNT(inventory_id)
FROM film f
INNER JOIN inventory i 
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
SELECT first_name, last_name, SUM(amount)
FROM customer AS c
INNER JOIN payment AS p
WHERE p.customer_id=c.customer_id
GROUP BY c.customer_id
ORDER BY last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies 
starting with the letters K and Q whose language is English.*/
SELECT title
FROM film f
WHERE title LIKE 'K%' OR title LIKE 'Q%'
AND language_id IN ( SELECT language_id
											FROM language
                                            WHERE name='English');

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (SELECT actor_id
									FROM film_actor
                                    WHERE film_id IN (SELECT film_id
																	FROM film
                                                                    WHERE title ='Alone Trip'));
                                                                    
/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
email addresses of all Canadian customers. Use joins to retrieve this information.*/
SELECT country, first_name, last_name, email
FROM customer c
INNER JOIN address a ON a.address_id=c.address_id
INNER JOIN city ci ON ci.city_id=a.city_id
INNER JOIN country co ON co.country_id=ci.country_id
WHERE country='Canada';


/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.*/
SELECT name, title
FROM film f
JOIN film_category fc ON fc.film_id=f.film_id
JOIN category c ON c.category_id=fc.category_id
WHERE name ='Family';

#7e. Display the most frequently rented movies in descending order.
SELECT title, count(rental_id) AS 'rented time'
FROM film f
JOIN inventory i ON i.film_id=f.film_id
JOIN rental r ON r.inventory_id=i.inventory_id
GROUP BY title
ORDER BY count(rental_id) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, sum(amount) AS revenue
FROM payment p
JOIN staff s ON s.staff_id=p.staff_id
JOIN store st ON st.store_id=s.store_id
GROUP BY st.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store s 
JOIN address a ON s.address_id= a.address_id
JOIN city c ON c.city_id=a.city_id
JOIN country co ON co.country_id=c.country_id;

/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
category, film_category, inventory, payment, and rental.)*/
SELECT c.name, SUM(p.amount) AS 'gross_revenue'
FROM payment as p
JOIN rental r ON p.rental_id=r.rental_id
JOIN inventory i ON r.inventory_id=i.inventory_id
JOIN film_category f ON i.film_id=f.film_id
JOIN category c ON c.category_id=f.category_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC LIMIT 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
CREATE VIEW Top_Five_Genres_By_Gross_Revenue AS
SELECT c.name, SUM(p.amount) AS 'gross_revenue'
FROM payment AS p
JOIN rental r ON p.rental_id=r.rental_id
JOIN inventory i ON r.inventory_id=i.inventory_id
JOIN film_category f ON i.film_id=f.film_id
JOIN category c ON c.category_id=f.category_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * 
FROM Top_Five_Genres_By_Gross_Revenue;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Five_Genres_By_Gross_Revenue;



