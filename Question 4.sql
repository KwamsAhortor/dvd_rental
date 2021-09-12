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