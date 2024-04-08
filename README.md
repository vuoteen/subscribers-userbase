# subscribers-userbase
## Introduction
This project aims to showcase a custom userbase segmentation and price point analysis using SQL/PowerBI. It is based on a fictional subscription-based business model of a small company (around 50k users). Subscriptions were offered at various prices throughout the past and the business is undertaking a price increase initiative to align subscription prices in all territories.

I have created a custom database 'dolphin' in MySQL Server 8.0 with four tables, generated and ingested the data. The data has then been manipulated using SQL with common table expressions, joins, aggregates, window functions and more to create a hollistic breakdown view of company's userbase. Microsoft PowerBI has been used to pull the data in order to create an interactive dashboard while seeking for valuable conclusions.

## Data Model

Company's database has been set up in a cascading model instead of a more typical dim/fact star schema approach. This means that a table1 is a dimension table for its fact table2 which then in turn acts as a dim table for fact table3. The downside of this top-down approach is that the tables can grow exponentially in size and complexity, but the architects have deemed it suitable for the business model.
![data model schema](https://github.com/vuoteen/subscribers-userbase/assets/166431469/83379953-a589-4ca8-9c0a-4102d68a7789)

- Production Location
