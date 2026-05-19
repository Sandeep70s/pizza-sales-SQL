CREATE TABLE Pizzas(
pizza_id VARCHAR(50) PRIMARY KEY,
pizza_type_id VARCHAR(50),
size VARCHAR(50),
price NUMERIC (10,2)
);

COPY  Pizzas(pizza_id, pizza_type_id, size, price)
FROM 'D:\SQL\pizza_sales\pizzas.csv'
CSV HEADER;



CREATE TABLE Pizza_Types(
pizza_type_id VARCHAR(50) PRIMARY KEY,
name VARCHAR(100),
category VARCHAR(100),
ingredients VARCHAR(100)
);
DROP TABLE Pizza_Types;

COPY Pizza_Types(pizza_type_id, name, category, ingredients)
FROM 'D:\SQL\pizza_sales\pizza_types.csv'
WITH CSV HEADER
ENCODING 'WIN1252';

CREATE TABLE Orders(
order_id SERIAL PRIMARY KEY,
date DATE,
time TIME
);
DROP TABLE Ordes;


COPY Orders(order_id, date, time)
FROM 'D:\SQL\pizza_sales\orders.csv'
CSV HEADER;

CREATE TABLE Order_Datails(
order_details_id SERIAL PRIMARY KEY,
order_id INT ,
pizza_id VARCHAR(50),
quantity INT
);

COPY Order_Datails(order_details_id, order_id, pizza_id, quantity )
FROM 'D:\SQL\pizza_sales\order_details.csv'
CSV HEADER;





   --**QUESTION**--
--Retrieve the total number of orders placed.
SELECT COUNT(Order_id) AS Toatal_Order 
FROM Orders;

--Calculate the total revenue generated from pizza sales.
SELECT 
SUM(Order_Datails.quantity * Pizzas.price) AS TOTAL 
FROM Pizzas JOIN Order_Datails
ON Pizzas.Pizza_id = Order_Datails.Pizza_id;

--Identify the highest-priced pizza.
SELECT Pizza_Types.name, Pizzas.price
FROM Pizza_Types JOIN Pizzas
ON Pizza_Types.Pizza_Type_Id= Pizzas.Pizza_Type_Id
ORDER BY Price  DESC LIMIT 1;

--Identify the most common pizza size ordered.
SELECT Pizzas.size, COUNT(Order_Datails.Order_Details_id) AS Order_Count
FROM Order_Datails JOIN Pizzas
ON Pizzas.Pizza_id=Order_Datails.Pizza_id 
GROUP  BY Pizzas.size ORDER BY Order_Count DESC ;

--List the top 5 most ordered pizza types along with their quantities.
SELECT Pizza_Types.name, SUM(Order_Datails.Quantity) AS Quantity
FROM Pizza_types JOIN Pizzas
ON Pizza_types.Pizza_type_id= Pizzas.Pizza_type_id
JOIN Order_Datails
On order_datails.Pizza_id= Pizzas.Pizza_id
GROUP BY Pizza_Types.name ORDER BY quantity DESC LIMIT 5;



      --**Intermidiate**--
--Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT Pizza_Types.category, SUM(Order_Datails.Quantity) AS Quantity
FROM Pizza_types JOIN Pizzas
ON Pizza_types.Pizza_type_id= Pizzas.Pizza_type_id
JOIN Order_Datails
On order_datails.Pizza_id= Pizzas.Pizza_id
GROUP BY Pizza_Types.category ORDER BY quantity DESC;

--Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM time) AS Hour, COUNT(Order_id) AS order_count
FROM Orders GROUP BY EXTRACT(HOUR FROM time)
ORDER BY order_count DESC;


--Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT (name) FROM Pizza_Types
GROUP BY category;


--Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT AVG(quantity) FROM 
(SELECT orders.Date, SUM (Order_Datails.quantity) AS Quantity
FROM orders JOIN Order_Datails
ON Orders.Order_id= Order_Datails.Order_Id
GROUP BY orders.Date);


--Determine the top 3 most ordered pizza types based on revenue.
SELECT Pizza_Types.name,
SUM (Order_Datails.quantity*Pizzas.price) AS REVENUE
FROM Pizza_types JOIN Pizzas
ON Pizzas.Pizza_Type_ID= Pizza_types.Pizza_Type_ID
JOIN Order_Datails
ON Order_Datails.Pizza_id=Pizzas.pizza_ID
GROUP BY Pizza_types.name ORDER BY REVENUE DESC LIMIT 3;



      --**Advanced**--
--calculate the percentage contribution of each pizza type to total revenue.
SELECT Pizza_Types.category,
ROUND(SUM (Order_Datails.quantity*Pizzas.price) /(SELECT(SUM(Order_Datails.Quantity*pizzas.price))
FROM Order_Datails JOIN Pizzas
ON Pizzas.pizza_id=order_datails.pizza_id)*100,2) AS Revenue
FROM Pizza_types JOIN Pizzas
ON Pizzas.Pizza_Type_ID = Pizza_types.Pizza_Type_ID
JOIN Order_Datails
ON Order_Datails.Pizza_id=Pizzas.pizza_ID
GROUP BY Pizza_types.category ORDER BY Revenue DESC ;

--Analyze the cumulative revenue generated over time
SELECT date,
SUM(revenue) Over(order by date) AS CUM_revenue
From
(Select orders.date,
SUM(order_datails.quantity*pizzas.price) AS revenue
From order_datails Join pizzas
on order_datails.pizza_id=pizzas.pizza_id
Join orders
On orders.order_id=order_datails.order_id
Group By orders.date) AS Sales;

--Determine the Top 3 most ordered pizza types based on revenue for each pizza category.
Select name, revenue
from
(
    select category, name, revenue,
           rank() over(partition by category order by revenue desc) as rn
    from
    (
        Select pizza_types.category, pizza_types.name,
               SUM(order_datails.quantity * pizzas.price) as revenue
        from pizza_types
        join pizzas
            on pizza_types.pizza_type_id = pizzas.pizza_type_id
        join order_datails
            on order_datails.pizza_id = pizzas.pizza_id
        group by pizza_types.category, pizza_types.name
    ) as a
) as b
where rn <= 3;


SELECT* FROM Orders;
SELECT * FROM Pizzas;
SELECT * FROM Pizza_Types;