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