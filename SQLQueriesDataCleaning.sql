/*

Cleaning Data in SQL Queries

*/
Select * 
from PortfolioDataCleaningProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioDataCleaningProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data 

Select *
From PortfolioDataCleaningProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID





-- ParcelID is going to be the same as property Address, so if X parcel Id has Y address, -> then we can populate null addresses because we know Parcel ID, gonna have to use a self-join
-- IF X is equal to Y, then we can Infer and populate Null values of Y because we know X...

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- WHEN NULL, populate property address with PropertyAddress
from PortfolioDataCleaningProject.dbo.NashvilleHousing a
JOIN PortfolioDataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- and A.Unique Id is NOT equal to B.UniqueID
	Where a.PropertyAddress is null 

	-- Now we need to update and populate
	Update a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) -- WHEN NULL, populate property address with PropertyAddress
	From PortfolioDataCleaningProject.dbo.NashvilleHousing a
	join PortfolioDataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null 



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress --delimiter is a comma
From PortfolioDataCleaningProject.dbo.NashvilleHousing
-- Where PropertyAddress is null 
-- Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

from PortfolioDataCleaningProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
from PortfolioDataCleaningProject.dbo.NashvilleHousing

-- can use parsename instead of substring, but we need to replace , with . where , is present
--Paresename instead of substring, but we need to replace, with . where , is present
Select
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3) -- Address
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,2) -- City
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,1) -- State
from PortfolioDataCleaningProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);


Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3) -- Address

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') ,2) -- City


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);


Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') ,1) -- State




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioDataCleaningProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioDataCleaningProject.dbo.NashvilleHousing


-- Update and change Y/N to Yes/NO
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
			) row_num

From PortfolioDataCleaningProject.dbo.NashvilleHousing
--Partition by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioDataCleaningProject.dbo.NashvilleHousing


ALTER TABLE PortfolioDataCleaningProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
