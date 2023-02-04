CREATE TABLE public.NashvilleHousing
(
    UniqueID text,
    ParcelID text,
    LandUse text,
    PropertyAddress text,
    SaleDate text,
    SalePrice text,
    LegalReference text,
    SoldAsVacant text,
    OwnerName text,
    OwnerAddress text,
    Acreage text,
    TaxDistrict text,
    LandValue text,
    BuildingValue text,
    TotalValue text,
    YearBuilt text,
    Bedrooms text,
    FullBath text,
    HalfBath text
);

ALTER TABLE IF EXISTS public.NashvilleHousing
    OWNER to postgres;
	
-- Cleaning Data in SQL Queries

--Standardizing Date Format

Select SaleDate, Cast(SaleDate as date) 
from nashvillehousing

Update nashvillehousing 
SET SaleDate = Cast(SaleDate as date) 

Select * from nashvillehousing

-- Populate Property Address Data

Select * from nashvillehousing
--where propertyaddress is null
order by ParcelID

Select a.ParcelID, a.Propertyaddress, b.ParcelID, b.Propertyaddress, COALESCE(a.Propertyaddress, b.Propertyaddress)
from nashvillehousing a 
JOIN nashvillehousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.Propertyaddress is null

Update a
SET propertyaddress = COALESCE(a.Propertyaddress, b.Propertyaddress)
from nashvillehousing a 
JOIN nashvillehousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.propertyaddress is null

-- Breaking out Address into Individual Columns
Select Propertyaddress
from nashvillehousing

SELECT
substring(PropertyAddress, 1, strpos(PropertyAddress, ',') -1) as Address
, substring(PropertyAddress, strpos(PropertyAddress, ',') +1, LENGTH(PropertyAddress)) as Address
from nashvillehousing

ALTER TABLE nashvillehousing
Add PropertySplitAddress varchar(255);

Update nashvillehousing
SET PropertySplitAddress = substring(PropertyAddress, 1, strpos(PropertyAddress, ',') -1) 

ALTER TABLE nashvillehousing
Add PropertySplitCity varchar(255);

Update nashvillehousing
SET PropertySplitCity = substring(PropertyAddress, strpos(PropertyAddress, ',') +1, LENGTH(PropertyAddress))

Select * from nashvillehousing

--
Select 
split_part(Owneraddress, ',', 1),
split_part(Owneraddress, ',', 2),
split_part(Owneraddress, ',', 3)
from nashvillehousing
where owneraddress is not null

Alter Table nashvillehousing
add OwnerSplitAddress varchar(255)

Update nashvillehousing
SET OwnerSplitAddress = split_part(Owneraddress, ',', 1)

Alter Table nashvillehousing
add OwnerSplitCity varchar(255)

Update nashvillehousing
SET OwnerSplitCity = split_part(Owneraddress, ',', 2)

Alter Table nashvillehousing
add OwnerSplitState varchar(255)

Update nashvillehousing
SET OwnerSplitState = split_part(Owneraddress, ',', 3)

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldasVacant), Count(SoldasVacant)
from nashvillehousing
group by soldasvacant
order by 2

Select soldasvacant
, CASE When SoldasVacant = 'Y' THEN 'Yes'
	   When SoldasVacant = 'N' THEN 'No'
	   ELSE SoldasVacant
	   END
from nashvillehousing

Update nashvillehousing
SET soldasvacant = CASE When SoldasVacant = 'Y' THEN 'Yes'
	   When SoldasVacant = 'N' THEN 'No'
	   ELSE SoldasVacant
	   END
	 
-- Removing Duplicates

WITH RowNumCTE AS (
Select *,
ROW_Number() OVER(
PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID) row_num

from nashvillehousing)
Select *
from RowNumCTE
where row_num > 1
Order by PropertyAddress

--Postgres does not allow column deletion from a CTE.
--Alternative:

WITH RowNumCTE AS (
DELETE from nashvillehousing
returning *
)
insert into nashvillehousing (ParcelID,
	SalePrice,
	SaleDate,
	LegalReference)
select ParcelID,
	SalePrice,
	SaleDate,
	LegalReference
from (
select ROW_Number() OVER(
PARTITION BY ParcelID,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID) row_num, ParcelID,
	SalePrice,
	SaleDate,
	LegalReference
	from RowNumCTE
	) atab
where row_num =1; -- > wrong

select * from nashvillehousing
where uniqueid is not null

--Delete unused columns

Select * from nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN Owneraddress 

ALTER TABLE nashvillehousing
DROP COLUMN taxdistrict

ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress