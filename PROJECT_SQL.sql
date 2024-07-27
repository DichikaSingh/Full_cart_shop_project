--1 create database
CREATE DATABASE FullCartStoreProject;

--2 active database
USE FullCartStoreProject;

--3 create table 
IF NOT EXISTS (select * from sys.tables where name = 'FullCartStoreProject')
begin
     Create table full_cart_store_data(
        [index] int primary key,
        [Order ID] int not null,
        [Cust ID] int,
        Gender varchar(25),
        Age int,
        [Date] date,
        [Status] varchar(100),
        Channel varchar(50),
        SKU varchar(max),
        Category varchar(max),
        Size varchar(20),
        Qty int,
        currency varchar(25),
        Amount int,
        [ship-city] varchar(max),
        [ship-country] varchar(25),
        B2B Varchar(25));
END;

--4 import data in bulk
BULK INSERT [dbo].[full_cart_store_data$]
FROM "C:\Users\hp\OneDrive\Desktop\full_cart_store_data.csv"
WITH(
    FIELDTERMINATOR=',',
	ROWTERMINATOR='\n',
	FIRSTROW=2)

--5 To Rename column name 
EXEC sp_rename '[dbo].[full_cart_store_data$].Index', 'S.No';

--6 to change datatype of column
ALTER TABLE [dbo].[full_cart_store_data$]
ALTER COLUMN [Index] int;

-- Check null value presence 
Select * from [dbo].[full_cart_store_data$]
where [S.No] IS NULL;

--allow not null in filed then we can add primary key to column
alter table [dbo].[full_cart_store_data$]
alter column [S.No] int not null;

--7 to add primary key in index field
ALTER TABLE [dbo].[full_cart_store_data$]
ADD CONSTRAINT PK_SNo primary key ([S.No])

--to retrive table data
select * from [dbo].[full_cart_store_data$]

--to delete all the data from table remaining only structure of tble
--truncate table [dbo].[full_cart_store_data$] 


--------------------------------------------------------------Now time of Analyz the data-------------------------------------------------------------

--1 How many orders placed?
select count(OrderID)  as [Total order placed by customer] from [dbo].[full_cart_store_data$] ;

--2 How many order placed by each channel?
select Channel, count(OrderID) as [No. of orders] from [dbo].[full_cart_store_data$]
GROUP BY Channel
order by count(OrderID) desc;

--3 Channel Name with the Highest number of orders?
SELECT Top 1 Channel as [Channel with the Highest number of orders], count(OrderID) as [No. of orders] from [dbo].[full_cart_store_data$]
GROUP BY Channel
ORDER BY count(OrderID)desc;

--4 Channel Name with the Lowest number of orders?
SELECT TOP 1 Channel as[Channel with The lowest Number of orders], Count(*) as [No. of orders] from [dbo].[full_cart_store_data$]
GROUP BY Channel
ORDER BY Count(*);

--5 Identify the channels with the First, second, third, fourth, and subsequent highest number of orders.

WITH ChannelOrderCounts AS (
    SELECT
        Channel,
        COUNT(*) AS OrderCount,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
    FROM
    [dbo].[full_cart_store_data$]   
    GROUP BY
        Channel
)
SELECT Channel, OrderCount
FROM ChannelOrderCounts
WHERE [Rank] = 2;

--6 Identify the channels with the First, second, third, fourth, and subsequent Lowest number of orders.
With Orders_count AS(
       Select 
			Channel,
			Count(*) as Toatl_OrdersNo,
			ROW_NUMBER()over(order by count(*)) as [Rank]
	   From [dbo].[full_cart_store_data$]
	   Group by Channel
)
select Channel, Toatl_OrdersNo
from Orders_count
where [Rank] = 1

--7 Show top3 channels with details?
WITH Show_top3_channel AS
(
  Select 
  Channel, 
  Count(*) AS total_orders_by_channel,
  ROW_NUMBER()OVER(order by  Count(*) desc) AS Row_num
  from  [dbo].[full_cart_store_data$]
  group by Channel
)
SELECT channel, total_orders_by_channel
from Show_top3_channel 
where  Row_num <4

