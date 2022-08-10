select *
from [Portfolio project]..CovidDeaths$
where continent is not null 
order by 3,4


--select *
--from [Portfolio project]..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio project]..CovidDeaths$
order by 1,2


-- Looking at Total Cases Vs Total Deaths
-- show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths$
where location like '%states%' 
order by 1,2


-- Look at Total cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths$
--where location like '%states%' 
order by 1,2


-- Looking at Countries with Hignest Infection Rate compared to Population. 

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio project]..CovidDeaths$
--where location like '%states%'
group by location, population 
order by PercentPopulationInfected desc


--show the countries with the highest death count per population

select location, max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--BREAK THINGS DOWN BY CONTINENTS

select location, max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--showing the continents with the highest death counts per population

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null 
group by date
order by 1,2

--as opposed to day by day this bottom query is for all time 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null 
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as ContinuousCountofVaccinations
, 
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

With PopvsVac(continent, location, date, population, new_vaccinations, ContinuousCountofVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as ContinuousCountofVaccinations
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (ContinuousCountofVaccinations/population)*100
from PopvsVac

--Temp table 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255), location nvarchar(255), date datetime, Population numeric, New_vaccinations numeric, ContinuousCountofVaccinations numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as ContinuousCountofVaccinations
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (ContinuousCountofVaccinations/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as ContinuousCountofVaccinations
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

