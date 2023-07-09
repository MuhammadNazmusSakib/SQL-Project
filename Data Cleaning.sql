---------------------Cleaning Data in SQL Queries------------------


select *
from PortfolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------
-----------------------------------Standardize Data Format---------------------------------------------------
-------------------------------------------------------------------------------------------------------------

select Saledate
from PortfolioProject..NashvilleHousing


select Saledate, convert(date, Saledate) as Date
from PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
--drop column SaledateConverted;
add SaledateConverted Date;

update PortfolioProject..NashvilleHousing
set SaledateConverted = convert(date, Saledate)

select SaledateConverted, convert(date, Saledate) as Date
from PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------------------------------------
-----------------------------------Populate Property Address data-------------------------------------------
------------------------------------------------------------------------------------------------------------

select *
from PortfolioProject..NashvilleHousing 
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
        isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b on
     a.ParcelID = b.ParcelID and
	 a.[uniqueID ] <> b.[uniqueID ]
where a.PropertyAddress is null


update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b on
     a.ParcelID = b.ParcelID and
	 a.[uniqueID ] <> b.[uniqueID ]
where a.PropertyAddress is null


-------------------------------------------------------------------------------------------------------------
--------------------Braking out Address into individual Columns (Address, City, State)-----------------------
-------------------------------------------------------------------------------------------------------------



select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
       substring(PropertyAddress, charindex(',', PropertyAddress) +1, 
	   len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
--drop column PropertySplitAddress;
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) 

alter table PortfolioProject..NashvilleHousing
--drop column PropertySplitCity;
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, 
	   len(PropertyAddress)) 


select PropertySplitAddress, PropertySplitCity
from PortfolioProject..NashvilleHousing




select OwnerAddress
from PortfolioProject..NashvilleHousing
--where OwnerAddress is not null

select parsename(replace(OwnerAddress, ',', '.'), 3),
       parsename(replace(OwnerAddress, ',', '.'), 2),
	   parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing
--where OwnerAddress is not null

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);
--drop column OwnerSplitAddress;

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)


alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);
--drop column OwnerSplitCity;

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)


alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);
--drop column OwnerSplitCity;

update PortfolioProject..NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)


select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProject..NashvilleHousing



----------------------------------------------------------------------------------------------------------
-------------------Change Y and N to Yes and No in "Sold as Vacant" field---------------------------------
----------------------------------------------------------------------------------------------------------


select SoldAsVacant
from PortfolioProject..NashvilleHousing

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case 
    when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case 
    when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end




------------------------------------------------------------------------------------------------------
---------------------------------Remove Duplicates----------------------------------------------------
------------------------------------------------------------------------------------------------------


with RowNumCTE as(
select *,
	Row_Number() over (
	partition by ParcelID,
				 PropertyAddress
				 order by
				    UniqueID
					)Row_Num
from PortfolioProject..NashvilleHousing
)
delete
--select *
from RowNumCTE
where Row_Num > 1
--order by Row_Num desc



-----------------------------------------------------------------------------------------------------------
---------------------------------Delete Unused Column------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress, TaxDistrict, OwnerAddress,SaleDate

