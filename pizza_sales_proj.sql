SHOW DATABASES;
use pizzahut;

-- 1 Retrieve the total number of orders placed.

select count(order_id) as total_order from orders;

-- 2 Calculate the total revenue generated from pizza sales.

select 
round(sum(a.quantity * b.price),2) as total_sales
from order_details a join pizzas b
on a.pizza_id=b.pizza_id;

-- 3 Identify the highest-priced pizza.
select 
a.name,b.price
from  pizza_types a join pizzas b
on a.pizza_type_id=b.pizza_type_id
order by b.price desc limit 1;

-- 4 Identify the most common pizza size ordered.
select a.size,count(b.order_details_id) as order_count
from pizzas a join order_details b
on a.pizza_id=b.pizza_id
group by a.size
order by order_count desc;

-- 5 List the top 5 most ordered pizza types along with their quantities.
select a.name,sum(b.quantity) as quantity
from pizza_types a join pizzas c
on a.pizza_type_id=c.pizza_type_id
join order_details b
on b.pizza_id=c.pizza_id
group by a.name
order by quantity desc limit 5;

-- 6 Join the necessary tables to find the total quantity of each pizza category ordered.
select a.category,sum(b.quantity) as quantity
from pizza_types a join pizzas c
on a.pizza_type_id=c.pizza_type_id
join order_details b 
on  b.pizza_id=c.pizza_id
group by a.category
order by quantity desc;

-- 7 Determine the distribution of orders by hour of the day.
select hour(order_time) as hour,count(order_id) as order_count from orders
group by order_time;

-- 8 Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types
group by category;

-- 9 Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as average_pizzas_ordered
from
(select a.order_date,sum(b.quantity) as quantity
from orders a join order_details b
on a.order_id=b.order_id
group by a.order_date) as order_quantity;

-- 10 Determine the top 3 most ordered pizza types based on revenue.
select a.name ,sum(b.quantity*c.price) as revenue
from pizza_types a join pizzas c
on a.pizza_type_id=c.pizza_type_id
join order_details b
on b.pizza_id=c.pizza_id
group by a.name
order by revenue desc limit 3;

-- 11 Calculate the percentage contribution of each pizza type to total revenue.
SELECT a.category,
ROUND(SUM(b.quantity * c.price) / ANY_VALUE(total.total_sales) * 100, 2) AS revenue_percentage
FROM pizza_types a
JOIN pizzas c ON a.pizza_type_id = c.pizza_type_id
JOIN order_details b ON b.pizza_id = c.pizza_id
CROSS JOIN (SELECT SUM(a.quantity * b.price) AS total_sales
    FROM order_details a
    JOIN pizzas b ON a.pizza_id = b.pizza_id) AS total
GROUP BY a.category
ORDER BY revenue_percentage DESC;

-- 12 Analyze the cumulative revenue generated over time.
SELECT 
    sales.order_date,
    SUM(sales.revenue) OVER (ORDER BY sales.order_date) AS cum_revenue
FROM (
    SELECT 
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas 
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders 
        ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS sales;

-- 13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category,name AS pizza_name,revenue
FROM (
    SELECT pt.category,pt.name,SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rnk
    FROM pizza_types pt
    JOIN pizzas p 
        ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od 
        ON p.pizza_id = od.pizza_id
    GROUP BY pt.category, pt.name
) AS ranked
WHERE rnk <= 3
ORDER BY category, revenue DESC;



