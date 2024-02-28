SELECT *
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing


--- Change 'SaleDate' Format and Column

SELECT 
	SaleDate,
	CONVERT(Date, SaleDate)AS SaleDateConverted
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



--- Populate Column 'PropertyAddress'

SELECT *
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing AS a
JOIN NashvilleHousingDataCleaning.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;



SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
CASE
	WHEN a.PropertyAddress IS NULL THEN b.PropertyAddress
	ELSE a.PropertyAddress
END
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing AS a
JOIN NashvilleHousingDataCleaning.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;



UPDATE a
SET PropertyAddress =
CASE
	WHEN a.PropertyAddress IS NULL THEN b.PropertyAddress
	ELSE a.PropertyAddress
END
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing AS a
JOIN NashvilleHousingDataCleaning.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


----- Breaking Out 'PropertyAddress' Column into 2 Columns (Address, City)

SELECT PropertyAddress
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS City
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Address VARCHAR(255),
	City VARCHAR(255);

UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1),
	City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))


----- Breaking Out 'OwnerAddress' Column into 1 Columns (State)
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD State VARCHAR(255);

UPDATE NashvilleHousing
SET State = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



--- Standarize 'SoldAsVcant' Column

SELECT DISTINCT SoldAsVacant, 
       COUNT(SoldAsVacant)
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant;


SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing


--- Remove Duplicates

SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) AS row_num
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing
ORDER BY ParcelID;




WITH row_numCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) AS row_num
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing
)
SELECT *
FROM row_numCTE
WHERE row_num > 1
ORDER BY PropertyAddress




WITH row_numCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) AS row_num
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing
)
DELETE
FROM row_numCTE
WHERE row_num > 1



---- Delete Unused Columns

SELECT *
FROM NashvilleHousingDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousingDataCleaning.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress
