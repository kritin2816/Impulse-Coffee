
--GROUP BY, HAVING AND AGGREGATE FUNCTIONS

-- Query 1:

-- Business Goal: To understand the coffee preferences of customers who have a preference for any flavor, aiding in personalized marketing strategies, inventory management, and product recommendations.
-- English Query: Retrieve the types of coffee purchased by customers who prefer vanilla flavor.

SET PAGESIZE 700
SET LINESIZE 250
COL TYPE FORMAT A20
COL name FORMAT A20
SELECT 
    CT.TYPE, 
    C.NAME
FROM 
    S24_S003_T14_CUSTOMER C
JOIN 
    S24_S003_T14_CUSTOMER_TRANSACTION CTR ON C.CUST_ID = CTR.CUSTOMER_ID
JOIN 
    S24_S003_T14_COFFEE CO ON CTR.TRANSACTION_D = CO.NAME
JOIN 
    S24_S003_T14_COFFEE_TYPE CT ON CO.COFFEE_ID = CT.COFFEE_ID
WHERE 
    C.PREFERRED_FLAVOR = 'Vanilla'
GROUP BY 
    CT.TYPE, C.NAME
HAVING 
    COUNT(*) > 0;


-- Query 2:

-- Business Goal: The analysis of the top-selling coffee types and their distribution across different customer cities can help the business identify new geographic markets with high demand for its popular coffee products. This information can guide the company's expansion strategy, allowing it to open new retail locations or distribution channels in these high-potential areas.
-- English Query: What are the top 3 best-selling coffee types, and how are they distributed across different customer cities?

SET PAGESIZE 700
SET LINESIZE 250
COL NAME FORMAT A30
COL city FORMAT A20
COL MAX_CITY FORMAT A20
COLUMN MAX_CITY FORMAT 99999
SELECT 
    C.NAME, 
    CU.CITY, 
    COUNT(CU.CITY) AS MAX_CITY
FROM 
    S24_S003_T14_COFFEE_TYPE CT
JOIN 
    S24_S003_T14_COFFEE C ON CT.COFFEE_ID = C.COFFEE_ID
JOIN 
    S24_S003_T14_CUSTOMER_TRANSACTION CTR ON C.NAME = CTR.TRANSACTION_D
JOIN 
    S24_S003_T14_CUSTOMER CU ON CTR.CUSTOMER_ID = CU.CUST_ID
GROUP BY 
    C.NAME, CU.CITY
ORDER BY 
    MAX_CITY DESC 
FETCH FIRST 3 ROWS ONLY;



-- Query 3:

-- Business Goal: To identify the top-selling coffee based on transaction count, aiding in  marketing strategies, and understanding customer preferences.
-- English Query: Retrieve the count of transactions for each coffee type, displaying only the top 3 coffee types based on transaction count.

SET PAGESIZE 700
SET LINESIZE 250
COL TRANSACTION_D FORMAT A35
COL PURCHASE_COUNT FORMAT A30
COLUMN PURCHASE_COUNT FORMAT 99999
SELECT 
    CTR.TRANSACTION_D, 
    COUNT(*) AS PURCHASE_COUNT
FROM 
    S24_S003_T14_CUSTOMER_TRANSACTION ctr
JOIN 
    S24_S003_T14_COFFEE c ON ctr.TRANSACTION_D = c.NAME
JOIN 
    S24_S003_T14_COFFEE_TYPE ct ON c.COFFEE_ID = ct.COFFEE_ID
GROUP BY 
    ctr.TRANSACTION_D
ORDER BY 
    PURCHASE_COUNT DESC
FETCH FIRST 3 ROWS ONLY;


-- Query 4:

-- Business Goal: To identify the most popular mode of payment among customers and understand individual customer preferences, facilitating efficient payment processing to enhance for promotions by targeting specific payment methods.
-- English Query: Retrieve the customer name and their preferred mode of payment, focusing on the most commonly used mode of payment.

SET PAGESIZE 700
SET LINESIZE 250
COL CUSTOMER_NAME FORMAT A35
COL PREFERRED_MODE_OF_PAYMENT FORMAT A30
SELECT
    C.NAME AS CUSTOMER_NAME,
    CMP.MODE_OF_PAYMENT AS PREFERRED_MODE_OF_PAYMENT
