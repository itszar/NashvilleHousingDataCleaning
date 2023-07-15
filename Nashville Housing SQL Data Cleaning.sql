SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
      ,[SaleDateConverted]
  FROM [PortfolioProjectDataCleaning].[dbo].[NashvilleHousing]

  -- Standardize Sale Date 
  SELECT SaleDateConverted, CONVERT(DATE, SALEDATE) 
  FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing

  UPDATE NashvilleHousing
  SET SaleDate = CONVERT(DATE, SALEDATE)

  ALTER TABLE NASHVILLEHOUSING
  ADD SALEDATECONVERTED DATE;

  UPDATE NashvilleHousing
  SET SaleDateConverted = CONVERT(DATE, SALEDATE)
-------------------------------------------------------------------------------------------------------------------------
  -- POPULATE PROPERTY ADDRESS DATA
  
  SELECT *
  FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing
  
  SELECT *
  FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing
  --WHERE PropertyAddress IS NULL
  ORDER BY ParcelID

  SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress ISNULL(A.PROPERTYADDRESS, B.PROPERTYADDRESS)
  FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing A
  JOIN PortfolioProjectDataCleaning.DBO.NashvilleHousing B
  ON A.ParcelID = B.ParcelID 
  AND A.[UniqueID ] <> B.[UniqueID ]
  WHERE A.PropertyAddress IS NULL

  UPDATE A
  SET PROPERTYADDRESS = ISNULL(A.PROPERTYADDRESS, B.PROPERTYADDRESS)
  FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing A
  JOIN PortfolioProjectDataCleaning.DBO.NashvilleHousing B
  ON A.ParcelID = B.ParcelID 
  AND A.[UniqueID ] <> B.[UniqueID ]
  WHERE A.PropertyAddress IS NULL


-----------------------------------------------------------------------------------------------------
-- BREAKING ADDRS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
-- SPLITTING PROPERTY ADDRS

SELECT PROPERTYADDRESS
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing
ORDER BY PARCELID

SELECT
SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS) -1) AS ADDRESS
, SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1, LEN(PROPERTYADDRESS)) AS ADDRESS
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing

ALTER TABLE NASHVILLEHOUSING
ADD PROPERTYSPLITADDRESS NVARCHAR(255)

UPDATE NASHVILLEHOUSING
SET PROPERTYSPLITADDRESS = SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS) -1)

ALTER TABLE NASHVILLEHOUSING
ADD PROPERTYSPLITCITY NVARCHAR(255)

UPDATE NASHVILLEHOUSING
SET PROPERTYSPLITCITY = SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1, LEN(PROPERTYADDRESS))

SELECT *
FROM  PortfolioProjectDataCleaning.DBO.NashvilleHousing
----------------------------------------------------------------------------------------------------------------
-- SPLITTING OWNER ADDRS

SELECT OwnerAddress
FROM  PortfolioProjectDataCleaning.DBO.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing

ALTER TABLE NASHVILLEHOUSING
ADD OwnerSplitAddress NVARCHAR (255)

UPDATE NASHVILLEHOUSING
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NASHVILLEHOUSING
ADD OwnerSplitCity NVARCHAR (255)

UPDATE NASHVILLEHOUSING
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NASHVILLEHOUSING
ADD OwnerSplitState NVARCHAR (255)

UPDATE NASHVILLEHOUSING
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing
 
 --------------------------------------------------------------------------------------
 -- Converting "Y" and "N" to "Yes" and "No" in "Sold as Vacant Field"

SELECT SOLDASVACANT
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing
GROUP BY SOLDASVACANT
ORDER BY 2


SELECT SOLDASVACANT
, CASE WHEN SOLDASVACANT = 'Y' THEN 'YES'
       WHEN SOLDASVACANT = 'N' THEN 'NO'
	   ELSE SOLDASVACANT
	   END
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing


UPDATE NASHVILLEHOUSING
SET SOLDASVACANT = CASE WHEN SOLDASVACANT = 'Y' THEN 'YES'
       WHEN SOLDASVACANT = 'N' THEN 'NO'
	   ELSE SOLDASVACANT
	   END
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing

SELECT SOLDASVACANT
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing

--------------------------------------------------------------------------------------
-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY PARCELID,
               PROPERTYADDRESS,
               SALEPRICE,
               SALEDATE,
               LEGALREFERENCE
               ORDER BY 
                  UNIQUEID
                  ) ROW_NUM 

FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1 
ORDER BY PROPERTYADDRESS 

----------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProjectDataCleaning.DBO.NashvilleHousing


ALTER TABLE PortfolioProjectDataCleaning.DBO.NashvilleHousing
DROP COLUMN OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS


ALTER TABLE PortfolioProjectDataCleaning.DBO.NashvilleHousing
DROP COLUMN SALEDATE

