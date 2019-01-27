USE sakila;

-- Describe 'actor' table
DESCRIBE actor;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT 
    first_name, last_name
FROM
    actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Actor Name'
FROM
    actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'
ORDER BY last_name , first_name;

-- Describe 'country' table
DESCRIBE country;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column
-- in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference
-- between it and `VARCHAR` are significant).
DESCRIBE actor;
ALTER TABLE actor ADD COLUMN description BLOB;
DESCRIBE actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;
DESCRIBE actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(1) AS number_of_actors
FROM
    actor
GROUP BY last_name
ORDER BY number_of_actors;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
    last_name, COUNT(1) AS number_of_actors
FROM
    actor
GROUP BY last_name
HAVING number_of_actors > 1
ORDER BY number_of_actors;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    first_name = 'HARPO'
        AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all!
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    first_name = 'HARPO'
        AND last_name = 'WILLIAMS';
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
--  * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
CREATE TABLE IF NOT EXISTS address (
    address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50) DEFAULT NULL,
    district VARCHAR(20) NOT NULL,
    city_id SMALLINT UNSIGNED NOT NULL,
    postal_code VARCHAR(10) DEFAULT NULL,
    phone VARCHAR(20) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (address_id),
    KEY idx_fk_city_id (city_id),
    CONSTRAINT `fk_address_city` FOREIGN KEY (city_id)
        REFERENCES city (city_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT 
    s.first_name, s.last_name, a.address
FROM
    staff s
        INNER JOIN
    address a ON s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT 
    s.first_name, s.last_name, SUM(amount)
FROM
    payment p
        INNER JOIN
    staff s ON p.staff_id = s.staff_id
WHERE
    p.payment_date LIKE '2005-08%'
GROUP BY s.first_name , s.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT 
    f.title, COUNT(fa.actor_id) AS num_actors
FROM
    film f
        INNER JOIN
    film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT 
    COUNT(1)
FROM
    inventory i
        INNER JOIN
    film f ON i.film_id = f.film_id
        AND f.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT 
    c.first_name,
    c.last_name,
    c.email,
    SUM(p.amount) AS total_paid
FROM
    payment p
        INNER JOIN
    customer c ON p.customer_id = c.customer_id
GROUP BY c.first_name , c.last_name , c.email;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with
-- the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the
-- letters `K` and `Q` whose language is English.
SELECT 
    f.title
FROM
    film f
WHERE
    f.language_id = (SELECT 
            language_id
        FROM
            language
        WHERE
            name = 'English')
        AND f.title LIKE 'K%'
        OR f.title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian
-- customers. Use joins to retrieve this information.
SELECT 
    cu.first_name, cu.last_name, cu.email
FROM
    customer cu
        INNER JOIN
    address ad ON cu.address_id = ad.address_id
        INNER JOIN
    city ci ON ci.city_id = ad.city_id
        INNER JOIN
    country ON ci.country_id = ci.country_id
        AND country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies
-- categorized as _family_ films.
SELECT 
    f.title
FROM
    film f
        INNER JOIN
    film_category fc ON f.film_id = fc.film_id
        INNER JOIN
    category c ON fc.category_id = c.category_id
        AND c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT 
    f.title, COUNT(1) AS num_rentals
FROM
    rental r
        INNER JOIN
    inventory i ON r.inventory_id = i.inventory_id
        INNER JOIN
    film f ON f.film_id = i.film_id
GROUP BY f.title
ORDER BY num_rentals DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
    a.address, SUM(p.amount) AS total_business
FROM
    payment p
        INNER JOIN
    rental r ON p.rental_id = r.rental_id
        INNER JOIN
    inventory i ON i.inventory_id = r.inventory_id
        INNER JOIN
    store s ON s.store_id = i.store_id
        INNER JOIN
    address a ON a.address_id = s.address_id
GROUP BY a.address
ORDER BY total_business DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT 
    s.store_id, ci.city, co.country
FROM
    store s
        INNER JOIN
    address a ON a.address_id = s.address_id
        INNER JOIN
    city ci ON ci.city_id = a.city_id
        INNER JOIN
    country co ON ci.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category,
-- film_category, inventory, payment, and rental.)

SELECT 
    c.name AS genre, SUM(p.amount) gross_revenue
FROM
    category c
        INNER JOIN
    film_category fc ON fc.category_id = c.category_id
        INNER JOIN
    inventory i ON i.film_id = fc.film_id
        INNER JOIN
    rental r ON r.inventory_id = i.inventory_id
        INNER JOIN
    payment p ON p.rental_id = r.rental_id
GROUP BY genre
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
    SELECT 
        c.name AS genre, SUM(p.amount) gross_revenue
    FROM
        category c
            INNER JOIN
        film_category fc ON fc.category_id = c.category_id
            INNER JOIN
        inventory i ON i.film_id = fc.film_id
            INNER JOIN
        rental r ON r.inventory_id = i.inventory_id
            INNER JOIN
        payment p ON p.rental_id = r.rental_id
    GROUP BY genre
    ORDER BY gross_revenue DESC
    LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
SELECT 
    *
FROM
    top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;
