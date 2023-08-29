Select *
From NashvileHousing


--Standardize Date Format

Select SaleDateconverting, Convert(Date,SaleDate) --it's doesn't work
From NashvileHousing

Update NashvileHousing
SET SaleDate = Convert(Date,SaleDate)  --it's doesn't work

alter table NashvileHousing --add column to the table
add SaleDateconverting Date;

Update NashvileHousing --update column (and it's work)
SET SaleDateconverting = Convert(Date,SaleDate)

---Populate Property Address Data

select *
From NashvileHousing
--where PropertyAddress is null
order by ParcelID

--When order by parcelID, We see that the same PercelID will have the same PropertyAddress so we will populate PropertyAddress for the same ParcelID which didn't same  uniqueID
--by using 'Isnull' to check if it's null populate something into it (As you can see 'datatoUpdate' column)

select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress,b.PropertyAddress) as datatoUpdate
From NashvileHousing a
join NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--order by a.[UniqueID ]

--Update Property Address

Update a
SET PropertyAddress = Isnull(a.PropertyAddress,b.PropertyAddress) 
From NashvileHousing a
join NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City)

select PropertyAddress
From NashvileHousing
--order by ParcelID

--use substring to extracts some characters from a string. And we use comma to extracts Address and city
select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
From NashvileHousing a

--So we have to add column & update data for Address, City

alter table NashvileHousing --add column to the table
add PropertySplitAddress Nvarchar(255);

Update NashvileHousing --update column (and it's work)
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 



alter table NashvileHousing --add column to the table
add PropertySplitCity Nvarchar(255);

Update NashvileHousing --update column (and it's work)
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) 

--Now we have 2 column added on Datasheet

--Split the delimited data of OwnerAddress by using Parsename

select OwnerAddress
From NashvileHousing 

Select
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
From NashvileHousing 

--So we have to add column & update data for Address, City, State

alter table NashvileHousing --add column to the table
add OwnerSplitAddress Nvarchar(255);

Update NashvileHousing --update column (and it's work)
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

alter table NashvileHousing --add column to the table
add OwnerSplitCity Nvarchar(255);

Update NashvileHousing --update column (and it's work)
SET OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)


alter table NashvileHousing --add column to the table
add OwnerSplitState Nvarchar(255);

Update NashvileHousing --update column (and it's work)
SET OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1) 

--Now, We have 3 column added on Datasheet 

Select *
From NashvileHousing

--****execute this code if you want to delete a column you had created or its didn't arrange correctly****--
alter table NashvileHousing
Drop column OwnerSplitState;

--change Y and N to Yes and No in 'Sold as Vacant' field 

Select distinct(SoldAsVacant), count(SoldAsVacant) as count
From NashvileHousing
group by SoldAsVacant
order by 2
 
 --or

Select SoldAsVacant, count(SoldAsVacant) as count
From NashvileHousing
group by SoldAsVacant

--changing Y and N

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
From NashvileHousing
where SoldAsVacant in ('Y','N') 

--then update in SoldAsVacant Column

Update NashvileHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

--Remove Duplicates
--show the duplicate rows by:

with rownumcte as (
select *, row_number() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) as rownum
From NashvileHousing
--order by ParcelID
)

select *
From rownumcte
where rownum > 1
order by PropertyAddress

-- Delete duplicate rows
Delete from rownumcte
where rownum > 1

--Delete the unused columns that we previously split and unnecessary
select *
from NashvileHousing

alter table NashvileHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvileHousing
drop column SaleDate


