--Viewing all data
SELECT *
FROM NashvilleHousing..SalesData

--Making sure Data Types of all columns are correct
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesData'

--SaleDate column has datetime values where time value for all rows is 00:00:00.000 
--So, adding a new column to only have date
ALTER TABLE SalesData
ADD CleanSalesDate Date


UPDATE NashvilleHousing..SalesData
SET CleanSalesDate = CAST(SaleDate AS Date)

--Making sure the date values are cleaned properly
SELECT UniqueID, SaleDate, CleanSalesDate, OwnerName
FROM SalesData

/*
Some rows have PropertyAddress as NULL. We have ParcelID for each row which is an 
unique number assigned to each parcel of land by the local Government body for tax
purposes. 
*/
Select *
From NashvilleHousing..SalesData
ORDER BY ParcelID


/*
From the previous query, we observe that properties sharing the same parcelID also share the same PropertyAddress. So, we can replace the NULL values in PropertyAddress with those from other rows sharing the same ParcelID
*/
--Checking if the address will be updated correctly
SELECT t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress, t2.PropertyAddress) AS UpdatedAddress
FROM NashvilleHousing..SalesData AS t1
JOIN NashvilleHousing..SalesData AS t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.UniqueID
WHERE t1.PropertyAddress IS NULL


--Adding a column CleanPropertyAddress to store address values
ALTER TABLE NashvilleHousing..SalesData
ADD CleanPropertyAddress nvarchar(255) 


--Adding the PropertyAddress of rows containing NULL values
UPDATE t1
SET CleanPropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM NashvilleHousing..SalesData AS t1
JOIN NashvilleHousing..SalesData AS t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.UniqueID
WHERE t1.PropertyAddress IS NULL

--Incorporating Non-NULL values of PropertyAddress to CleanPropertyAddress
UPDATE t1
SET CleanPropertyAddress = ISNULL(t1.PropertyAddress, t1.CleanPropertyAddress)
FROM NashvilleHousing..SalesData AS t1

--Ensuring if NULL values are updated correctly
SELECT *
FROM NashvilleHousing..SalesData
WHERE PropertyAddress is NULL

--Dropping SaleDate and PropertyAddress columns since we now have clean values in 
--separate columns
ALTER TABLE NashvilleHousing..SalesData
DROP COLUMN IF EXISTS SaleDate, PropertyAddress


--Breaking PropertyAddress into Address and City 
SELECT CleanPropertyAddress, 
	SUBSTRING(CleanPropertyAddress, 1, CHARINDEX(',', CleanPropertyAddress) - 1) AS Address,
	SUBSTRING(CleanPropertyAddress, CHARINDEX(',', CleanPropertyAddress) + 1, LEN(CleanPropertyAddress)) AS City
FROM NashvilleHousing..SalesData;


--Adding the new PropertyAddress and PropertyCity columns
ALTER TABLE NashvilleHousing..SalesData
ADD PropertyAddress nvarchar(100) , PropertyCity nvarchar(50)


--Assigning values to PropertyAddress and PropertyCity columns
UPDATE NashvilleHousing..SalesData
SET PropertyAddress = SUBSTRING(CleanPropertyAddress, 1, CHARINDEX(',', CleanPropertyAddress) - 1) ,
PropertyCity  = SUBSTRING(CleanPropertyAddress, CHARINDEX(',', CleanPropertyAddress) + 1, LEN(CleanPropertyAddress))


/*
OwnerAddress column also has many NULL values. But on observation, we see that OwnerAddress has the same value as PropertyAddress with characters "TN" (meaning Tennessee state) at the end of PropertyAddress value. So, we can simply take PropertyAddress values and add "TN" to them.
*/

ALTER TABLE NashvilleHousing..SalesData
ADD CleanOwnerAddress nvarchar(255) 


UPDATE NashvilleHousing..SalesData
SET CleanOwnerAddress = ISNULL(OwnerAddress, CleanPropertyAddress + ', TN') 


--Ensuring that the values are updated correctly
SELECT *
FROM NashvilleHousing..SalesData
WHERE OwnerAddress IS NULL

--Dropping the original columns
ALTER TABLE NashvilleHousing..SalesData
DROP COLUMN IF EXISTS CleanPropertyAddress, OwnerAddress

/*
Separating CleanOwnerAddress into Address, City and State.
PARSENAME is used to get specified parts of SQL object names. 
SQL object names are in the form Server_Name.Database_Name.Schema_Name.Table_Name.
If the string values are separated by periods(.), PARSENAME can be used to split the string.
In our OwnerAddress column, we have comma as the separator. So, we can replace comma with a period and then use PARSENAME function.
*/

SELECT CleanOwnerAddress, PARSENAME(REPLACE(CleanOwnerAddress,',','.'),3) AS Address,
	PARSENAME(REPLACE(CleanOwnerAddress,',','.'),2) AS City,
	PARSENAME(REPLACE(CleanOwnerAddress,',','.'),1) AS State
FROM NashvilleHousing..SalesData


ALTER TABLE NashvilleHousing..SalesData
ADD OwnerAddress nvarchar(100) , OwnerCity nvarchar(50), OwnerState nvarchar(10)


UPDATE NashvilleHousing..SalesData
SET OwnerAddress = PARSENAME(REPLACE(CleanOwnerAddress,',','.'),3),
	OwnerCity = PARSENAME(REPLACE(CleanOwnerAddress,',','.'),2),
	OwnerState = PARSENAME(REPLACE(CleanOwnerAddress,',','.'),1)


--The column SoldAsVacant has values 'Yes', 'No', 'Y', 'N'. 
--Calculating the number of rows for each unique SoldAsVacant value
Select Distinct(SoldAsVacant), Count(SoldAsVacant) TotalRows
From NashvilleHousing..SalesData
Group by SoldAsVacant
order by TotalRows

--We can update 'Y' and 'N' as 'Yes' and 'No'
--Ensuring that values will be updated correctly
SELECT SoldAsVacant,
CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN  SoldAsVacant = 'N' THEN 'No'
	 ELSE  SoldAsVacant
END AS Updated_values
FROM NashvilleHousing..SalesData
WHERE SoldAsVacant <> 'Yes' AND SoldAsVacant <> 'No'

UPDATE NashvilleHousing..SalesData
SET SoldAsVacant = CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
						WHEN  SoldAsVacant = 'N' THEN 'No'
						ELSE  SoldAsVacant
						END


/* 
Checking for Duplicate Rows.
A Row can be said to be dupllicate if the values in columns ParcelID, SalePrice, SaleDate, Address and LegalReference are all same.
*/
SELECT ParcelID, SalePrice, CleanSalesDate, PropertyAddress, 
	LegalReference, COUNT(*) AS Row_Count
FROM NashvilleHousing..SalesData
GROUP BY ParcelID, SalePrice, CleanSalesDate, PropertyAddress, LegalReference
HAVING COUNT(*) > 1

--On observation, there are 104 duplicate rows. These rows need to be removed.
WITH ROWNUMBER AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, SalePrice, CleanSalesDate, PropertyAddress, LegalReference ORDER BY ParcelID) AS RowNum
	FROM NashvilleHousing..SalesData
	)

DELETE
FROM ROWNUMBER
WHERE RowNum >1


--Storing data in a View for visualization
CREATE OR ALTER VIEW Nashville_Housing_Sales AS 
SELECT UniqueID, ParcelID, SalePrice, SoldAsVacant, CleanSalesDate AS SaleDate, PropertyAddress, PropertyCity
FROM NashvilleHousing..SalesData