FROM
    S24_S003_T14_CUSTOMER C
JOIN
    S24_S003_T14_CUSTOMER_MODEOFPAYMENT CMP ON C.CUST_ID = CMP.CUSTOMER_ID
JOIN (
    SELECT
        MODE_OF_PAYMENT,
        COUNT(*) AS payment_count
    FROM
        S24_S003_T14_CUSTOMER_MODEOFPAYMENT
    GROUP BY
        MODE_OF_PAYMENT
    ORDER BY
        COUNT(*) DESC
        FETCH FIRST 1 ROW ONLY
) PC ON CMP.MODE_OF_PAYMENT = PC.MODE_OF_PAYMENT;


  
-------------------------------------------------------------------------------------


--DIVISION QUERY


-- Query 5:

-- Business goal: To identify customers who exclusively purchase dark roasted coffee, due to its premium pricing his analysis also allows for cost-cutting measures in the coffee shop if fewer customers are inclined towards this particular product.                                                                                                 
-- English Query: Retrieve the customer ID and name of customers who have made purchases of dark roasted coffee only.

SET PAGESIZE 700
SET LINESIZE 250
COL CUST_ID FORMAT A30
COL NAME FORMAT A30
COLUMN CUST_ID FORMAT 99999
SELECT 
    C.CUST_ID,
    C.NAME
FROM 
    S24_S003_T14_CUSTOMER C 
JOIN 
    S24_S003_T14_PURCHASE P ON C.CUST_ID = P.CUST_ID
WHERE 
    P.COFFEE_ID IN (
        SELECT 
            CO.COFFEE_ID
        FROM 
            S24_S003_T14_COFFEE CO
        MINUS
        SELECT 
            CO.COFFEE_ID
        FROM 
            S24_S003_T14_COFFEE CO 
        JOIN 
            S24_S003_T14_COFFEE_TYPE CT ON CO.COFFEE_ID = CT.COFFEE_ID
        JOIN 
            S24_S003_T14_PURCHASE P ON CO.COFFEE_ID = P.COFFEE_ID
        WHERE 
            CT.TYPE = 'Mild roasted' AND C.CUST_ID = P.CUST_ID
    );



----------------------------------------------------------------------------------------------

--ROLL UP CLAUSE 


-- Query 6:

-- Business goal: Analyze customer purchasing behavior for each coffee type within specific timeframes to identify seasonal trends, quarterly performance, and the popularity of different coffee types over time. These insights empower businesses to make data-driven decisions, fostering overall business development and growth.             
-- English Query: Retrieve the count of unique customers who made purchases for each coffee type, categorized by year, quarter.

SET PAGESIZE 700
SET LINESIZE 250
COL PURCHASE_MONTH FORMAT A30
COL NUM_CUSTOMERS FORMAT A20
COLUMN NUM_CUSTOMERS FORMAT 99999
SELECT 
    TO_CHAR(TO_DATE(DATE_OF_PURCHASE, 'DD-MON-RR'), 'MON-RR') AS PURCHASE_MONTH,
    COUNT(DISTINCT CDP.CUSTOMER_ID) AS NUM_CUSTOMERS
FROM 
    S24_S003_T14_CUSTOMER_DATEOFPURCHASE CDP 
JOIN 
    S24_S003_T14_CUSTOMER_TRANSACTION CTR ON CDP.CUSTOMER_ID = CTR.CUSTOMER_ID
JOIN 
    S24_S003_T14_COFFEE C ON C.NAME = CTR.TRANSACTION_D
JOIN 
    S24_S003_T14_PURCHASE P ON P.COFFEE_ID= C.COFFEE_ID
GROUP BY 
    ROLLUP(TO_CHAR(TO_DATE(DATE_OF_PURCHASE, 'DD-MON-RR'), 'MON-RR'))
ORDER BY 
    NUM_CUSTOMERS DESC;
    
    
    
-----------------------------------------------------------------------------------------

--CUBE CLAUSE

-- Query 7:

-- Business Goal: To obtain a comprehensive overview of total sales revenue for each coffee type, facilitating a thorough analysis of sales performance to inform decisions regarding pricing strategies.
-- English Query: Retrieve the total sales revenue for each coffee type, accounting for potential missing data, and include a summary row for the overall sales revenue.

