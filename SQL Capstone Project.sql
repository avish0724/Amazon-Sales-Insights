-- Data Wrangling:

CREATE DATABASE IF NOT EXISTS amazon;
USE amazon;


CREATE TABLE IF NOT EXISTS amazondata  (
invoice_id VARCHAR(30) NOT NULL ,
branch VARCHAR(5) NOT NULL ,
city VARCHAR(30) NOT NULL ,
customer_type VARCHAR(30) NOT NULL ,
gender VARCHAR(10) NOT NULL ,
product_line VARCHAR(100) NOT NULL  ,
unit_price DECIMAL(10,2) NOT NULL ,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(10,2) NOT NULL ,
date DATE NOT NULL ,
time TIME NOT NULL ,
payment_method VARCHAR(200) NOT NULL ,
cogs DECIMAL(10,2) NOT NULL ,
gross_margin_percentage FLOAT(11,9) NOT NULL ,
gross_income DECIMAL(10,2) NOT NULL ,
rating FLOAT(2,1) NOT NULL
);
SELECT * FROM amazondata;

-- Feature Engineering:

# Adding a new column named timeofday to get insights of sales in morning,afternoon and evening

ALTER TABLE amazondata
ADD COLUMN timeofday VARCHAR(15);

UPDATE amazondata 
SET timeofday = 
	IF(hour(time) >= 0 AND hour(time) < 12, 'Morning',
		IF(hour(time) >= 12 AND hour(time) < 18, 'Afternoon','Evening'));
        
# Adding a new column named dayname

ALTER TABLE amazondata
ADD COLUMN dayname VARCHAR(10);

UPDATE amazondata
SET dayname = DAYNAME(date);


#  Adding a new column named monthname

ALTER TABLE amazondata
ADD COLUMN monthname VARCHAR(10);

UPDATE amazondata
SET monthname = MONTHNAME(date);


#EDA Part

-- Business Questions to Answer

# 1.What is the count of distinct cities in the dataset?

SELECT COUNT(DISTINCT city)
FROM amazondata;

# 2.For each branch, what is the corresponding city?

SELECT DISTINCT branch,city 
FROM amazondata 
ORDER BY branch;


# 3.What is the count of distinct product lines in the dataset?

SELECT COUNT(DISTINCT product_line)
FROM amazondata;


# 4.Which payment method occurs most frequently?

SELECT payment_method , COUNT(*) AS pm
FROM amazondata 
GROUP BY payment_method
ORDER BY pm DESC
LIMIT 1;


#5.Which product line has the highest sales?

SELECT product_line,COUNT(invoice_id) AS sale_count
FROM amazondata
GROUP BY product_line
ORDER BY sale_count desc LIMIT 1;


#6.How much revenue is generated each month?

SELECT monthname,SUM(total) AS revenue
FROM amazondata
GROUP BY monthname
ORDER BY revenue DESC;


#7.In which month did the cost of goods sold reach its peak?

SELECT monthname,SUM(cogs) AS cost_ofgood
FROM amazondata
GROUP BY monthname
ORDER BY cost_ofgood DESC LIMIT 1;


#8.Which product line generated the highest revenue?

SELECT product_line,SUM(total) AS revenue
FROM amazondata
GROUP BY product_line
ORDER BY revenue DESC LIMIT 1;


#9.In which city was the highest revenue recorded?

SELECT city,SUM(total) AS revenue
FROM amazondata
GROUP BY city
ORDER BY revenue DESC limit 1;


#10.Which product line incurred the highest Value Added Tax?

SELECT product_line,SUM(VAT) AS tax
FROM amazondata
GROUP BY PRODUCT_LINE
ORDER BY tax DESC LIMIT 1;

#11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SELECT product_line,SUM(total) AS revenue,
CASE
	WHEN
		SUM(total) < (SELECT AVG(total) FROM amazondata) THEN 'bad'
	ELSE 'good'
	END AS sales_category
