# 2Market - Exploratory analysis 
  
### Project Overview
2Market is a global supermarket which sells products online and in-stores. 2Market needs to understand their customer purchase behaviour and effective advertising methods. Therefore, the problem statement is as follows: 2Market has insufficient insight on customer purchasing behaviour and optimal advertising methods. It is probable that the root cause of this problem is organisational in nature, as no previous attempts at analysis
have been made even though the primary data exists. Notably, an issue with using the problem-solving framework arises when the root cause is complex and may be impacted by interlinked factors, making the problem hard to pinpoint. With this in mind, I would like to pose the following questions to the 2Market team: Are all the products available online also available in store for purchase? And are all products available for purchase in all countries?

### Data Sources
1. Marketing_data__.csv contains information about customer demographics and product sales. 
2. ad_data.csv contain information about advertisement.

Both datasets were used during analysis and visualisation.

### Tools 
- Excel
- SQL Sever
- Tableau

### Data Cleaning/Preperation (Excel)
- Data loading and Inspection.
- Check for spelling errors.
- Check for missing/duplicate values.
- Homogenise Date Format.

### Exploratory analysis (Excel)
Key questions:

- What is the average age of 2Market’s customers?
- What is the average age of the customers belonging to each type of marital status?
- What is the average age of customers who earn a yearly income between US$90,000 and US$100,000?

  <img width="644" alt="image" src="https://github.com/Chloenjuguna/2Market-/assets/143361757/e95d9a36-3c60-461d-9a97-560828cbfd02">

  <img width="656" alt="image" src="https://github.com/Chloenjuguna/2Market-/assets/143361757/1a12efef-d778-43dd-8d12-34a4097cf380">

  <img width="615" alt="image" src="https://github.com/Chloenjuguna/2Market-/assets/143361757/462fa32f-6ab4-4688-96f5-0849d9a0b4c1">


### Exploratory analysis (SQL)
Key questions:
- What is the total spend per country?
- What is the total spend per product per country?
- Which products are the most popular based on martial status?
- Which products are the most popular based on whether or not there are children or teens in the home?
- Which method is the most effective method of advertising in each country?
- Which social media platform is the most effective method of advertising based on marital status?

