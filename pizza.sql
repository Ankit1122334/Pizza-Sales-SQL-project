use pizza;
create table orders(
          order_id int not null,
          order_date date not null,
          order_time time not null ,
          primary key (order_id ));
          
create table order_details(
          order_details_id int not null,
          order_id int not null,
          pizza_id text not null ,
          quantity int not null,
          primary key (order_details_id ));
          

          
-- Retrieve the total number of orders placed.
select count(order_id) as Total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(quantity * price), 2) AS Total_Pizza_Revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- Identify the highest-priced pizza.

select pizza_id as "Most_Expensive_pizza" from pizzas order by price desc limit 1 ;

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS Max_ordered_Pizza
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(order_details.order_details_id) DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,sum(quantity) as `Max Quantity` 
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id join pizza_types 
    on pizzas.pizza_type_id = pizza_types.pizza_type_id 
    group by pizza_types.name order by `Max Quantity` desc limit 5;
    
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity) AS Total_quantity
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hours, COUNT(order_id) AS Total_order
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY Total_order DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category,sum(quantity) as "Total_Quantity"
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    group by pizza_types.category order by Total_Quantity desc  ;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    order_date, SUM(quantity) AS Total_Pizza_Ordered
FROM
    order_details
        JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY orders.order_date
ORDER BY Total_Pizza_Ordered DESC;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizzas.pizza_type_id, SUM(quantity * price) AS Total_Revenue
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizzas.pizza_type_id
ORDER BY Total_Revenue DESC
LIMIT 0 , 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

set @total_revenue = (SELECT 
    ROUND(SUM(quantity * price), 2) AS Total_Pizza_Sale
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id);
    
SELECT 
    pizzas.pizza_type_id, SUM(quantity * price)*100/@total_revenue AS Total_Revenue
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizzas.pizza_type_id
ORDER BY Total_Revenue Desc;

-- Analyze the cumulative revenue generated over time.

select *,sum(Total_Revenue) over ( order by order_date) as Cumulative_Revenue  from 
(SELECT 
    order_date,round(sum(quantity*price),2) as Total_Revenue
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id group by orders.order_date)t;
    

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select * from 
(select *,dense_rank() over (PARTITION BY category ORDER BY Total_revenue DESC) AS "Rankk" from 
(SELECT 
    category,pizza_types.pizza_type_id,round(sum(quantity*price),2) as "Total_revenue"
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
    group by pizza_types.category,pizza_types.pizza_type_id)t )t1 
    where Rankk<4;
    