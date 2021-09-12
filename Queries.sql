/* Query 1 - What movies are famillies watching? */
SELECT DISTINCT category_name,
				rental_count
FROM (
	SELECT f.title AS film_title,
			c.name AS category_name,
			COUNT(r.*) OVER (PARTITION BY c.name) AS rental_count
	FROM rental r
	JOIN inventory i
	ON r.inventory_id = i.inventory_id
	JOIN film f
	ON i.film_id = f.film_id
	JOIN film_category fc
	ON f.film_id = fc.film_id
	JOIN category c
	ON fc.category_id = c.category_id
	WHERE c.name IN ('Animation', 'Children', 'Comedy', 'Family', 'Music')
	ORDER BY 2,1
) AS sub


/* Query 2 - How long are customers keeping family movies? */
WITH category_duration_quartile AS (
	SELECT category_name,
			duration_days,
			NTILE (4) OVER (ORDER BY duration_days) AS standard_quartile
	FROM (
		SELECT f.title AS film_title,
				c.name AS category_name,
				CAST(EXTRACT(epoch FROM r.return_date - r.rental_date)/86400 AS INT) AS duration_days
		FROM rental r
		JOIN inventory i
		ON r.inventory_id = i.inventory_id
		JOIN film f
		ON i.film_id = f.film_id
		JOIN film_category fc
		ON f.film_id = fc.film_id
		JOIN category c
		ON fc.category_id = c.category_id
		WHERE c.name IN ('Animation', 'Children', 'Comedy', 'Family', 'Music')
	) sub
)

SELECT category_name,
		rental_duration,
		COUNT(rental_duration)
FROM (
	SELECT category_name,
		CASE WHEN standard_quartile = 4 THEN 'Over a week'
			WHEN standard_quartile = 3 THEN 'Over 6 days'
			WHEN standard_quartile = 2 THEN 'Over 4 days'
			WHEN standard_quartile = 1 THEN 'Below 3 days' END AS rental_duration
	FROM category_duration_quartile
	)sub
GROUP BY 1, 2


/* Query 3 - How are stores performing? */
WITH store_date AS (
	SELECT s.store_id,
			DATE_PART('month', rental_date) AS rental_month,
			DATE_PART('year', rental_date) AS rental_year,
			COUNT (rental_date) count_rentals	
	FROM store s
	JOIN staff sf
	ON s.store_id = sf.store_id
	JOIN rental r
	ON sf.staff_id = r.staff_id
	GROUP BY 2, 1, 3
) 

SELECT store_id,
		rental_month,
		count_rentals
FROM store_date
WHERE rental_year = 2005


/* Query 4 - How is customer performance */
WITH customer_revenue AS (
	SELECT customer_name,
			SUM(amount) AS payment
	FROM (
		SELECT c.customer_id,
				c.first_name || ' ' || c.last_name AS customer_name,
				p.amount AS amount
		FROM customer c
		JOIN rental r
		ON c.customer_id = r.customer_id
		JOIN payment p
		ON r.rental_id = p.rental_id
	) sub
	GROUP BY 1
)
SELECT CASE WHEN quartile = 5 THEN 'Platinum Customers'
			WHEN quartile = 4 THEN 'Diamond Customers'
			WHEN quartile = 3 THEN 'Gold Customers'
			WHEN quartile = 2 THEN 'Silver Customers'
			WHEN quartile = 1 THEN 'Bronze Customers' END AS customer_rank,
		COUNT(quartile) AS rank_count,
		SUM (payment) AS total_revenue
FROM (
	SELECT *,
			NTILE(5) OVER (ORDER BY payment) AS quartile
	FROM customer_revenue
) sub
GROUP BY 1
ORDER BY 3