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