select * from covid_deaths
where continent is not null
order by 3,4

select * from covid_vaccinations
order by 3,4

--Select Data that we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2

--Looking at Total Cases vs Total Deaths 
--(how many cases are in this country and how many deaths do they have for their cases?)
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%States'
order by 1,2

-- converted data types to numeric so we could divide
alter table covid_deaths
alter column population TYPE numeric(10,0) USING (population::numeric(10,0))

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from covid_deaths
--where location like '%States'
order by 1,2

-- Looking at countries with Highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths
--where location like '%States'
group by location, population
order by PercentPopulationInfected desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, MAX(total_deaths) as TotalDeathCount
from covid_deaths
--where location like '%States'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing Countries with Highest Death Count per Population
select location, MAX(total_deaths) as TotalDeathCount
from covid_deaths
--where location like '%States'
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population
select continent, MAX(total_deaths) as TotalDeathCount
from covid_deaths
--where location like '%States'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, SUM(cast(new_cases as numeric)) as total_cases, SUM(cast(new_deaths as numeric)) as total_deaths, SUM(cast(new_deaths as numeric))/
SUM(cast(new_cases as numeric))*100 
as DeathPercentage
from covid_deaths
--where location like '%States'
where continent is not null
and total_cases is not null
and total_deaths is not null 
group by date
order by 1,2

-- Joining Both Tables
-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as numeric),
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated-- what is OVER AND PARTITION?
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE because we can't use a column we just created using select clause
-- CTE: Common Table Expression

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as numeric),
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table: Steps - Create temp table first, then Insert Into, then Select *

Drop table if exists PercentPopulationVaccinated
Create Temporary Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric(50),
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as numeric),
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 
From PercentPopulationVaccinated

--Creating View to store data for later visualizations.
-- The query below "PercentPopulationVaccinated" can be used for vizs

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as numeric),
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated