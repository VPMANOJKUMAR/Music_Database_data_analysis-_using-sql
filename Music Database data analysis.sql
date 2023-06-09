-----+++ Easy Level +++-------
/*Q1: Who is the senior most employee based on job title?*/

selec * from employee
order by levels desc
limit 1;

/*Q2: Which countries have the most invoices?*/

select billing_country, count(billing_country)  from invoice
group by billing_country
order by count(billing_country) desc


--Q3: What are the top 3 values of total invoice

select total  from invoice
order by total desc
limit 3

/*Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals*/

select billing_city,sum(total) from invoice
group by billing_city
order by sum(total) desc


/*Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the msot money. */

select customer.customer_id, customer.first_name,customer.last_name,sum(invoice.total) from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by sum(invoice.total) desc
limit 1



--------+++++ Moderate Level +++++-----------
/*Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A */

---1st way---

select distinct c.email,c.first_name, c.last_name from customer c
join invoice inv
on c.customer_id=inv.customer_id
join invoice_line invl
on inv.invoice_id=invl.invoice_id
join track t
on invl.track_id=t.track_id
join genre g
on t.genre_id=g.genre_id
where g.name = 'Rock'
order by c.email 

---- 2nd way---

select distinct c.email,c.first_name, c.last_name from customer c
join invoice inv
on c.customer_id=inv.customer_id
join invoice_line invl
on invl.invoice_id=inv.invoice_id
where track_id in(
	select track_id from track t
	join genre g
	on t.genre_id=g.genre_id
	where g.name like 'Rock'
)
order by c.email 



/*Q7: Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands */

select art.artist_id, art.name,count(art.artist_id)
from artist art
join album alb
on art.artist_id=alb.artist_id
join track t
on alb.album_id=t.album_id
join genre g
on t.genre_id=g.genre_id
where g.name like 'Rock'
group by art.artist_id
order by count(art.artist_id) desc
limit 10

/*Q8: Return all the track names that have a song length longer than the average song length. return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc



------+++++Advance Level+++++----------
/*Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with bsa as(
	select art.artist_id,art.name,sum(il.unit_price*il.quantity)
	from invoice_line il
	join track t on t.track_id=il.track_id
	join album al on t.album_id=al.album_id
	join artist art on art.artist_id=al.artist_id
	group by art.artist_id
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name,bsa.name, sum(il.unit_price*il.quantity)
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on t.track_id=il.track_id
join album al on al.album_id=t.album_id
join bsa on bsa.artist_id=al.artist_id
group by 1,2,3,4
order by 5 desc

/*Q10: we want to find out most popular music Genre for each country. We determine the most popular genre as the genre as the genre with the highesst amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres. */

with popular_genre as(
	select count(il.quantity) as purchase,c.country,g.name,g.genre_id,
	row_number() over(partition by c.country order by count(il.quantity) desc) as row_no
	from invoice_line il
	join invoice i on il.invoice_id=i.invoice_id
	join customer c on c.customer_id=i.customer_id
	join track t on t.track_id=il.track_id
	join genre g on g.genre_id =t.genre_id
	group by 2,3,4
	order by 2 asc,1 desc
)
select * from popular_genre
where row_no<=1
