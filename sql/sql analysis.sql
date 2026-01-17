use customer_behavior;
SELECT * FROM customer;

# what is the revenue genarated by male vs female?
select gender,
sum(purchase_amount) as amount
from customer
group by gender;

# which customer used a discount but still spent more than the avg purchase amount?
with discount_applied as (
select customer_id,purchase_amount
from customer
where discount_applied="yes")
select customer_id,purchase_amount
from discount_applied
where purchase_amount >= (select avg(purchase_amount) from customer);

# what are the top 5 products with highest avg review rating?
use customer_behavior;
select item_purchased,round(avg(review_rating),2) as avg_product_rating
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

# compare the avg purchase amounts btw standard and expenses shipping?
select shipping_type,avg(purchase_amount) as avg_amount 
from customer
where shipping_type in ("Express","Standard")
group by shipping_type;

#Do subscribe customer spend more ? compare avg spend and total revenue btw subscribe and non-subscribe ?
select subscription_status,
count(customer_id) as total_customers,
avg(purchase_amount) as avg_spend,
sum(purchase_amount) as total_spend
from customer
group by subscription_status
order by avg_spend,total_spend desc;

# which 5 products have the high percentage of purchase with discount applied ?
SELECT
    item_purchased,
    ROUND(
        SUM(CASE WHEN discount_applied = 'yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS discount_purchase_percentage
FROM customer
GROUP BY item_purchased
ORDER BY discount_purchase_percentage DESC
LIMIT 5;

# segment customers into new,returning and loyal based on their number of previous purchases and show the count of each customer ?
with customer_type as (
select customer_id,previous_purchases,
case when previous_purchases = 1 then "New"
	when previous_purchases between 2 and 10 then "Returning"
    else "Loyal"
    end as customer_segment
from customer)
select customer_segment,count(*) as Number_of_Customers
from customer_type
group by customer_segment;

# what are the top 5 most purchased product within each category
WITH product_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS purchase_count
    FROM customer
    GROUP BY category, item_purchased
),
ranked_products AS (
    SELECT
        category,
        item_purchased,
        purchase_count,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY purchase_count DESC
        ) AS rn
    FROM product_counts
)
SELECT
    category,
    item_purchased,
    purchase_count
FROM ranked_products
WHERE rn <= 5
ORDER BY category, purchase_count DESC;

# are customers who are repeated buyers (more than 5 previous purchases) also subscribe ?
select subscription_status,count(customer_id) as repeated_customers
from customer
where previous_purchases >= 5 
group by subscription_status
order by repeated_customers desc;

# what is the revenue contribution by each age group ?
select age_group,
sum(purchase_amount)as total_revenue
from customer
group by age_group
order by total_revenue desc;
