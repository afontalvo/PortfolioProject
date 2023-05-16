select *
from Covid..CovidDeaths$
where continent is not null
order by 3, 4

--select *
--from Covid..CovidVaccinations$
--order by 3, 4

--Select data we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
 from Covid..CovidDeaths$
 where continent is not null
 order by 1, 2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
 from Covid..CovidDeaths$
 where location like '%colombia%'
 where continent is not null
 order by 1, 2

--Looking at the total cases vs population
--Shows percentage of population got covid
select location, date, total_cases, population, total_deaths, (total_cases/population)*100 as infection_rate
 from Covid..CovidDeaths$
 where location like '%colombia%' 
 --where continent is not null
 order by 1, 2


--Looking at countries with highest infection rate vs population
select location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as infection_rate
 from Covid..CovidDeaths$
 where location like '%colombia%'
 group by population, location
 --where continent is not null
 order by infection_rate desc

--Showing the countries with the highest death count per population
select location, population, MAX(cast(total_deaths as int)) as total_deaths_count, MAX(cast(total_deaths as int))/population*100  as death_percentage
 from Covid..CovidDeaths$
 where location like '%colombia%'
 --where continent is not null
 group by population, location
 order by total_deaths_count desc

--Showing the percentage of the population who died because of covid
select location, population, MAX(cast(total_deaths as int)) as total_deaths_count, MAX(cast(total_deaths as int))/population*100  as death_percentage
 from Covid..CovidDeaths$
 --where location like '%colombia%'
 where continent is not null
 group by population, location
 order by death_percentage desc

 --Break this down by continent
 --Showing continent with the highest death count
 select location, MAX(cast(total_deaths as int)) as total_deaths_count 
 from Covid..CovidDeaths$
 --where location like '%colombia%'
 where continent is null
 group by location
 order by total_deaths_count desc

 --Global numbers
 select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))
 /SUM(new_cases)*100 as death_percentage 
 from Covid..CovidDeaths$
 --where location like '%colombia%' 
 where continent is not null
 Group by date
 order by 1, 2

--Looking population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as rolling_people_vaccinated--, (rolling_people_vaccinated/population)*100
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null	
order by 2, 3


--USE CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, people_vaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as rolling_people_vaccinated--, (rolling_people_vaccinated/population)*100
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null	
--order by 2, 3
)
Select *, (people_vaccinated/population)*100
from PopvsVac

-- Temp table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
People_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as rolling_people_vaccinated--, (rolling_people_vaccinated/population)*100
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null	
--order by 2, 3

Select *, (people_vaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view for data visualization
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as rolling_people_vaccinated--, (rolling_people_vaccinated/population)*100
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null	
--order by 2, 3