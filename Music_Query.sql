-- SELECT * FROM TRACK;
-- SELECT * FROM INVOICE_LINE;
-- SELECT * FROM CUSTOMER;
-- SELECT * FROM EMPLOYEE;
-- SELECT * FROM GENRE;

-- SET 1
-- Q1 Who is the senior-most employee based on job title?
SELECT employee_id, first_name, last_name ,title
FROM employee
where reports_to is null;
-- ANSWER: Mohan Madan

-- Q2 Which countries have the most Invoices?
SELECT BILLING_COUNTRY, COUNT(INVOICE_ID) FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY COUNT(INVOICE_ID) DESC;
-- ANSWER: USA

-- Q3 What are top 3 values of total invoice?
SELECT TOTAL FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3;
-- ANSWER: 23.759999999999998, 19.8, 19.8\

/* Q4 Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals */
SELECT BILLING_CITY, SUM(TOTAL) FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY SUM(TOTAL) DESC
LIMIT 1;
-- ANSWER: Prague

/* Q5 Who is the best customer?  Write a query that returns the person who has spent the
most money */
SELECT first_name, last_name, SUM(TOTAL) as Total
FROM invoice
RIGHT JOIN customer
ON invoice.customer_id = customer.customer_id
GROUP BY first_name, last_name                                                                                                                                                                              
ORDER BY Total DESC
limit 1;
-- ANSWER: R Madhav

-- SET 2
/* Q1 Write a query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email, starting with A*/
SELECT first_name, last_name, email
from customer c
right join 
(
	INVOICE i
	RIGHT JOIN 
		(INVOICE_LINE il
		RIGHT JOIN TRACK t
		ON il.track_id = t.track_id
		)
	ON i.INVOICE_ID = il.INVOICE_ID
) 
on c.customer_id = i.customer_id
WHERE genre_id = '1' AND email IS NOT NULL
group by first_name, last_name, email
order by email asc;

/* Q2 Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands*/
SELECT a.name, COUNT(t.track_id) as Track_no
from 
artist a
right join
album b ON a.artist_id = b.artist_id
right join 
track t ON b.album_id =t.album_id
where genre_id = '1'
group by a.name
order by Track_no desc
limit 10;

/* Q3 Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */
SELECT t.name, milliseconds
from track t
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
GROUP BY t.name, milliseconds
ORDER BY milliseconds desc;

-- SET 3 
/* Q1 Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */
SELECT CONCAT(c.first_name, c.last_name) AS CUST_NAME, ar.name, sum(i.total) as Tot_spent
from customer c 
right join
invoice i ON c.customer_id = i.customer_id
right join 
invoice_line il on i.invoice_id = il.invoice_id
right join 
track t on il.track_id = t.track_id
right join
album al on t.album_id = al.album_id
right join 
artist ar on al.artist_id = ar.artist_id
WHERE c.last_name IS NOT NULL
group by CUST_NAME, c.last_name, ar.name
ORDER BY c.last_name asc, tot_spent desc;

/* Q2 We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres */

--ANSWER
WITH popular_genre AS
(
	SELECT c.country, g.name, COUNT(il.quantity) AS purchases,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo
	FROM invoice_line il
	JOIN invoice i ON i.invoice_id = il.invoice_id
	JOIN customer c ON c.customer_id = i.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN genre g ON t.genre_id = g.genre_id
	GROUP BY 1,2
	ORDER BY 3 DESC, 1 ASC 
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

/* Q3 Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount */
SELECT i.billing_country, c.first_name, c.last_name, il.unit_price * COUNT(il.invoice_id) AS tot_spent
FROM customer c
JOIN invoice i ON  c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY i.billing_country, c.first_name, c.last_name, il.unit_price
ORDER BY i.billing_country ASC, tot_spent DESC;

WITH Customer_And_Country AS
(
	SELECT i.billing_country, c.customer_id, c.first_name, c.last_name, SUM(total) AS Tot_Spending,
	ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY SUM(i.total) DESC) AS RowNo
	FROM customer c
	JOIN invoice i ON  c.customer_id = i.customer_id
	GROUP BY 1, 2, 3, 4
	ORDER BY 4 ASC, 5 DESC 
)
SELECT * FROM Customer_And_Country WHERE RowNo <= 1;
