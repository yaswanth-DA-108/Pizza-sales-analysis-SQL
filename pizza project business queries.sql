create database pizza_project;
use pizza_project;

 describe orders;
 
 select * from orders ;
 
 select * from orders where
 (order_id is null or order_id='') or
( order_date is null or order_date='') or
(order_time  is null or order_time='');
 
 
 alter table orders
 modify order_date date;
 
 alter table orders
 modify order_time time;
 
 with copie as(
 select *,row_number() over(partition by order_id,order_date,order_time) as ranks
 from orders
 )
 select * from copie where ranks>1;
 
describe order_details;
 
 select * from 
 order_details where
( order_details_id is null or order_details_id='')or
(order_id is null or order_id='')or
( pizza_id is null or pizza_id='')or
 (quantity is null or quantity='');
 
 with copies as(
 select *,row_number() over(partition by order_details_id,order_id,pizza_id,quantity) ranks
 from order_details
 )
 select * from copies 
 where ranks>1;
 
 describe pizzas;
 
 select * from 
 pizzas where
 (pizza_id is null or pizza_id='')or
 (pizza_type_id is null or pizza_type_id='')or
 (size is null or size='')or
 (price is null or price='' );
 
 with copies as(
 select *,row_number() over(partition by pizza_id,pizza_type_id,size,price) ranks
 from pizzas
 )
 select *from copies 
 where ranks>1;
 
 describe pizza_types;
 
 select * from pizza_types
 where (pizza_type_id is null or pizza_type_id='') or
	   (`name` is null or `name`='')or
       (category is null or category='')or
       (ingredients is null or ingredients='');
       
with copies as(
select *,row_number() over(partition by pizza_type_id,`name`,category,ingredients) ranks
from pizza_types
)
select * from copies 
where ranks>1;
 
 # Answering business questions
 
-- 1.Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) toatl_orders
FROM
    orders;


-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(price * quantity), 2) AS revenue
FROM
    pizzas
        JOIN
    order_details USING (pizza_id);


-- 3.Identify the highest-priced pizza

SELECT 
    `name` highest_priced_pizza, price
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
WHERE
    price = (SELECT 
            MAX(price)
        FROM
            pizzas);


-- 4.Identify the most common pizza size ordered.

SELECT 
size, COUNT(pizza_id) num_orders
FROM
    pizzas
        JOIN
    order_details USING (pizza_id)
GROUP BY size
ORDER BY COUNT(pizza_id) DESC
LIMIT 1;


-- 5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    `name`, SUM(quantity) quantity
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY `name`
ORDER BY quantity DESC
LIMIT 5;


-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity) quantity
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY category
ORDER BY 2 DESC;


-- 7.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) hour_, COUNT(order_id) AS num_orders
FROM
    orders
GROUP BY 1;


-- 8.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(`name`) count_
FROM
    pizza_types
GROUP BY 1
ORDER BY 2 DESC;


-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(sum_o), 0) avg_orders_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) sum_o
    FROM
        orders
    JOIN order_details USING (order_id)
    GROUP BY 1
    ORDER BY 1) AS aveg;
    
    
    -- 10.Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    `name`, ROUND(SUM(quantity * price), 0) revenue
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY `name`
ORDER BY 2 DESC
LIMIT 3;


-- 11.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    `name`,
    (SUM(quantity * price) / (SELECT 
            SUM(quantity * price)
        FROM
            order_details
                JOIN
            pizzas USING (pizza_id)
                JOIN
            pizza_types USING (pizza_type_id))) * 100 AS percentage
FROM
    order_details
        JOIN
    pizzas USING (pizza_id)
        JOIN
    pizza_types USING (pizza_type_id)
GROUP BY `name`;


-- 12.Analyze the cumulative revenue generated over time.

select order_date,sum(revenue) over(order by order_date) as c_rev
from(
select order_date,round(sum(quantity*price),0) revenue
from orders join order_details using(order_id)
			join pizzas using(pizza_id)
		group by order_date
	) as sum;
    
    
-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category

with cte as (
select category,`name`,sum(quantity*price) as revenue,
row_number() over(partition by category order by sum(quantity*price)) as ranks
from
order_details
JOIN pizzas USING (pizza_id)
JOIN pizza_types USING (pizza_type_id)
group by category,`name`
)
select category,`name`,round(revenue,0) revenue
from cte 
where ranks<=3
;
    
  
              












