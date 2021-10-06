--Cleaning data in SQL Queries


Select *
From PortfolioProject2.dbo.NashvilleHousing


--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject2.dbo.NashvilleHousing

Update PortfolioProject2.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject2.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From PortfolioProject2.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, State)
Select PropertyAddress
From PortfolioProject2.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject2.dbo.NashvilleHousing




ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
Add PropertySplitAddress VARCHAR(255);

Update PortfolioProject2.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
Add PropertySplitCity VARCHAR(255);

Update PortfolioProject2.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



Select *
From PortfolioProject2.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------

-- Owner Address

Select OwnerAddress
From PortfolioProject2.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject2.dbo.NashvilleHousing



ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject2.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject2.dbo.NashvilleHousing


Update PortfolioProject2.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
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

From PortfolioProject2.dbo.NashvilleHousing
--order by ParcelID
)


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject2.dbo.NashvilleHousing




-------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject2.dbo.NashvilleHousing


ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


