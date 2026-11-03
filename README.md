# Brazilian E-Commerce Sales Analysis
**Tools:** SQL (Google BigQuery), Looker Studio

Looker Studio Dashboard: https://datastudio.google.com/reporting/5b27bbfa-b057-4acf-80a9-e1c2c55a3a1a

<img width="664" height="495" alt="Снимок экрана 2026-11-03 в 05 25 07" src="https://github.com/user-attachments/assets/58133be8-a3fd-4ef3-babc-dd19b6c6a505" />


## Business question:
Which product categories and regions drive the revenue of Olist, a Brazilian e-commerce platform that sells through several marketplaces, how did sales develop over time, and where does delivery fall short of what customers were promised?

## Data
- **Source:** Brazilian E-Commerce Public Dataset by Olist on Kaggle (9 CSV files). (https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) 
- The dataset describes about 100k orders from 2016 to 2018.
- **Scope of the analysis:** delivered orders purchased from January 1, 2017, to August 31, 2018. 2016 is excluded because it contains only a handful of orders.

## Key Findings
- Total revenue: about 13.18 million BRL from 96,211 delivered orders (January 2017 - August 2018). Average order value is roughly 136 BRL.
-  Revenue is concentrated in a few categories. The top 10 of 73 categories generate 62.5% of revenue (8.23 of 13.18 million BRL). The leader is Health & Beauty.
-  The number of completed orders increased from 750 in January 2017 to 4,478 in October of the same year, then rose sharply to 7,289 the following month (November 2017). In 2018, order volume stabilized at approximately 6,000–7,000 per month. The surge in November could be attributed to "Black Friday," though this cannot be stated with certainty.
-  Sales are geographically concentrated: Sao Paulo (SP) is by far the largest state by revenue
-  Delivery reliability differs by region. About 8% of delivered orders arrive after the promised date. The highest late-delivery rates are in mostly northeastern states (AL, MA, PI, CE, SE, BA).
- Customers are generally satisfied: the average review score is about 4.15 out of 5.

  Some information above are not shown on the dashboard (total number of orders, number of categories, top-10 share, orders per month). They can be reproduced with `support_query.sql`.

## Query Description

The full query with comments is in [`olist_dashboard_query.sql`](olist_dashboard_query.sql). It is built from chained CTEs:
 
| CTE | What it does |
|-----|--------------|
| `delivered_orders` | Delivered orders from 2017 on, with purchase month, customer state and a late-delivery flag |
| `review_per_order` | Collapse all reviews for each order into a single line showing the average score for that specific order |
| `items_with_category` | Items with English category names |
| `order_category_revenue` | Revenue, freight and item count per order and category |
| `month_category_state` | Final grain:  order, revenue, late and review counts |
| `category_totals` | Window function `SUM() OVER (PARTITION BY category)`: total revenue per category |
| `category_ranked` | Window function `DENSE_RANK()`: category ranking by revenue |
