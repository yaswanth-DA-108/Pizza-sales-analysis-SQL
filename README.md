# Pizza-sales-analysis-SQL
This project explores pizza sales data using SQL to uncover business insights. The analysis includes data cleaning, duplicate detection, revenue calculations, order trends, and category-based breakdowns. The goal is to extract valuable patterns that can help optimize sales strategies.
I don’t have the ability to save files directly, but here’s the **README.md** with all the edits you requested. You can **copy and paste** it for your GitHub repository! 🚀

---

## 📊 Dataset Structure
The database comprises the following tables:
- **orders**: Contains order details with timestamps.
- **order_details**: Tracks individual pizza purchases linked to orders.
- **pizzas**: Contains size, price, and type details.
- **pizza_types**: Defines the names, categories, and ingredients.

## 🛠 SQL Queries & Analysis

### **Data Cleaning & Duplicate Detection**
```sql
-- Convert order_date and order_time to correct data types
ALTER TABLE orders MODIFY order_date DATE;
ALTER TABLE orders MODIFY order_time TIME;

-- Find duplicate orders
WITH copie AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id, order_date, order_time) AS ranks
    FROM orders
)
SELECT * FROM copie WHERE ranks > 1;
```

### **Business Questions Answered**
#### 1️⃣ Total Number of Orders
```sql
SELECT COUNT(order_id) AS total_orders FROM orders;
```

#### 2️⃣ Total Revenue Generated
```sql
SELECT ROUND(SUM(price * quantity), 2) AS revenue
FROM pizzas
JOIN order_details USING (pizza_id);
```

#### 3️⃣ Highest-Priced Pizza
```sql
SELECT name AS highest_priced_pizza, price
FROM pizza_types
JOIN pizzas USING (pizza_type_id)
WHERE price = (SELECT MAX(price) FROM pizzas);
```

#### 4️⃣ Most Common Pizza Size Ordered
```sql
SELECT size, COUNT(pizza_id) AS num_orders
FROM pizzas
JOIN order_details USING (pizza_id)
GROUP BY size
ORDER BY num_orders DESC
LIMIT 1;
```

#### 5️⃣ Top 5 Most Ordered Pizza Types
```sql
SELECT name, SUM(quantity) AS quantity
FROM pizza_types
JOIN pizzas USING (pizza_type_id)
JOIN order_details USING (pizza_id)
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;
```

#### 6️⃣ Total Quantity of Each Pizza Category Ordered
```sql
SELECT category, SUM(quantity) AS quantity
FROM pizza_types
JOIN pizzas USING (pizza_type_id)
JOIN order_details USING (pizza_id)
GROUP BY category
ORDER BY quantity DESC;
```

#### 7️⃣ Order Distribution by Hour
```sql
SELECT HOUR(order_time) AS hour_, COUNT(order_id) AS num_orders
FROM orders
GROUP BY hour_;
```

#### 8️⃣ Category-wise Distribution of Pizzas
```sql
SELECT category, COUNT(name) AS count_
FROM pizza_types
GROUP BY category
ORDER BY count_ DESC;
```

#### 9️⃣ Average Number of Pizzas Ordered Per Day
```sql
SELECT ROUND(AVG(sum_o), 0) AS avg_orders_per_day
FROM (
    SELECT order_date, SUM(quantity) AS sum_o
    FROM orders
    JOIN order_details USING (order_id)
    GROUP BY order_date
) AS avg_data;
```

#### 🔟 Top 3 Most Ordered Pizza Types by Revenue
```sql
SELECT name, ROUND(SUM(quantity * price), 0) AS revenue
FROM pizza_types
JOIN pizzas USING (pizza_type_id)
JOIN order_details USING (pizza_id)
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;
```

#### 🔢 Revenue Contribution of Each Pizza Type
```sql
SELECT name, 
       (SUM(quantity * price) / (SELECT SUM(quantity * price) FROM order_details
                                 JOIN pizzas USING (pizza_id)
                                 JOIN pizza_types USING (pizza_type_id))) * 100 AS percentage
FROM order_details
JOIN pizzas USING (pizza_id)
JOIN pizza_types USING (pizza_type_id)
GROUP BY name;
```

#### 📈 Cumulative Revenue Over Time
```sql
SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT order_date, ROUND(SUM(quantity * price), 0) AS revenue
    FROM orders
    JOIN order_details USING (order_id)
    JOIN pizzas USING (pizza_id)
    GROUP BY order_date
) AS revenue_data;
```

#### 🔝 Top 3 Most Ordered Pizza Types by Revenue Per Category
```sql
WITH cte AS (
    SELECT category, name, SUM(quantity * price) AS revenue,
           ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(quantity * price) DESC) AS ranks
    FROM order_details
    JOIN pizzas USING (pizza_id)
    JOIN pizza_types USING (pizza_type_id)
    GROUP BY category, name
)
SELECT category, name, ROUND(revenue, 0) AS revenue
FROM cte
WHERE ranks <= 3;
```

## ⚙️ SQL Techniques Used
- **Data Cleaning** (`IS NULL`, `MODIFY`)
- **Duplicate Detection** (`ROW_NUMBER() OVER()`)
- **Aggregation & Grouping** (`SUM()`, `COUNT()`, `GROUP BY`)
- **Ranking Analysis** (`ORDER BY`, `LIMIT`)
- **Join Operations** (`JOIN USING(...)`)
- **Window Functions** (`SUM() OVER()`)

## 🚀 How to Run
1. **Create the Database**:
   ```sql
   CREATE DATABASE pizza_project;
   USE pizza_project;
   ```
2. **Import Data**: Load tables with CSV files (if applicable).
3. **Run Queries**: Execute the SQL statements to analyze the dataset.



