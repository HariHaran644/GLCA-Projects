use film_rental;
-- 1. What is the total revenue generated from all rentals in the database? (2 Marks)
select sum(amount) from payment;

-- 2. How many rentals were made in each month_name? (2 Marks)
select count(rental_id),month(rental_date) from rental
group by month(rental_date);

-- 3. What is the rental rate of the film with the longest title in the database? (2 Marks)
select rental_rate,char_length(title)as lenght from film
order by lenght desc
limit 1;

-- 4. What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? (2 Marks)
select avg(rental_rate) from rental r join inventory i using (inventory_id) join film f using (film_id)
where r.rental_date in (select rental_date from Rental where rental_date between "2005-05-05 22:04:30" and (select adddate("2005-05-05 22:04:30" , interval 30 day))
order by rental_date);

-- 5. What is the most popular category of films in terms of the number of rentals? (3 Marks)
select count(r.rental_id)as c_r,c.name from rental r join inventory i using (inventory_id)
join film f using (film_id) join film_category fc using (film_id)
join category c using (category_id) group by c.name order by c_r desc limit 1;
-- 6. Find the longest movie duration from the list of films that have not been rented by any customer. (3 Marks
select f.rental_duration as dur, i.inventory_id, f.film_id, f.title  from film f   left join  inventory  i  using (film_id)
order by dur  desc 
limit 1;

-- 7. What is the average rental rate for films, broken down by category? (3 Marks)
select avg(f.rental_rate) as rr, c.name  as n  from  film f join film_category fc using (film_id) join category c using (category_id)
group by n;

-- 8. What is the total revenue generated from rentals for each actor in the database? (3 Marks)
select  concat(a.first_name, ' ' , a.last_name), a.actor_id,sum(p.amount) from  actor a join film_actor fa using(actor_id) 
join  film f using(film_id) join inventory i using (film_id) join rental r  using (inventory_id) join payment p using(rental_id)
group by a.actor_id;

-- 9. Show all the actresses who worked in a film having a "Wrestler" in the description. (3 Marks)
select concat(a.first_name, ' ' , a.last_name), f.description  from  film f join film_actor fa using(film_id) join actor a using (actor_id)
where f.description like '%Wrestler%';
-- 10. Which customers have rented the same film more than once? (3 Marks)


-- 11. How many films in the comedy category have a rental rate higher than the average rental rate? (3 Marks)
select count(f.title) from category c join film_category fc using (category_id) join film f using (film_id)
where c.name = "Comedy" and f.rental_rate>(select avg(rental_rate) from film); 

-- 12. Which films have been rented the most by customers living in each city? (3 Marks)
select f.title,dense_rank() OVER (ORDER BY count(f.title) DESC) AS Ranking,cu.customer_id,c.city  from customer cu join rental r using (customer_id) join address a using (address_id) join city c using (city_id) join inventory i using (inventory_id) join film f using (film_id)
group by customer_id,city,f.title;

-- 13. What is the total amount spent by customers whose rental payments exceed $200? (3 Marks)
with abc (tot,customer_id) as
(
select sum(amount) as tot ,customer_id from payment
group by customer_id
)
select tot from abc where tot > 200;


-- 14. Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema] (2 Marks)
select * from information_schema.table_constraints
where table_name = 'rental' and table_schema = 'film_rental'
                            and constraint_type = 'FOREIGN KEY';
                            
                            
-- 15. Create a View for the total revenue generated by each staff member, broken down by store city with the country name. (4 Marks)
create view staff_total_revenue as 
select s.staff_id, concat(s.first_name, ' ', s.last_name) as staff_name, c.city, cy.country, sum(p.amount) as total_revenue
from staff s join store st using (store_id)
             join address ad on st.address_id = ad.address_id
             join city c using (city_id)
             join country cy using (country_id)
             join payment p using (staff_id)
group by s.staff_id, s.first_name, s.last_name, c.city, cy.country; 

 
-- 16. Create a view based on rental information consisting of visiting_day, customer_name, the title of the film, no_of_rental_days, the amount paid by the customer along with the percentage of customer spending. (4 Marks)
create view rental_information as
select c.customer_id, rental_date, concat(c.first_name, ' ', c.last_name) as customer_name, title, rental_duration, amount as paid_amount,
((amount/ (select sum(amount) from payment)) *100) as pct
from rental join inventory using (inventory_id)
            join film using (film_id)
            join customer c using (customer_id)
            join payment using (rental_id)
group by c.customer_id, rental_date, title, rental_duration, paid_amount;

 
-- 17. Display the customers who paid 50% of their total rental costs within one day. (5 Marks)
select c.customer_id,f.film_id, (f.rental_rate * f.rental_duration) as rental_cost , p.amount, (p.amount/(f.rental_rate * f.rental_duration))*100 as pct_paid
from film f join inventory i using (film_id)
			join rental r using (inventory_id)
            join customer c using (customer_id)
            join payment p using (rental_id)
where (p.amount/(f.rental_rate * f.rental_duration)) > 0.5 and payment_date < date_add(r.rental_date, interval 1 day) ;

