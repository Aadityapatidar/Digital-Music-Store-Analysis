-- Q1 : who is the senior most employee based on job title.

select employee_id, concat(first_name, last_name)as full_name, title
from employee
order by levels desc
limit 1;

-- Q2 : which countries have the most invoices.

select count(*)as total_count, billing_country
from invoice
group by billing_country
order by total_count desc;

-- Q3 : what are top 3 values of total invoice.

select*
from invoice
order by total desc
limit 3;

-- Q4 : who is the best customer. the customer who has spend the most money will be declared the best customer.
--      write the query that returns the person who has spend the most money

select c.customer_id,concat(first_name,'', last_name)as full_name, sum(i.total)as total
from customer as c join invoice as i
on c.customer_id = i.customer_id
group by c.customer_id
order by total desc
limit 1;	 

-- Q5 : write query to return the email, firstname, lastname, & genere of all rock music listeners.
--     return your list ordered alphabetically by email starting with A.

SELECT DISTINCT c.email,CONCAT(c.first_name, ' ', c.last_name) AS full_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE il.track_id IN (SELECT t.track_id FROM track t JOIN genre g 
    ON t.genre_id = g.genre_id
    WHERE g.name = 'Rock')
ORDER BY c.email;

-- Q6 : lets invite the artists who have written the most rock music in our dataset.
--     write a query that returns the artist name and total track count of the top 10 rock bands.

SELECT ar.artist_id, ar.name AS artist_name,
    COUNT(t.track_id) AS number_of_songs
FROM track t JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY number_of_songs DESC
LIMIT 10;

-- Q7 : return all the track names that have a song length langer than the average song length.
--      return the name and milliseconds for each track. order by the song length with the 
-- 	 longest songs listed first.

select name, milliseconds
from track
where milliseconds >(
     select avg(milliseconds)as avg_track_length
	 from track)
order by milliseconds desc;	

-- Q8 : find how much amount spent by each customer on artists. write a query to return customer name,
--      artist name and total spent.
	 
WITH best_selling_artist AS (
 SELECT  ar.artist_id,ar.name AS artist_name,
 SUM(il.unit_price * il.quantity) AS total_sales
 FROM invoice_line il JOIN track t ON il.track_id = t.track_id
 JOIN album a ON t.album_id = a.album_id
 JOIN artist ar ON a.artist_id = ar.artist_id
 GROUP BY ar.artist_id, ar.name
 ORDER BY total_sales DESC
 LIMIT 1)
SELECT c.customer_id, c.first_name,c.last_name,bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i JOIN customer c ON i.customer_id = c.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN best_selling_artist bsa ON a.artist_id = bsa.artist_id
GROUP BY c.customer_id, c.first_name,c.last_name,bsa.artist_name
ORDER BY amount_spent DESC;

-- Q9 : we wont to find out the most popular music genre for each country.
--      we determine the most popular genre as the genre with the highest amount of purchases.

with popular_genre as(
select count(il.quantity)as purchases, c.country, g.name, g.genre_id,
row_number()over(partition by c.country order by count(il.quantity)desc)as rowno
from invoice_line as il join invoice as i
on il.invoice_id = i.invoice_id
join customer as c on i.customer_id = c.customer_id
join track as t on il.track_id = t.track_id
join genre as g on t.genre_id = g.genre_id
group by c.country, g.genre_id, g.name
order by c.country asc ,purchases desc)
select*
from popular_genre
where rowno <=1;

-- Q10 : write a query that determines the customer that has spent the most on music for each country.
--       write a query that returns the country  alang with the top customer and how much they spent.
-- 	  for countries where the top amount spent is shared, provide all customers who spent this amount.

with customer_with_country as (
    select c.customer_id, first_name, last_name, billing_country, sum(total)as total_spending,
	row_number()over(partition by billing_country order by sum(total)desc)as rowno
	from invoice as i join customer as c
	on i.customer_id = c.customer_id
	group by c.customer_id, first_name, last_name, billing_country
	order by billing_country asc, total_spending desc)
select*
from customer_with_country
where rowno <=1 ;
