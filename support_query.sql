/*
  Supporting queries for the README.
  Each query reproduces figures quoted in the README that are not directly
  visible on the dashboard. Dialect: BigQuery Standard SQL.
*/
 
-- 1) Total number of delivered orders in scope
-- (96,211 delivered orders)
SELECT 
  COUNT(*) AS delivered_orders
FROM `brazilian_commerce.orders`
WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= TIMESTAMP('2017-01-01');
 
 
-- 2) Delivered orders per month
-- (750 -> Jan 2017, 4,478 -> Oct 2017, 7,289 -> Nov 2017)
SELECT
  DATE(TIMESTAMP_TRUNC(order_purchase_timestamp, MONTH)) AS month,
  COUNT(*) AS orders_cnt
FROM `brazilian_commerce.orders`
WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= TIMESTAMP('2017-01-01')
GROUP BY month
ORDER BY month;
 
 
/* 
3) Number of categories, total revenue and share of the top 10 categories
(73 categories, top 10 = 62.5% of revenue)
Items without a category are labelled 'unknown', 
they count towards total revenue but aren't counted as a category. 
*/
WITH category_revenue AS (
  SELECT
    COALESCE(
      t.string_field_1,
        CASE p.product_category_name
          WHEN 'pc_gamer' THEN 'pc_gamer'
          WHEN 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'portable_kitchen_food_preparers'
        END,
      'unknown') AS category,
    SUM(i.price) AS revenue
  FROM `brazilian_commerce.order_items` AS i
  INNER JOIN `brazilian_commerce.orders` AS o
    USING (order_id)
  INNER JOIN `brazilian_commerce.products` AS p
    USING (product_id)
  LEFT JOIN `brazilian_commerce.category_name_translation` AS t
    ON p.product_category_name = t.string_field_0
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= TIMESTAMP('2017-01-01')
  GROUP BY category
),
 
ranked AS (
  SELECT
    category,
    revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS rnk
  FROM category_revenue
)
 
SELECT
  COUNT(CASE WHEN category != 'unknown' THEN 1 END)               AS categories_cnt,
  ROUND(SUM(CASE WHEN rnk <= 10 THEN revenue END), 2)             AS top10_revenue,
  ROUND(SUM(revenue), 2)                                          AS total_revenue,
  ROUND(SUM(CASE WHEN rnk <= 10 THEN revenue END) / SUM(revenue) * 100, 1) AS top10_share_pct
FROM ranked;