--8 Show Bottom3 channels with details?
WITH Bottom3_sales_by_channel AS
(
 Select Channel,
 COUNT(*) AS Total_sales_by_channel,
 ROW_NUMBER()over(order by COUNT(*)) AS Rown_num
 from  [dbo].[full_cart_store_data$]
 Group by Channel
)
Select Channel,
Total_sales_by_channel
from Bottom3_sales_by_channel
where Rown_num < 4;


--9 How many total orders has each customer placed?
Select CustID,
COUNT(*) As No_of_orders_placedby_customer
from [dbo].[full_cart_store_data$]
GROUP BY CustID
ORDER BY COUNT(*) desc;

--10 which customers made 10 orders or above?
SELECT CustID,
Count(*) AS [Orders placed by customer]
from  [dbo].[full_cart_store_data$]
GROUP BY CustID
Having Count(*) > 10
order by Count(*) desc;

--11 2.What is the total amount spent by each customer?
Select CustID,
Sum(Amount) AS [Toatl amount by Customer on all orders]
from [dbo].[full_cart_store_data$]
Order by Sum(Amount) desc;

--12 What is the average order value for each customer?
Select CustID,
AVG(Amount) AS [Avg order by Customer]
From [dbo].[full_cart_store_data$]
Group by CustID
Order by AVG(Amount) desc;

--13 What are the total sales by category?
Select Category,
SUM(Amount) as [Total sales by Category]
from [dbo].[full_cart_store_data$]
Group by Category
Order by SUM(Amount) desc;

--14 How many units of each SKU have been sold?
Select SKU, 
Count(Qty) as [Total Qty sold by SKU]
from [dbo].[full_cart_store_data$]
Group by SKU
order by Count(Qty) desc;

--15 Which Category most order by customer?
Select Category, 
Count(Qty) AS [Total Qty by Category]
from [dbo].[full_cart_store_data$]
Group by Category
Order by Count(Qty) Desc;

--16 Identify the Category with the First, second, third, fourth, and subsequent highest number of Qty.
WITH Category_from_top AS
(
  Select Category,
  Count(Qty) AS [Qty Sold by Category],
  ROW_NUMBER() over(order by Count(Qty) Desc) AS Row_num
  from [dbo].[full_cart_store_data$]
  Group by Category
)
Select Category,
[Qty Sold by Category]
from Category_from_top
Where Row_num <3;

--17 Identify the Category with the First, second, third, fourth, and subsequent Lowest number of Qty.
With Category_From_bottom_by_Qty AS
(
 select Category,
 count(Qty) as [Qty Sold by Category],
 ROW_NUMBER() over(order by count(Qty))AS Row_num
 from [dbo].[full_cart_store_data$]
 Group by Category
)
Select Category,
[Qty Sold by Category]
from Category_From_bottom_by_Qty
where Row_num<3

--18 What is the total revenue generated by each sales channel?
Select Channel,
SUM(Amount) AS [Total Revenue By Category]
from [dbo].[full_cart_store_data$]
Group by Channel
Order by SUM(Amount) desc;

--19 How many total orders have been placed from each city?
Select [Ship-city],
Count(OrderID) AS [TOtal Orders Placed]
from [dbo].[full_cart_store_data$]
Group by [Ship-city]
Order by Count(OrderID) desc;

--20 What is the total revenue generated from each country?
Select [Ship-country],
SUM(Amount) AS [Total Revenue Generated]
From [dbo].[full_cart_store_data$] 
Group by [Ship-country];

---So there are sum unwanted data in ship-country field so lets remove unwanted value from Country column 
--(And the result is there are only one country in ship-country field that is IN.)--

BEGIN TRANSACTION --(For rollback purpose if needed)
Delete From [dbo].[full_cart_store_data$]
Where [Ship-country] not in ('IN');
--Now check
select * From [dbo].[full_cart_store_data$]; 

