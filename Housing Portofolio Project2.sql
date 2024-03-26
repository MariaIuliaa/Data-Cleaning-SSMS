--CLEANING DATA IN SQL QUERIES

select * 
from PortofolioProject2.dbo.NashvilleHousing

--STANDARDIZE DATE FORMAT from 2013-04-09 00:00:00.000 to 2013-04-09

select SaleDateConverted, convert(date, SaleDate)
from PortofolioProject2.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)

--POPULATE PROPERTY ADDRESS DATA
select *
from PortofolioProject2.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject2.dbo.NashvilleHousing a
--self join
join PortofolioProject2.dbo.NashvilleHousing b
 on  a.ParcelID = b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject2.dbo.NashvilleHousing a
join PortofolioProject2.dbo.NashvilleHousing b
 on  a.ParcelID = b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

 select PropertyAddress
 from PortofolioProject2.dbo.NashvilleHousing
 --the delimitator is a comma, we want to get rid of it

 select 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
 --after this we will still have a comma at the end CHARINDEX(',', PropertyAddress) specifies a position
 -- SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address, CHARINDEX(',', PropertyAddress)
--this will show the position of the comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 ,LEN(PropertyAddress)) as Address
-- =1 we go to the comma itself

 from PortofolioProject2.dbo.NashvilleHousing



alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortofolioProject2.dbo.NashvilleHousing


--this shows the city, address and state, so we need to split it
--we dont want to unse substring again
select OwnerAddress
from PortofolioProject2.dbo.NashvilleHousing

--parsname is useful for periods, it does things backwards
select 
PARSENAME(replace (OwnerAddress, ',', '.'), 3),
PARSENAME(replace (OwnerAddress, ',', '.'), 2),
PARSENAME(replace (OwnerAddress, ',', '.'), 1)
from PortofolioProject2.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace (OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace (OwnerAddress, ',', '.'), 2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace (OwnerAddress, ',', '.'), 1)


--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortofolioProject2.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From  PortofolioProject2.dbo.NashvilleHousing
--after this we will still have some N s that havent been transformed

update NashvilleHousing
set SoldAsVacant=CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--REMOVE DUPLICATESS
--we re going to run a CTE
with RowNumCTE AS(
Select *,
--we need to partition on things that should be unique to each row

	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From  PortofolioProject2.dbo.NashvilleHousing
--order by ParcelID
)
--delete
select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress

--DELETE UNUSED COLUMNS

select* 
From  PortofolioProject2.dbo.NashvilleHousing

alter table PortofolioProject2.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

--delete the SaleDate

alter table PortofolioProject2.dbo.NashvilleHousing
drop column SaleDate