# 🛒 E-Commerce Customer & Sales Analysis

A complete end-to-end data analytics project covering **SQL-based data preparation**, **Python EDA**, and an **interactive Power BI dashboard** — built on a real-world e-commerce dataset with 519 customers, 100 orders, and 8 products across multiple Indian cities.

---

## 📌 Project Overview

| Item | Detail |
|---|---|
| **Domain** | E-Commerce / Retail Analytics |
| **Tools Used** | MySQL, Python (Pandas, Matplotlib, Seaborn), Power BI |
| **Dataset Size** | 519 customers · 100 orders · 519 order line items · 8 products |
| **Dashboard Pages** | 4 (Executive, Customer, Product, Advance Analysis) |
| **DAX Measures** | 14 custom measures including MoM Growth, Running Revenue, RFM, CLV |

---

## 📁 Project Structure

```
ecommerce-analysis/
│
├── data/
│   ├── customers.csv          # 519 customers with name and location
│   ├── orders.csv             # 100 orders with dates and amounts
│   ├── orderdetails.csv       # Line-level order items (quantity × price)
│   └── products.csv           # 8 products across 3 categories
│
├── sql/
│   └── E_CommerceCaseStudy.sql   # All 20 SQL queries across 6 phases
│
├── dashboard/
│   └── E-CommerceCS.pbix      # Power BI dashboard (4 pages, 14 measures)
│
└── README.md
```

---

## 🗄️ Database Schema

```
customers          orders              orderdetails         products
──────────         ──────────          ──────────────       ──────────
customer_id  ──┐  order_id (PK)       order_id  ──────┐   product_id (PK)
name           │  order_date     ┌──  product_id       └── product_id
location       └─ customer_id ◄──┘   quantity           name
                  total_amount        price_per_unit     category
                                                         price
```

> **Note:** `orders.total_amount` was found to be inconsistent with transaction-level data during validation. All revenue metrics were recalculated from `quantity × price_per_unit` in `orderdetails` to ensure accuracy.

---

## 🔍 SQL Analysis — 6 Phases, 20 Queries

### Phase 1 — Data Import & Restructuring
- Imported raw CSVs into MySQL Workbench
- Retained only relevant columns per table to enforce a clean schema

### Phase 2 — Data Quality Check
- Null value checks across all 4 tables
- Duplicate detection and removal (using `DISTINCT` on `orderdetails`)
- Date type conversion (`STR_TO_DATE`)
- **Revenue reconciliation:** discovered and corrected mismatches between `orders.total_amount` and line-level calculations

### Phase 3 — Customer Analysis
- Total customers count
- Customer distribution by location
- Top 10 customers by revenue
- Average order value per customer

### Phase 4 — Product Analysis
- Best-selling products by units sold
- Revenue by product and by category
- Highest revenue product identification

### Phase 5 — Sales Analysis
- Monthly revenue trend
- Monthly order volume
- Average order value by month
- **Month-over-Month (MoM) revenue growth** using `LAG()` window function
- Highest revenue month
- Revenue by customer location
- **Running revenue total** using cumulative `SUM()` window function

### Phase 6 — Advanced Analysis
- **Customer Lifetime Value (CLV)** — total spend per customer
- **Pareto Analysis** — top 20% customer contribution
- **Customer Segmentation** — Low Value / Regular / VIP based on spend thresholds
- **Product Ranking within Category** — using `RANK() OVER (PARTITION BY)`
- **RFM Analysis** — Recency, Frequency, Monetary scoring

---

## 📊 Power BI Dashboard — 4 Pages

### Page 1: Executive Dashboard
High-level KPIs with location and category slicers.
- KPI Cards: Total Revenue, Total Orders, Total Customers, AOV
- Monthly revenue trend (line chart)
- Revenue by category (donut chart)
- Revenue by location (treemap)

### Page 2: Customer Analysis
- Top 10 customers by revenue
- Customer frequency distribution by segment
- Customer location breakdown
- Customer segment split (pie chart)
- Customer lifetime value by location

### Page 3: Product Analysis
- Units sold by product
- Revenue by product
- Revenue by category (donut)
- Category-level slicer for drill-down
- Product rank table

### Page 4: Advance Analysis
- MoM revenue growth pivot table
- Running/cumulative revenue (area chart)
- Revenue by month (bar chart)
- Category revenue pivot and donut

---

## 📐 DAX Measures

| Measure | Purpose |
|---|---|
| `Total Revenue` | `SUM` of revenue from order details |
| `Total Orders` | `COUNTROWS` of orders |
| `Total Customers` | `DISTINCTCOUNT` of customer IDs |
| `Total Products` | Count of distinct products |
| `Units Sold` | `SUM` of quantity |
| `AOV` | Average Order Value = Revenue / Orders |
| `Previous Month Revenue` | `CALCULATE` + `DATEADD` / `PREVIOUSMONTH` |
| `MoM Growth` | % change vs previous month |
| `Running Revenue` | Cumulative revenue using `CALCULATE` + date filter |
| `Cumulative % Simple` | Running Revenue / Total Revenue |
| `Product Rank` | `RANKX` over products by revenue |
| `Customer Segment` | `SWITCH`/`IF` segmentation logic |
| `Customer Frequency` | Purchase count per customer |
| `avg Revenue by unit sold` | Revenue per unit sold |

---

## 💡 Key Business Insights

- **Revenue reconciliation gap** identified between order-level totals and line-item calculations — corrected before analysis
- **Top 10 customers** drive a disproportionate share of revenue (Pareto principle validated)
- **Electronics** is the dominant category by both revenue and units sold
- **MoM growth** shows seasonal variation — specific months show significant dips and spikes
- **Customer segmentation** reveals most customers fall in the Low Value tier, indicating upsell opportunity
- **RFM scoring** identifies high-value, recent, frequent buyers for targeted retention

---

## 🛠️ How to Use

**SQL:**
1. Import all 4 CSVs into MySQL Workbench as separate tables
2. Run `E_CommerceCaseStudy.sql` sequentially — phases are clearly marked with comments

**Power BI:**
1. Open `E-CommerceCS.pbix` in Power BI Desktop
2. Reconnect data sources if prompted (point to the `/data` folder)
3. Refresh the report

---

## 👤 Author

**Adnan Sajjad Makrani**
Data Analyst | Bhopal, India
[LinkedIn](#) · [GitHub](#) · adnansajjad360@gmail.com