FROM amazondata
GROUP BY product_line
ORDER BY revenue DESC;


#12.Identify the branch that exceeded the average number of products sold

SELECT branch,SUM(quantity) AS total_quantity
FROM amazondata 
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM amazondata);


#13.Which product line is most frequently associated with each gender?

WITH freq AS (
SELECT product_line,gender,
row_number() OVER (partition by gender ORDER BY COUNT(*) DESC)  AS first_rank
FROM amazondata 
GROUP BY product_line,gender
)
SELECT product_line,gender 
FROM freq 
WHERE first_rank = 1;


#14.Calculate the average rating for each product line.

SELECT product_line,AVG(rating) AS avg_rating
FROM amazondata
GROUP BY product_line
ORDER BY avg_rating DESC;


#15.Count the sales occurrences for each time of day on every weekday.

SELECT dayname,timeofday,COUNT(invoice_id) AS sales_occurences
FROM amazondata
WHERE dayname NOT IN ('Saturday','Sunnday')
GROUP BY dayname,timeofday
ORDER BY dayname DESC,sales_occurences DESC;


#16.Identify the customer type contributing the highest revenue.

SELECT customer_type, SUM(total) as revenue
FROM amazondata
GROUP BY customer_type
ORDER BY revenue DESC LIMIT 1;


#17.Determine the city with the highest VAT percentage.

SELECT city,MAX(VAT)
FROM amazondata
GROUP BY city
ORDER BY MAX(vat) DESC LIMIT 1;


#18.Identify the customer type with the highest VAT payments.

SELECT customer_type,MAX(VAT) AS highest_vat
FROM amazondata 
GROUP BY customer_type
ORDER BY highest_vat DESC LIMIT 1;


#19.What is the count of distinct customer types in the dataset?

SELECT COUNT(DISTINCT customer_type) AS cust_type
FROM amazondata;


#20.What is the count of distinct payment methods in the dataset?

SELECT COUNT(DISTINCT payment_method) 
FROM amazondata;


#21.Which customer type occurs most frequently?

SELECT COUNT(*) AS occurence,customer_type
FROM amazondata 
GROUP BY customer_type
ORDER BY COUNT(*) DESC LIMIT 1;


#22.Identify the customer type with the highest purchase frequency.

SELECT customer_type,COUNT(invoice_id) AS purchase_freq
FROM amazondata
GROUP BY customer_type
ORDER BY COUNT(invoice_id) DESC LIMIT 1;


#23.Determine the predominant gender among customers.

SELECT gender, COUNT(*) AS gender_count
FROM amazondata
GROUP BY gender
ORDER BY gender_count DESC
LIMIT 1;


#24.Examine the distribution of genders within each branch.

SELECT branch,gender,COUNT(*) AS gender_count
FROM amazondata 
GROUP BY branch,gender 
ORDER BY branch,gender_count DESC;


#25.Identify the time of day when customers provide the most ratings.

SELECT  timeofday,COUNT(*) AS rate_time
FROM amazondata
GROUP BY timeofday
ORDER BY rate_time DESC LIMIT 1;


#26.Determine the time of day with the highest customer ratings for each branch.

SELECT branch,timeofday,COUNT(*) AS rating_time
FROM amazondata
GROUP BY branch,timeofday
ORDER BY branch,rating_time DESC;


#27.Identify the day of the week with the highest average ratings.

SELECT DAYNAME,AVG(rating) AS avg_rating
FROM amazondata
GROUP BY dayname
ORDER BY avg_rating DESC LIMIT 1;


#28.Determine the day of the week with the highest average ratings for each branch.

WITH high_avg AS (
SELECT branch,timeofday,AVG(rating) AS avg_rating,
row_number() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS row_num
FROM amazondata
GROUP BY branch,timeofday
)
SELECT branch,timeofday,avg_rating FROM high_avg
WHERE row_num = 1
ORDER BY branch;