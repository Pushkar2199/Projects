
/* Q1: Who is the senior most employee based on job title? */

select first_name, last_name, title from employee order by levels desc limit 1 ;

/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC ;



/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC limit 3;



/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */


select billing_city , sum(total) as invoice_total from invoice group by billing_city order by invoice_total desc limit 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/


SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
inner join invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, first_name, last_name
ORDER BY total_spending DESC  limit 1;



/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
ORDER BY email;



/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.name ,count(*)  as track_count, genre.name as genre  from artist 
join  album  on album.artist_id = artist.artist_id
join track ON album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name = "Rock"  group by  artist.name order by track_count desc  limit 10;

/* Q9: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds as length from track
 where milliseconds > (select avg(milliseconds) from track)
 order by length desc;
 


/* Question Set 3 - Advance */

/* Q 10 : Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with top_artist as (
select artist.artist_id as artist_id , artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as total from artist
join album on artist.artist_id  = album.artist_id
join track on track.album_id = album.album_id
join invoice_line on track.track_id = invoice_line.track_id
group by artist.artist_id,artist.name 
order by total desc 
limit 1
) 
select customer.first_name , customer.last_name , top_artist.artist_name ,sum(invoice_line.quantity * invoice_line.unit_price) as amount_spent  from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id 
join track on invoice_line.track_id = invoice_line.track_id
join album on track.album_id = album.album_id 
join top_artist on album.artist_id = top_artist.artist_id
group by customer.first_name , customer.last_name , top_artist.artist_name
order by amount_spent desc;




/* Q 11: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

select country_name, genre_name, total_purchase from (
    select customer.country as country_name, genre.name as genre_name, count(invoice_line.quantity) as total_purchase,
    rank() over (partition by customer.country order by  count(invoice_line.quantity) desc ) as genre_rank
    from  customer
    join invoice on invoice.customer_id = customer.customer_id
    join invoice_line on invoice.invoice_id = invoice_line.invoice_id
    join track on invoice_line.track_id = track.track_id
    join genre on track.genre_id = genre.genre_id
    group by country_name, genre_name
) as sub_query
where genre_rank = 1
order by country_name;


/* Q 12: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. */

select country_name ,first_name ,last_name ,amount_spent from (
 select customer.country as country_name, customer.first_name as first_name, customer.last_name as last_name ,  sum(invoice_line.quantity*invoice_line.unit_price) as amount_spent,
 rank() over (partition by customer.country order by  sum(invoice_line.quantity * invoice_line.unit_price)  desc ) as amount_rank
from customer
join invoice on customer.customer_id = invoice.customer_id 
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
group by customer.first_name , customer.last_name , customer.country ) as sub_query
where amount_rank = 1
order by country_name; 




 