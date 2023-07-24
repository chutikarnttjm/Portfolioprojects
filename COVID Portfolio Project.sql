
Select *
From Rip
where continent is not null
order by 3,4

Select *
From Vaccination
where continent is not null
order by 3,4

--Select *
--From Vaccination
--order by 3,4

--looking at tot cases vs Tot Deaths on Thailand

Select location, date, population, total_cases, total_deaths, (total_deaths/Total_cases)*100 as deathprecentage
From dbo.Rip 
where location like '%Thai%' 
order by 1,2

--? Shows percentage of population got covid on Thailand

Select location, date, population, total_cases, total_deaths, (Total_cases/population)*100 as Infected
From dbo.Rip 
where location like '%Thai%'
order by 1,2

--?> what country have highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectioncount,  (MAX(Total_cases)/population)*100 as PercentPopulationInfected
From dbo.Rip 
group by location, population
where continent is not null
order by PercentPopulationInfected DESC

-- ANS : "Andorra" has a highest infection rate when compared with pop.

--? Where thailand on in ranking?

--Sol1 - show rownumber first

Select row_number() over (order by (MAX(Total_cases)/population)*100 DESC) as rownumber,location, population, MAX(total_cases) as HighestInfectioncount,  (MAX(Total_cases)/population)*100 as PercentPopulationInfected
From dbo.Rip 
where continent is not null
group by location, population
order by PercentPopulationInfected DESC
 
--Sol2 show rownumber by subquery 

Select Row_number() Over (order by PercentPopulationInfected DESC) as rownum, location, population, HighestInfectioncount, PercentPopulationInfected
From (
	Select location, population, MAX(total_cases) as HighestInfectioncount, (MAX(Total_cases)/population)*100 as PercentPopulationInfected 
	From Rip
	where continent is not null
	group by location, population
) as subquery;

---Then select 'thailand' and show where thailand is on the rankedData
----create cte first to freeze row number

With RankedData as (                                           
  select location, population, MAX(total_cases) as HighestInfectioncount, (MAX(Total_cases) / population) * 100 AS PercentPopulationInfected,
    ROW_NUMBER() OVER (ORDER BY (MAX(Total_cases) / population) DESC) AS rownum
  From Rip
  where continent is not null
  Group BY location, population
)
Select location, population, HighestInfectioncount, PercentPopulationInfected, rownum
From RankedData
Where location = 'Thailand';

--- ANS : Thailand is 160 on the rankedData about the country who have HighestPercentPopulationInfected 

--?: country with hightest death count per population
-- 1. clean data by convert datatype of total_deaths from nvarchar to int before aggrerate
--2. use 'cast' to convert datatype

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From Rip
group by location, population
order by TotalDeathCount DESC

--but the result of the location column show that many continents are included in there instead just the names of countries 
--1. Clean data by add scritp 'where continent is not null' where null is the names in continent column that have continent names in location column

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From Rip
where continent is not null
group by location, population
order by TotalDeathCount DESC

--ANS : United States

-- BREAK THINGS DOWN BY CONTINENT

--showing continents with the hightest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Rip
where continent is not null
group by continent
order by TotalDeathCount DESC

--global numbers

Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int))as total_death, sum(cast(New_deaths as int))/sum(new_cases)*100 as DeathPercentage
From dbo.Rip 
where continent is not null
order by 1,2

-- let's join 2 table

-- looking at Total Population vs Vaccinations

select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by rip.location) as totalnewvac 
--we have to partition by location because we want to start over when we get new country
from Rip
join Vaccination vac
	on Rip.location = vac.location
	and Rip.date = vac.date
where rip.continent is not null
order by 2,3
 
 -- the code above just show all sum of newvaccination in every single row of each country
--so we have to use "order by" in partition to show progressive addition for each row of each country 

select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by rip.location order by rip.date) as RollingPeopleVaccinated
--we have to partition by location because we want to start over when we get new country
from Rip
join Vaccination vac
	on Rip.location = vac.location
	and Rip.date = vac.date
where rip.continent is not null
order by 2,3

--Create CTE to compared Peoplevaccinated VS Population each country in percentage (we can't use our own created column to calculate directly)

with rollingppvac as (
select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by rip.location order by rip.date) as RollingPeopleVaccinated
--we have to partition by location because we want to start over when we get new country
from Rip
join Vaccination vac
	on Rip.location = vac.location
	and Rip.date = vac.date
where rip.continent is not null
--order by 2,3
)
select  continent, location, population, RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100 as comparedPercentage 
from rollingppvac

--? What is the lastest percentage of vaccinated compared to the population of each country?

with rollingppvac as (
select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by rip.location order by rip.date) as RollingPeopleVaccinated
--we have to partition by location because we want to start over when we get new country
from Rip
join Vaccination vac
	on Rip.location = vac.location
	and Rip.date = vac.date
where rip.continent is not null
--order by 2,3
)
select  continent, location, population, MAX(RollingPeopleVaccinated/population)*100 as MAXcompared 
from rollingppvac
group by location, continent, population

--TEMP Table

DROP Table if exists #PercentPopulationVaccinated
create table #PercentpopulationVaccinated
(
continent nvarchar(255), location nvarchar(255), date datetime, population numeric,
new_vaccinations numeric, RollingPeopleVaccinated numeric 
)

Insert into #PercentpopulationVaccinated  --we can select values from the rip table instead insert by your own (copy code above)
	Select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by rip.location order by rip.date) as RollingPeopleVaccinated
--we have to partition by location because we want to start over when we get new country
	from Rip
	join Vaccination vac
		on Rip.location = vac.location
		and Rip.date = vac.date
	--where rip.continent is not null
	--order by 2,3

select  *
from #PercentpopulationVaccinated

--creating view to store data for later visualizations

create view PercentpopulationVaccinated as
	Select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by rip.location order by rip.date) as RollingPeopleVaccinated
--we have to partition by location because we want to start over when we get new country
	from Rip
	join Vaccination vac
		on Rip.location = vac.location
		and Rip.date = vac.date
	where rip.continent is not null
	--order by 2,3








 
























