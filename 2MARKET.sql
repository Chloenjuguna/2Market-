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
  "AmtLiq", 
  "AmtVege", 
  "AmtNonVeg", 
  "AmtPes", 
  "AmtChocolates", 
  "AmtComm"
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

