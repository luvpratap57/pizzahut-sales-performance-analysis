Create Database Pizzahut;
use Pizzahut;

select * from pizzas;

Create Table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id)
) ;
select * from order_details;

-- Basic:
-- 1) Retrieve the total number of orders placed.

 Select count(order_id) as Total_orders from orders;
 
-- 2) Calculate the total revenue generated from pizza sales.

 Select Round(sum((order_details.quantity*pizzas.price)),2) as Total_sales 
 from order_details Join pizzas
 On order_details.pizza_id = pizzas.pizza_id;
 
 
-- 3) Identify the highest-priced pizza.

 select pizza_types.name , pizzas.price 
 from pizza_types join pizzas 
 on pizza_types.pizza_type_id = pizzas.pizza_type_id
 order by pizzas.price Desc Limit 1 ;
 
 
-- Identify the most common pizza size ordered.

 select pizzas.size, Count(order_details.quantity) as Total_quantity from order_details
 join pizzas
 on order_details.pizza_id = pizzas.pizza_id
 Group by pizzas.size
 order by Total_quantity desc limit 1;


-- List the top 5 most ordered pizza types along with their quantities.

 select count(order_details.quantity) as Quantity, pizza_types.name as Pizza_name  from order_details 
 join pizza_types on order_details.pizza_id= pizza_types.pizza_id
group by Pizza_name ;
 


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.

 select  pizza_types.category,sum(order_details.quantity)
 from pizza_types
 join pizzas 
 on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join order_details 
 on pizzas.pizza_id= order_details.pizza_id
 group by pizza_types.category 
 order by sum(order_details.quantity) Desc ;



-- Determine the distribution of orders by hour of the day.

 select hour(order_time), count(order_id) from orders
 group by hour(order_time);
 
-- Join relevant tables to find the category-wise distribution of pizzas.
   -- total types of pizzas in different categories
   
 select category , count(name) from pizza_types
 group by category ;



-- Group the orders by date and calculate the average number of pizzas ordered per day.

select  round(avg( quantity),0) as avg_pizza_per_day from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id= order_details.order_id
group by orders.order_date ) as daily_quantity;

-- NOTE:--
-- SQL treats the subquery like a temporary table.
-- And every table must have a name → that's what daily_qty is here.


-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(pizzas.price*order_details.quantity) as revenue 
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by revenue Desc limit 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category ,  round(sum(order_details.quantity*pizzas.price)/
 (select sum(order_details.quantity*pizzas.price)
 from order_details
 join pizzas
 on order_details.pizza_id= pizzas.pizza_id) *100,2) as revenue_percent
 from pizza_types 
 join pizzas
 on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join order_details
 on pizzas.pizza_id= order_details.pizza_id
 group by pizza_types.category;

-- Analyze the cumulative revenue generated over time.

     select order_date,
     sum(revenue) over(order by order_date ) as cum_revenue
     from
     ( select orders.order_date,
     sum( order_details.quantity*pizzas.price) as revenue
     from order_details join pizzas
     on order_details.pizza_id = pizzas.pizza_id
     join orders 
     on orders.order_id = order_details.order_id
     group by orders.order_date)as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

 use pizzahut;
    select name , revenue from
 (select category , name, revenue,
 rank() over(partition by category order by revenue desc) as rn
 from 
 (select pizza_types.category, pizza_types.name,
 sum((order_details.quantity)*pizzas.price) as revenue
 from pizza_types join pizzas
 on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join order_details
 on order_details.pizza_id =pizzas.pizza_id
 group by pizza_types.category, pizza_types.name) as a) as b
 where rn<=3;    
