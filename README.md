# subscribers-userbase
## Introduction
This project aims to showcase a custom userbase segmentation and price point analysis using SQL/PowerBI. 

It is based on a fictional subscription-based business model of a small company (around 50k users). Subscriptions were offered at various prices throughout the past and the business is undertaking a price increase initiative to align subscription prices in all territories.

I have created a custom database 'dolphin' in MySQL Server 8.0 with four tables, generated and ingested the data. The data has then been manipulated using SQL with common table expressions, joins, aggregates, window functions and more to create a hollistic breakdown view of company's userbase in the form of a view. Microsoft PowerBI has been used to pull the tables and the view in order to create an interactive dashboard while seeking for valuable conclusions.

## Data Model

Company's database has been set up in a cascading model instead of a more typical dim/fact star schema approach. This means that a table1 is a dimension table for its fact table2 which then in turn acts as a dim table for fact table3. The downside of this top-down approach is that the tables can grow exponentially in size and complexity, but the architects have deemed it suitable for the business model.
![data model schema](https://github.com/vuoteen/subscribers-userbase/assets/166431469/1a4b50cb-423d-41f3-90e4-c10cde94c510)

- "<b>users</b>"  - This table stores information about unique users who can have multiple subscriptions. It includes personal data, their invoicing and currency details as well as test user boolean indicator that will allow to analyze genuine users only

- "<b>subscriptions</b>" - This table stores subscriptions that can include many products (recurring subscriptions, pay-per-view type products, additional products and services). Subscriptions are identifiable by both "Number" and "Id" the latter of which is used as a primary key. "SubscriptionType" indicates if the subscriptions has been initiated directly with the business or via a third-party which impacts liability. "TermType" indicates whether the subscription has a defined end date (for example yearly subscription) or is active until on-demand cancellation notice is placed.

- "<b>subscriptionproducts</b>" - This table lists all products that make a particular subscription with its commercial name, internal product ID ("CatalogueId") and unique id identifiable with a particular subscription ("Id").

- "<b>productdetails</b>" - This table provides details on all products found on all subscription outlining product price history across subscription lifecycle

Example: user1 ("users") has 2 subscriptions ("subscriptions") with 3 products ("subscriptionproducts") all of which had their price changed 3 times ("productdetails") - 18 records