SET PAGESIZE 700
SET LINESIZE 250
COL COFFEE_NAME FORMAT A35
COL TOTAL_SALES FORMAT A30
COL COFFEE_ID FORMAT A30
COLUMN TOTAL_SALES FORMAT 99999
COLUMN COFFEE_ID FORMAT 99999
SELECT 
    COALESCE(c.NAME, 'Grand Total') AS COFFEE_NAME, 
    SUM(fc.COFFEE_COST) AS TOTAL_SALES, 
    c.COFFEE_ID
FROM 
    S24_S003_T14_COFFEE c
FULL OUTER JOIN 
    S24_S003_T14_PURCHASE p ON c.COFFEE_ID = p.COFFEE_ID
FULL OUTER JOIN 
    S24_S003_T14_FINAL_COFFEE_COST fc ON p.COFFEE_ID = fc.COFFEE_ID
GROUP BY 
    CUBE(c.NAME,c.COFFEE_ID)
ORDER BY 
    COFFEE_NAME NULLS LAST;


------------------------------------------------------------------------------------------

--OVER CLAUSE


-- Query 8:

-- Business goal: To analyze the distribution of customers across different age groups and determine which age groups are the most frequent consumers of coffee. This information can be valuable for targeted marketing campaigns, product development, and understanding consumer behavior.                  
-- English Query: Identify the number of customers in different age groups and rank them based on their coffee consumption frequency.

SET PAGESIZE 700
SET LINESIZE 250
COL AGE_GROUP FORMAT A20
COL NUM_CUSTOMERS FORMAT A20
COL MOST_COFFEE_DRINKERS FORMAT A20
COLUMN NUM_CUSTOMERS FORMAT 99999
COLUMN MOST_COFFEE_DRINKERS FORMAT 99999
WITH CUST_AGE_GROUP AS (
  SELECT c.CUST_ID,
         c.NAME,
         TRUNC((SYSDATE - c.DOB) / 365.25, 0) AS age,
         CASE
           WHEN TRUNC((SYSDATE - c.DOB) / 365.25, 0) < 20 THEN '0-19'
           WHEN TRUNC((SYSDATE - c.DOB) / 365.25, 0) BETWEEN 20 AND 29 THEN '20-29'
           WHEN TRUNC((SYSDATE - c.DOB) / 365.25, 0) BETWEEN 30 AND 39 THEN '30-39'
           WHEN TRUNC((SYSDATE - c.DOB) / 365.25, 0) BETWEEN 40 AND 49 THEN '40-49'
           WHEN TRUNC((SYSDATE - c.DOB) / 365.25, 0) BETWEEN 50 AND 59 THEN '50-59'
           ELSE '60+'
         END AS AGE_GROUP
  FROM S24_S003_T14_CUSTOMER c 
)
SELECT AGE_GROUP,
       COUNT(*) AS NUM_CUSTOMERS,
       RANK() OVER (ORDER BY COUNT(*) desc) AS MOST_COFFEE_DRINKERS
FROM CUST_AGE_GROUP
JOIN S24_S003_T14_CUSTOMER_TRANSACTION ct ON CUST_AGE_GROUP.CUST_ID = ct.CUSTOMER_ID
GROUP BY AGE_GROUP
ORDER BY MOST_COFFEE_DRINKERS;






---------------------------------------------------------------------------------------


--LIKE OPERATOR

-- Query 9:

-- Business Goal: To identify preferred flavors among customers that do not correspond to any available coffee options. This information can guide product development decisions and help in expanding the coffee menu to better cater to customer preferences.
-- English Query: Retrieve the preferred flavors of customers that do not match any existing coffee names, sorted by the frequency of each preferred flavor.

SET PAGESIZE 700
SET LINESIZE 250
COL PREFERRED_FLAVOR FORMAT A30
SELECT sub.PREFERRED_FLAVOR
FROM (
    SELECT DISTINCT PREFERRED_FLAVOR
    FROM S24_S003_T14_CUSTOMER
) sub
WHERE NOT EXISTS (
    SELECT 1
    FROM S24_S003_T14_COFFEE c
    WHERE UPPER(c.NAME) LIKE '%' || UPPER(sub.PREFERRED_FLAVOR) || '%'
)
GROUP BY sub.PREFERRED_FLAVOR
ORDER BY COUNT(sub.PREFERRED_FLAVOR) DESC;


