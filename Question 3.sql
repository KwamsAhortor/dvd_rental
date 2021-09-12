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