--21 What is the average quantity ordered per category?
 Select 
 Category,
 AVG(Qty) AS [Average Qty by Category]
 from [dbo].[full_cart_store_data$]
 GROUP BY Category;
  
--22 Which are the top-selling product Category?
WITH Category_top_selling AS
(
  SELECT 
    Category,
    SUM(Amount) AS TotalAmount,
    ROW_NUMBER() OVER(ORDER BY SUM(Amount) DESC) AS Row_num
  FROM [dbo].[full_cart_store_data$]
  GROUP BY Category
)
SELECT Category
FROM Category_top_selling 
WHERE Row_num = 1;

--23 Find the Average Age of Customers?
Select CustID,
AVG(Age) AS [Average age of customer]
from [dbo].[full_cart_store_data$]
Group by CustID;

--24 Find the Average Age of Customers by gender?
Select Gender,
AVG(Age) AS [Average age of customer by gender]
From [dbo].[full_cart_store_data$]
Group by Gender;

---------Change Men And M to Man in gender field?------30873
Select * from [dbo].[full_cart_store_data$];

UPDATE [dbo].[full_cart_store_data$]
SET Gender = 'Man'
Where Gender in ('M','Men');

--25 Retrieve Orders with a Specific Size.
Select Size,
Count(*) AS [Total orders by size]
from [dbo].[full_cart_store_data$]
Group by Size
order by Count(*) desc;

--26 Count Orders with a Quantity Greater Than 10.
Select OrderID,
Count(*) AS [Order Volumn]
from [dbo].[full_cart_store_data$]
Group by OrderID
having Count(*) >10
Order by Count(*) desc;

--27 Calculate Total Revenue in a Specific Currency.
Select Currency,
SUM(Amount) AS [Total Revenue]
from [dbo].[full_cart_store_data$]
Group by Currency
order by SUM(Amount) desc;

--28 Find Orders Marked as B2B.
Select * from [dbo].[full_cart_store_data$]
where B2B  in('True','TRUE')

--29 Find Orders not Marked as B2B.
Select * from [dbo].[full_cart_store_data$]
where B2B = 'FALSE' or B2B = 'False'

--30 Order volume by Year.
Select YEAR([Date]) AS [Year],
Count(*) AS [Order Volume]
From [dbo].[full_cart_store_data$]
Group by YEAR([Date])
order by Count(*) desc; --Means there are only 2022 records


--31 Revenue Generated by Year.
Select YEAR([Date]) AS [Year],
Sum(Amount) AS [Revenue]
From [dbo].[full_cart_store_data$]
Group by Year([Date])
order by sum(Amount) Desc;

--32 Find the Most Common Category.
Select Top 1 Category from
(
  Select Category,
  Count(*) AS [Order Volume]
  FROM [dbo].[full_cart_store_data$]
  GROUP BY Category
) AS subquery_alias
Order by [Order Volume] Desc;

---with max
Select Category From
(
 Select Category,
 Count(*) As [Order volume]
 from [dbo].[full_cart_store_data$]
 Group by Category
) AS Subquery_alias
  where [Order volume] = (Select MAX([Order volume])
  From (
		  Select Category,
		  Count(*) As [Order volume]
		  From [dbo].[full_cart_store_data$]
		  Group by Category
	    ) AS Max_subquery
                           );


--33 Find the Most not popular Category.
------with TOP function
Select TOP 1 Category From
(
  Select Category,
  Count(*) AS [Order Volume]
  From [dbo].[full_cart_store_data$]
  Group by Category 
) AS Sub_query_alias
Order by [Order Volume];

-----with Max Function
Select Category From
(
 Select Category,
 Count(*) As [Order Volume]
 From [dbo].[full_cart_store_data$]
 Group by Category
) AS Sub_query_alias
where [Order Volume] = (Select MIN([Order Volume]) 
                        From
						(
						  Select Category,
						  Count(*) AS [Order Volume]
						  from [dbo].[full_cart_store_data$]
						  Group by Category
                        ) AS Min_subquery
						);

