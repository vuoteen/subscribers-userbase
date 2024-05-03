# subscribers-userbase
## Introduction
This project aims to showcase a custom userbase segmentation and price point analysis using SQL/PowerBI. 

It is based on a fictional subscription-based business model of a small company (around 50k users). Subscriptions were offered at various prices throughout the past and the business is undertaking a price increase initiative to align subscription prices in all territories.

I have created a custom database 'dolphin' in MySQL Server 8.0 with four tables, generated and ingested the data. 
![PopSQL](https://github.com/vuoteen/subscribers-userbase/assets/166431469/a2a2d2d1-0d82-4476-ad9c-41c31234372c)
The data has then been manipulated using SQL (via PopSQL tool) with common table expressions, joins, aggregates, window functions and more to create a holistic breakdown view of company's userbase in the form of a view. Microsoft PowerBI has been used to pull the tables and the view in order to create an interactive dashboard while seeking valuable conclusions.

## Data Model

The company's database has been set up in a cascading model instead of a more typical dim/fact star schema approach. This means that a table1 is a dimension table for its fact table2 which then in turn acts as a dim table for fact table3. The downside of this top-down approach is that the tables can grow exponentially in size and complexity, but the architects have deemed it suitable for the business model.
![data model schema](https://github.com/vuoteen/subscribers-userbase/assets/166431469/1a4b50cb-423d-41f3-90e4-c10cde94c510)

- "<b>users</b>"  - This table stores information about unique users who can have multiple subscriptions. It includes personal data, their invoicing and currency details as well as test user boolean indicator that will allow to analyze genuine users only

- "<b>subscriptions</b>" - This table stores subscriptions that can include many products (recurring subscriptions, pay-per-view type products, additional products and services). Subscriptions are identifiable by both "Number" and "Id" the latter of which is used as a primary key. "SubscriptionType" indicates if the subscriptions has been initiated directly with the business or via a third-party which impacts liability. "TermType" indicates whether the subscription has a defined end date (for example yearly subscription) or is active until on-demand cancellation notice is placed.

- "<b>subscriptionproducts</b>" - This table lists all products that make a particular subscription with its commercial name, internal product ID ("CatalogueId") and unique id identifiable with a particular subscription ("Id").

- "<b>productdetails</b>" - This table provides details on all products found on all subscriptions, outlining product price history across the subscription lifecycle

Example: user1 ("users") has 2 subscriptions ("subscriptions") with 3 products ("subscriptionproducts") all of which had their price changed 3 times ("productdetails") - 18 records

## Tables creations

Please refer to <b>sql files/create tables.sql</b> file

Each table has been created with a unique VARCHAR(6) primary key 'Id' that are used as foreign keys to the remaining tables as shown in the model above. It has been randomly generated to ensure uniqueness which is fine for this project, however a much more effective and safe approach would be to use BIGINT or UUID as primary keys. 

All standard data types have been used such as DECIMAL, BOOLEAN, VARCHAR, DATE and TIMESTAMP with character lengths/number of digits allowed handcrafted for the prepared dataset. Normally, one should execute much more caution to properly account for what data might be coming in the future to avoid having to alter already existing tables with many records.

Also a non-standard ENUM(value1,value2) approach was used to restrict allow values, however it's advisable to introduce such restraints upstream (for example in a dim table) which is much more efficient and future-proof. It's fine for this pre-defined project, however it's known to have bad performance and create unnecessary roadblocks when adding/altering allowed column values.

## Data ingestion

Please refer to <b>sql files/data ingest.sql</b> file

My databases has been populated with data via a csv files upload directly into the created tables. I utilized a native upload folder for MySQL Server 8.0 that allowed me to use LOAD DATA INFILE command to insert data after having specified the delimiters, making sure to ignore the first line containing table headers.

## SQL view for data analysis

Please refer to <b>sql files/create view.sql</b> file

As mentioned in the introduction, the business seeks to align subscription prices for its subscribers in various markets. All territories have a market price that subscriptions are sold at, but still there are many users who have subscribed at a previous lower price point.

The main question that the business first wants to have answered is <b>"How many direct, cable and internet provider subscribers do we have in each market at a given price point and what type of subscription do they hold?"</b>. 

After this question is answered, we'll look to investigate which territories have the largest population of underpriced subscriptions and various other trends.
To achieve this a SQL view is to be created and then loaded into PowerBI to limit the amount of data manipulation required via DAX. This approach helps keep the data preparation upstream and is much more performant and reliable than using the BI tool to manipulate data.
![View results sample](https://github.com/vuoteen/subscribers-userbase/assets/166431469/9583a715-0651-461b-9cc7-1e9c263de2f5)

<ins>Query breakdown</ins><br>

Firstly the common table expression (cte) is created that joins all the tables together selecting the minimal number of columns required for analysis.<br> Filtering is keeping only subscriptions that are active or with pending future cancellation, discarding the ones that already ended. Also only direct (s.SubscriptionType IS NULL) or cable/internet provider subscription types are kept, as per the business case. Finally, the test accounts are discarded as are all product models other than type FlatFee (such as individual custom discounts or free periods via 'DiscountPercentage').<br> A dense rank window function is introduced to rank the subscriptions price changes from the most recent one (latest starting and ending dates).

We then proceed to select the columns from cte, performing a few transformations, that should have ideally been done upstream in the data source
- converting SubscriptionType NULL into 'Direct', 'Internet Provider' and 'Cable Provider' into 'Third-Party'
- inferring the plan type from the product name string using LIKE '%(...)%' operator<br>

Also, the stakeholders wanted to have a few aggregated subscriptions counts which were introduced via summing various partitioned counts - total count, per subscription category, subscription type, plan type and subscription country.

The only filter is selecting the dense_rank = 1 which is keeping only the latest price point of the subscription lifecycle. This is the only reason why we needed to create a cte in the first place, as it's not possible to create a rank and filter it in the same query due to MySQL execution order.<br> If we were using Snowflake for example, we could use QUALIFY operator in the dense_rank command to filter it immediately, skipping the cte. 

Lastly, the required grouping is set up with ordering to improve data visibility.

## PowerBI dashboard

The "subscription_breakdown" view, which is going to be the main data source for the analysis, has been loaded into PowerBI through the MySQL Server connection. The four tables from the database, although technically redundant, have been loaded as well to help visualize data relationships. Additionally, two additional tables are added (via xlsx fines) with relationships created to the view - "new_season_price" which holds target prices for the price increase initiative and "fx_rates" which is used for the financial piece of the analysis. 

Two DAX columns were introduced to "subscription_breakdown". The first one "SubscriptionPrice" is inferring the true price the customer is paying from MonthlyPrice column by either multiplying it by 12 in case of Annual subscriptions or keeping the value unaltered for monthly subscriptions. The other new column "Is_At_Season_Price" is looking up the newly created SubscriptionPrice value in the "new_season_price" to answer whether a particular user cohort needs a price increase or whether they are already on the correct new season price. Lastly, around a dozen DAX measures are created and stored exclusively in the designated table "#Measures".

### <i>Season price users breakdown</i>

The first visual is focused on the general number of subscribers per country and the proportion of subscribers already at the correct price point.<br> Over half of the existing users are already paying the designated amount with varying trends in particular markets. Five of them have more correctly priced users than the global average, with no particular outlier. The remaining five markets dip below the global average with Japan scoring particularly weak with just over 29% of users at correct price point. <br>

![User breakdown visual](https://github.com/vuoteen/subscribers-userbase/assets/166431469/2fc78428-634f-4700-a7bb-75a977caf418)

While hovering over a given country's column the user will see a custom tooltip providing more details on the user distribution

![User breakdown tooltip visual](https://github.com/vuoteen/subscribers-userbase/assets/166431469/1e97ba34-0400-4576-89b7-90918fcf5344)

### <i>Monetization changes</i>

Having learned that there are over 42% existing users that the business wants to increase the price for, the aim is now to forecast next season's revenue once the global pricing has been aligned. This model assumes a utopia scenario where none of the existing users churn. <br>
This is achievied via "current_annual_revenue_eur" and "potential_annual_revenue_eur" measures that aggregate yearly subscription income from all subscribers at current and future prices. They are then juxtaposed together having been recalculated using the latest exchange rates.

![Monetization changes](https://github.com/vuoteen/subscribers-userbase/assets/166431469/1b764476-6044-43c5-ba62-54627e93f177)

The business is currently making €5.8 million from its subscribers looking to increase that number by €2.3 million to a total of €8.1 million in our utopia scenario. <br> Japan is looking to almost double its revenue which can be attributed to their lower ratio of existing subscribers at next seasons' price. Australia is set to grow the least due to having the strongest ratio of users at correct pricing that do not require price rising and a relatively mild price increase jump. <br> Monetarily speaking, Japan is also looking to gain the second-most (€386.99k) despite placing fifth in the current revenue ranking. The Netherlands stand to profit the most, amassing just shy of 40% of total EUR to be gained by the business, thanks to the biggest userbase of all markets and a fairly large number of users to price increase. Brazil is to see the weakest monetary difference of €26.6k due to low subscriber numbers and a solid ratio of users at next season's pricing. 

### <i>Product type breakdown</i>

For end users that require more detail on product level an interactive map was created to provide insights into particular subscriber cohorts.

![Interactive map visual](https://github.com/vuoteen/subscribers-userbase/assets/166431469/d4ae4ec8-211d-416e-bffa-0c4bac7397bb)

After selecting the desired market and subscriber segmentation, the user can drill through to the detailed breakdown by following the explore button.

![Interactive map drillthrough visual](https://github.com/vuoteen/subscribers-userbase/assets/166431469/4390a133-fd3d-4bc6-829c-9e876db3faf6)

This visual displays the most granular breakdown where we can see how many subscribers there are at each product and price point as well as how much each user cohort stands to gain after the price increase initiative is completed.<br>
For user convenience, a back button is available as well as a Settings table that displays the chosen conditions.