```sql
-- Create table to contain advertising data
CREATE TABLE ad_data (
"ID" BIGSERIAL PRIMARY KEY, 
"Bulkmail_ad" numeric (2), 
"Twitter_ad" numeric (2),
"Instagram_ad" numeric (2),
"Facebook_ad" numeric (2),
"Brochure" numeric (2) );

-- View output 
SELECT * fROM public.ad_data

-- Create table to contain 2market market data
CREATE TABLE marketing_data (
"ID" BIGSERIAL PRIMARY KEY, 
"Year_Birth" INTEGER,
"Age" INTEGER,
"Education" VARCHAR (50),
"Martial_Status" VARCHAR (50),
"Income" INTEGER, 
"Kidhome" numeric (2),
"Teenhome" numeric (2),
"Dt_Customer" DATE, 
"Recency" INTEGER, 
"AmtLiq" INTEGER, 
"AmtVege" INTEGER, 
"AmtNonVeg" INTEGER, 
"AmtPes" INTEGER, 
"AmtChocolates" INTEGER, 
"AmtComm" INTEGER, 
"NumDeals" INTEGER, 
"NumWebBuy" INTEGER, 
"NumWalkinPur" INTEGER, 
"NumVisits" INTEGER, 
"Response" numeric (2), 
"Complain" numeric (2),
"Country" VARCHAR (20),
"Count_success" INTEGER);

-- View output
SELECT * FROM public.marketing_data

-- Add total spend column
ALTER TABLE marketing_data
ADD COLUMN Total_spent INTEGER;

-- Calculate total spend by adding the product's columns
UPDATE marketing_data 
SET total_spent = "AmtLiq" + "AmtVege" + "AmtNonVeg" + "AmtPes" + "AmtChocolates" + "AmtComm";

-- What is the total spend per country?
SELECT "Country", SUM("total_spent") AS "TotalSpendPerCountry"
FROM public.marketing_data
GROUP BY "Country"
ORDER BY "TotalSpendPerCountry" ASC;

-- What is the total spend per product per country?
SELECT "Country",
SUM("total_spent") AS "TotalSpendPerCountry",
SUM("AmtLiq") AS "Alcoholic beverages",
SUM("AmtVege") AS "Vegetables",
SUM("AmtNonVeg") AS "Meat items",
SUM("AmtPes") AS "Fish products",
SUM("AmtChocolates") AS "Chocolates",
SUM("AmtComm") AS "Commodities"
FROM public.marketing_data
GROUP BY "Country"
ORDER BY "TotalSpendPerCountry" DESC;

-- Which products are the most popular based on martial status?
SELECT DISTINCT ON ("Marital_status")
  "Marital_status",
  "AmtLiq" AS "Alcoholic beverages",
  "AmtVege" AS "Vegetables", 
  "AmtNonVeg" AS "Meat items", 
  "AmtPes" AS "Fish products", 
  "AmtChocolates" AS "Chocolates", 
  "AmtComm" AS "Commodities"
FROM (
  SELECT
	"Marital_status",
    "AmtLiq", 
    "AmtVege", 
    "AmtNonVeg", 
    "AmtPes", 
    "AmtChocolates", 
    "AmtComm",
    SUM("total_spent") AS "TotalSpend",
    ROW_NUMBER() OVER (PARTITION BY "Marital_status" ORDER BY SUM("total_spent") DESC) AS "Rank"
  FROM public.marketing_data
  GROUP BY "Marital_status", "AmtLiq", "AmtVege", "AmtNonVeg", "AmtPes", "AmtChocolates", "AmtComm"
) AS ProductRanking
WHERE "Rank" = 1;

-- Which products are the most popular based on whether or not there are children or teens in the home?
SELECT DISTINCT ON ("Kidhome", "Teenhome")
"Kidhome",
"Teenhome",
"AmtLiq",
"AmtVege",
"AmtNonVeg",
"AmtPes",
"AmtChocolates",
"AmtComm"
FROM (
  SELECT
"Kidhome",
"Teenhome",
"AmtLiq", 
"AmtVege", 
"AmtNonVeg", 
"AmtPes", 
"AmtChocolates", 
"AmtComm",
SUM("total_spent") AS "TotalSpend",
ROW_NUMBER() OVER (PARTITION BY "Kidhome", "Teenhome" ORDER BY SUM("total_spent") DESC) AS "Rank"
FROM public.marketing_data
GROUP BY "Kidhome", "Teenhome", "AmtLiq", "AmtVege", "AmtNonVeg", "AmtPes", "AmtChocolates", "AmtComm"
) AS ProductRanking
WHERE "Rank" = 1;

-- Which method is the most effective method of advertising in each country?
SELECT
  marketing_data."Country",
  SUM(ad_data."Bulkmail_ad") AS "Bulkmail_effectiveness",
  SUM(ad_data."twitter_ad") AS "Twitter_effectiveness",
  SUM(ad_data."Instagram_ad") AS "Instagram_effectiveness",
  SUM(ad_data."Facebook_ad") AS "Facebook_effectiveness",
  SUM(ad_data."Brochure") AS "Brochure_effectiveness"
FROM marketing_data 
JOIN ad_data ON marketing_data."ID" = ad_data."ID"
GROUP BY marketing_data."Country";

--Which social media platform is the most effective method of advertising based on marital status?
SELECT
  marketing_data."Marital_status",
  SUM(ad_data."Bulkmail_ad") AS "Bulkmail_effectiveness",
  SUM(ad_data."twitter_ad") AS "Twitter_effectiveness",
  SUM(ad_data."Instagram_ad") AS "Instagram_effectiveness",
  SUM(ad_data."Facebook_ad") AS "Facebook_effectiveness",
  SUM(ad_data."Brochure") AS "Brochure_effectiveness" 
FROM marketing_data 
JOIN ad_data ON marketing_data."ID" = ad_data."ID"
GROUP BY marketing_data."Marital_status"
ORDER BY "Bulkmail_effectiveness" DESC, "Twitter_effectiveness" DESC, "Instagram_effectiveness" DESC, "Facebook_effectiveness" DESC, "Brochure_effectiveness" DESC;
```

