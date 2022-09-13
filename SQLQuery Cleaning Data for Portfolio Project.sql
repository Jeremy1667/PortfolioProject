
/* Portfolio Project for Cleaning Data


cleaning data in SQL queries
*/

select *
from [Portfolio project].dbo.NashvilleHousing

--standardize Sale Date format

select SaleDateConverted, Convert (date,SaleDate)
from [Portfolio project].dbo.NashvilleHousing

update NashvilleHousing
set SaleDate= Convert (date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted= Convert(Date,Saledate)

--Populate Property Address Data 

select *
from [Portfolio project].dbo.NashvilleHousing

--where PropertyAddress is null
order by ParcelID	


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio project].dbo.NashvilleHousing a
JOIN [Portfolio project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = Isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio project].dbo.NashvilleHousing a
JOIN [Portfolio project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State) 

select PropertyAddress
from [Portfolio project].dbo.NashvilleHousing

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress)) as Address

from [Portfolio project].dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


alter table NashvilleHousing
add PropertySplitCity NvarChar(255);

update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress))

select *

from [Portfolio project].dbo.NashvilleHousing

--seperating the owner address into different columns to differentiate city and address and state

Select OwnerAddress
from  [Portfolio project].dbo.NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
from  [Portfolio project].dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)

alter table NashvilleHousing
add OwnerSplitCity NvarChar(255);

update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2)

alter table NashvilleHousing
add OwnerSplitState NvarChar(255);

update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') , 1)


select *

from [Portfolio project].dbo.NashvilleHousing


--Change Y and N to Yes and No in "sold as vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio project].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


select SoldAsVacant
, Case when SoldAsVacant = 'y' then 'Yes'
		When SoldAsVacant = 'N' then 'No' 
		Else SoldAsVacant
		End
From [Portfolio project].dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'y' then 'Yes'
		When SoldAsVacant = 'N' then 'No' 
		Else SoldAsVacant
		End


--Remove Duplicates

WITH RowNumCTE AS(
select *,
	row_Number() Over (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					) Row_Num
				


From [Portfolio project].dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
where Row_Num > 1
order by PropertyAddress


select *
From [Portfolio project].dbo.NashvilleHousing


--Delete Unused Columns 

select *
From [Portfolio project].dbo.NashvilleHousing

Alter table [Portfolio project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter table [Portfolio project].dbo.NashvilleHousing
DROP COLUMN SaleDate