--34 Calculate the Average Amount for Orders with a Specific Status.
 Select * from [dbo].[full_cart_store_data$]
Select [Status],
Avg(Amount) AS [Avg amount]
From [dbo].[full_cart_store_data$]
Group by [Status]
Order by Avg(Amount) desc;

--35 Calculate Amount by Status.
Select [Status],
SUM(Amount) AS [Amount]
From [dbo].[full_cart_store_data$]
Group by [Status]
order by SUM(Amount) desc;

--36 Calculate total orders by status.
Select [Status],
Count(*) as [Orders]
From [dbo].[full_cart_store_data$]
Group by [status]
order by count(*) desc;

--37 Calculate average orders by status.
Select [Status],
AVG(Qty) AS [Average order]
from [dbo].[full_cart_store_data$]
Group by [Status]
order by AVG(Qty) desc;

--38 List Orders Placed by Customers Aged 30 or Older.
Select *
From [dbo].[full_cart_store_data$]
where Age>=30;

--39 List Orders Placed by Customers Aged 30 or below.
Select * 
from [dbo].[full_cart_store_data$]
where Age<=30

--40 Count Orders with a Quantity Less Than 5.
Select Count(*) AS [Order Volume which Qty less than 5]from(
 Select [OrderID],
Count([OrderID]) As [Order Volume]
From [dbo].[full_cart_store_data$]
Group by [OrderID]
Having Count(*)<5
) AS Sub_query;

--41 Get the SKU with the Lowest Quantity Sold.
Select SKU, [Total Qty]
From 
(
  Select SKU,
  Count(Qty) AS [Total Qty]
  From [dbo].[full_cart_store_data$]
  Group by SKU
) AS sub_query_alias
Where [Total Qty] = (Select MIN([Total Qty])
From
(
  Select SKU,
  Count(Qty) as [Total Qty]
  from [dbo].[full_cart_store_data$]
  Group by SKU) As sub_query_alias2);

--42 Get the SKU with the Highest Average Amount Sold.
With Top_highest_avg_SKU AS(
  Select SKU,
  Avg(Amount) as [Aerage amount],
  ROW_NUMBER() over(order by Avg(Amount)desc ) as row_num
  From [dbo].[full_cart_store_data$]
  Group by SKU
)
select SKU, 
[Aerage amount]
From Top_highest_avg_SKU
where row_num = 1

--43 Get the SKU with the lowest Average Amount Sold.
With bottom_SKU_lowest_Avg AS (
  Select SKU,
  Avg(Amount) as [Average Amount],
  ROW_NUMBER() over(order by Avg(Amount)) as row_num
  from [dbo].[full_cart_store_data$]
  Group by SKU
)
Select SKU,
[Average Amount]
from bottom_SKU_lowest_Avg
where row_num = 1

--45 Calculate Total Revenue for Each Channel and Size.
Select Channel,Size,
SUM(Amount) As [Total Sales]
from [dbo].[full_cart_store_data$]
Group by Channel,Size
Order by Channel, Size desc;

--46 Find Orders Shipped to a Specific City and Channel.
Select Channel, [Ship-city],
SUM(Amount) AS [Total sales]
from [dbo].[full_cart_store_data$]
Group by Channel,[Ship-city]
Order by Channel,[Ship-city];

--47 Remove the " from value in ship-city column.
 UPDATE [dbo].[full_cart_store_data$]
 SET [Ship-city] = SUBSTRING([Ship-city], 2, LEN([Ship-city])-1) --substring is a function which extract char  from string
 Where LEFT([Ship-city], 1) = '"';

 --48 List Orders from a Specific Channel and B2B Status.
 Select Channel, B2B,
 count(*) as [Order Volume]
 from [dbo].[full_cart_store_data$]
 group by Channel, B2B
 order by Channel, count(*) desc;

 --49 Extract all character except TRUE and False from value of B2B column.
 UPDATE [dbo].[full_cart_store_data$]
 SET B2B = CASE
          When PATINDEX( '%true%', Lower(B2B)) > 0 then 'True'
		  When PATINDEX('%false%', lower(B2B)) > 0 then 'False'
		  Else null
