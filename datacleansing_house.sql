select * 
from [dbo].[house]

/*

Cleaning Data in SQL Queries

*/
---------------------------------------------------------------------------------
--Standardize Data Format

SELECT SaleDate, convert(date, saledate) saledate
FROM [dbo].[house]

UPDATE [dbo].[house]
SET Saledate = convert(date, saledate);  ---didn't change

Alter table [dbo].[house]
ADD Solddate date;

UPDATE  [dbo].[house]
SET solddate = convert(date, saledate);



---------------------------------------------------------------------------------

--Populate Property Address data

SELECT propertyaddress
FROM [dbo].[house]
WHERE propertyaddress IS NULL;  --29 ROWS

SELECT A.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(A.propertyaddress, B.propertyaddress)
FROM [dbo].[house] A
JOIN [dbo].[house] B ON A.parcelid = b.parcelid and a.uniqueid <> b.uniqueid
WHERE A.propertyaddress IS NULL; 

UPDATE A
SET propertyaddress = ISNULL(A.propertyaddress, B.propertyaddress)
FROM [dbo].[house] A
JOIN [dbo].[house] B ON A.parcelid = b.parcelid and a.uniqueid <> b.uniqueid
WHERE A.propertyaddress IS NULL;


select
    parsename('server1.dbname1.dbo.table',1) as 'Object Name'

--------------------------------------------------------------------------------------------------------------
-- Breaking out Address into individual columns(Address, city, state)
SELECT SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) AS address
	,SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) AS CITY
FROM [dbo].[house];

ALTER TABLE [dbo].[house] 
ADD propertyaddress_new NVARCHAR(255);


ALTER TABLE [dbo].[house] 
ADD property_city NVARCHAR(255);

UPDATE [dbo].[house] 
SET propertyaddress_new = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) ;

UPDATE [dbo].[house] 
SET property_city = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1,LEN(propertyaddress));

SELECT PARSENAME(REPLACE(owneraddress, ',', '.'),3)
	, PARSENAME(REPLACE(owneraddress, ',', '.'),2)
	,PARSENAME(REPLACE(owneraddress, ',', '.'),1)
FROM [dbo].[house]

ALTER TABLE [dbo].[house] 
ADD	owneraddress_add nvarchar(255);

ALTER TABLE [dbo].[house] 
ADD	owneraddress_city nvarchar(255);

ALTER TABLE [dbo].[house] 
ADD	owneraddress_state nvarchar(255);

UPDATE [dbo].[house] 
SET owneraddress_add = PARSENAME(REPLACE(owneraddress, ',', '.'),3);

UPDATE [dbo].[house] 
SET owneraddress_city = PARSENAME(REPLACE(owneraddress, ',', '.'),2);

UPDATE [dbo].[house] 
SET owneraddress_state = PARSENAME(REPLACE(owneraddress, ',', '.'),1);

--change Y and N in 'sold as vacant' field

SELECT soldasvacant, count(soldasvacant)
FROM  [dbo].[house] 
group by soldasvacant

SELECT CASE WHEN soldasvacant = 'Y' THEN 'YES'
			WHEN soldasvacant = 'N' THEN 'NO'
			ELSE soldasvacant
		END
FROM [dbo].[house] 

UPDATE  [dbo].[house] 
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'YES'
						WHEN soldasvacant = 'N' THEN 'NO'
						ELSE soldasvacant
					END;

--RemoveDuplicate

WITH ROW_NUM_CTE AS (
SELECT * ,
		ROW_NUMBER() OVER ( PARTITION BY PARCELID
										, PROPERTYADDRESS
										, SALEDATE
										, SALEPRICE
										, LEGALREFERENCE 
							ORDER BY UNIQUEID) ROW_NUM
FROM [dbo].[house] )

DELETE 
FROM ROW_NUM_CTE
WHERE ROW_NUM >1;


--Delete Unused Columns

ALTER TABLE [dbo].[house]
DROP COLUMN owneraddress, TAXDISTRICT, PROPERTYADDRESS
