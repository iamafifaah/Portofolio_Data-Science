select * 
from Project_2.dbo.CovidDeaths$ 
where continent is not null
order by 3,4

-- select * from Project_2.dbo.CovidVaccinations$ order by 3,4

-- select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from Project_2.dbo.CovidDeaths$ 
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Death

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
from Project_2.dbo.CovidDeaths$
where location like '%states%'
and continent is not null
order by deaths_percentage DESC

-- Looking at Total Cases VS Population

select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from Project_2.dbo.CovidDeaths$
--- where location like '%states%'
order by percent_population_infected DESC


-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population)*100) as percent_population_infected
from Project_2.dbo.CovidDeaths$
--- where location like '%states%'
where continent is not null
group by location, population
order by percent_population_infected DESC

-- Showing Countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project_2.dbo.CovidDeaths$
--- where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project_2.dbo.CovidDeaths$
--- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- When Location not in continent
/* select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project_2.dbo.CovidDeaths$
--- where location like '%states%'
where continent is null
group by location
order by TotalDeathCount DESC */

-- Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project_2.dbo.CovidDeaths$
--- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Project_2.dbo.CovidDeaths$
-- where location like '%states%'
where continent is not null
-- Group by date
order by DeathPercentage DESC

-- Join Table
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project_2.dbo.CovidDeaths$ dea
join Project_2.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by new_vaccinations DESC
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccination

create table #PercentPopulationVaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project_2.dbo.CovidDeaths$ dea
join Project_2.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by new_vaccinations DESC

select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccination
from #PercentPopulationVaccination

-- Create view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project_2.dbo.CovidDeaths$ dea
join Project_2.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by new_vaccinations DESC

select *
from PercentPopulationVaccinated