END;

--50 Change null value to False in B2B field.
Update [dbo].[full_cart_store_data$]
Set B2B = 'False'
Where B2B is null;

select * from [dbo].[full_cart_store_data$]

--51 Count Orders with an Amount Above Than 500 INR.
 Select Count(*) As [Order with Above 500INR Amount] from(
  Select 
  Amount
  From [dbo].[full_cart_store_data$]
  Where Amount > 500
) As Sub_query_alias;

--52 Count Orders with an Amount below Than 500 INR.
 Select Count(*) As[Orders with below 500INR Amount] from
 (
  Select
  Amount
  From [dbo].[full_cart_store_data$]
  Where Amount < 500
 ) AS sub_query_alias; 

 --53 Find Orders with a Specific Category and Currency.
 Select Currency, Category,
 Count(*) AS [Order Volume]
 from [dbo].[full_cart_store_data$]
 Group by Currency, Category
 Order by Category , Count(*) desc;

--54 Calculate the Total Amount for Each Size.
Select Size,
SUM(Amount) as [Amount]
from  [dbo].[full_cart_store_data$]
Group by Size
order by Size, SUM(Amount) desc; 

--55 Change value of Size where XXL into 2XL.
UPDATE [dbo].[full_cart_store_data$]
SET Size = '2XL'
Where Size = 'XXL';

--56 Retrieve Orders Placed in the Last 7 Days.
Select Count(*) as [Order volum] from
(
 Select OrderID
 from [dbo].[full_cart_store_data$]
 Where [Date] = DATEADD(day, -7, getdate())
) As sub_query_alias;

--57 List Orders with a Specific Status and Currency.
Select Currency,
[Status],
Count(*) as [Order Volume]
From [dbo].[full_cart_store_data$]
group by Currency, [Status]
order by Count(*) desc;

--58 List Orders Placed on a Specific Date.
Select CONVERT(date, [Date]) as [Date],
COUNT(*) as [Order Volume]
from [dbo].[full_cart_store_data$]
Group by CONVERT(date, [Date])
Order by Count(*) desc;

--59 Retrive all records with date formate in order_date field.
  Select  [S.No], OrderID, CustID, Gender, Age, CONVERT(date, [Date]) AS [Date],
  [Status], Channel, SKU, Category, Size, Qty, Currency, Amount, [Ship-city], [Ship-country],B2B
  From [dbo].[full_cart_store_data$]

--60 Ranking Rows Based on Order Amount.
Select *,
Rank() over(order by Amount desc) As [Ranking by Order Amount]
from [dbo].[full_cart_store_data$]; 

--61 Retrieve the Latest Order for Each Customer.
With Lastest_order_by_cust AS
(
 Select CustID, OrderID, Amount, [Date],
 ROW_NUMBER() over(Partition by CustID order by [Date]) AS row_num
 from [dbo].[full_cart_store_data$]
)
Select CustID, OrderID, Amount, Convert(date, [Date]) as [Date]
From Lastest_order_by_cust
Where row_num = 1;

select * from [dbo].[full_cart_store_data$]

--62 Create Another table for column CustId, Gender, Age.
Create Table Customer_detail
(
 CustID Float,
 Age float,
 Gender nvarchar(255)
);

--63 Insert data from that table column to this new table column.
Insert into Customer_detail(CustID, Age, Gender)
Select DISTINCT CustID, Age, Gender
from [dbo].[full_cart_store_data$]
WHERE CustID NOT IN (SELECT CustID FROM Customer_detail);

--64 delete this colums from order table (age, gender).
Alter table [dbo].[full_cart_store_data$]
Drop column Age, Gender;








z
 













                      










  











 
