### Results
<img width="353" alt="Screenshot 2024-01-22 at 09 01 53" 
	src="https://github.com/Chloenjuguna/2Market-/assets/143361757/0d505c92-03a4-4228-b082-9c72d1052bfd">

- Spain had the highest total expenditure on products, compared to Australia, Canada, Germany, India, Montenegro, South Africa, and the United States of America.

- Among all countries, alcoholic beverages emerged as the most purchased product.
  
<img width="842" alt="Screenshot 2024-01-22 at 09 06 19" src="https://github.com/Chloenjuguna/2Market-/assets/143361757/a63e132d-f417-4cee-b60d-7b840adb40ac">

- Alcoholic beverages were the top-selling product across all marital statuses and among customers, regardless of whether they had children or teens in their homes or not. 

<img width="997" alt="Screenshot 2024-01-22 at 09 13 15" src="https://github.com/Chloenjuguna/2Market-/assets/143361757/560b8228-cb61-4694-8014-bbfff1b0e753">

- Twitter ads were the most effective in converting to product purchases, followed by Bulkmail, Instagram, Facebook and Brochure across all countires.

- Among all marital groups, married customers were the most influenced by advertisements to puchase products.

<img width="995" alt="Screenshot 2024-01-22 at 10 14 38" src="https://github.com/Chloenjuguna/2Market-/assets/143361757/21c3d923-73c5-4fd4-a45d-3ce0bb421ae8">

### Data Visualisation (Tableau)
I designed a comprehensive workbook for 2Market's marketing and advertising data, featuring three distinct dashboards dedicated to demographics, sales, and advertising. The demographics dashboard offers insights into customer profiles, allowing for a deeper understanding of the target audience. The sales dashboard provides a detailed analysis of product purchases, enabling quick assessments of product performance and market trends. The advertising dashboard evaluates the effectiveness of various channels, aiding in strategic decision-making for future campaigns. This structured approach facilitates a holistic view of 2Market's marketing landscape, empowering stakeholders with actionable insights to optimize customer engagement and maximise advertising impact. [Access Tableau Workbook here](https://public.tableau.com/app/profile/chloe.njuguna)

### Interpretation 
Spain hosts the majority of customers, totaling 1,093. On average, the customer base falls within the age range of 40s to 50s, with the largest segment of customers being married. Highest proportion of customers held a master's level education. The total amount spent on products is highest in spain, in contrast to Montenegro. Interestingly alcoholic beverages are the most purchased product by a great margin followed by meat items and commodities across countries. Individuals with a master's education level, had a higher average income than any other education level, however graduates spent more on products by comparison. Similar the SQL ouput, married inidviduals spent the most on products. 
Customers made the most significant number of purchases through Twitter advertisements. When examining this ad category with respect to average income, marital status, and total products purchased, it becomes apparent that married individuals and those who were 'together' made more purchases through Twitter and Bulkmail advertisements. This is fascinating as it raises questions as to whether other modes
of advertisement e.g. brochures are being distributed as frequently as twitter ads. I would like to investigate whether the products available for purchase in one country are also available in another. It is crucial to address this, as the absence of certain products in specific countries could lead to a misinterpretation of purchasing insights. If some products included in the analysis are sold in certain countries but not in others, it may impact the accuracy of our conclusions.

### Recommendations 

1. Tailor marketing strategies to purchasing behaviour observed in each country. Consider the economic and cultural factors that influence purchasing behaviour.

2. Ensure to investigate the availability of products across different countries, so that future analysis considers products that are universally available.

3. Twitter advertisement have shown signficant impact, among other social media platforms so you may which to consider allocating more resources to digital advertising. You may also wish to investigate the distribution frequency of traditional advertising channels, to ensure a balanced approach.

4. There is a relationship between higher education and higher average income. Tailoring marketing messages and promotions to appeal to these groups, may help potentially increase their spending capacity. 

5. Leverage the understanding that married individuals, as well as those who are 'together,' are more responsive to Twitter and Bulkmail advertisements. Develop targeted campaigns and advertisements for these groups to help engage them further, as well as capture those who are generally less engaged. 

6. Capitalise on the popularity of particular products i.e., alcoholic beverages, meat items and commodities across countries by providing bundling deals and special promotions.


