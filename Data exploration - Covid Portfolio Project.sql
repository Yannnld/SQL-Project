select * 
from ProjectCovid19..CovidDeaths
order by 3,4

--select * 
--from ProjectCovid19..CovidVaccinations
--where continent is not null 
--order by 3,4;

select Location, date, total_cases, new_cases, total_deaths, population
from ProjectCovid19..CovidDeaths
order by 1,2;

-- Looking at the Total Cases vs Total Deaths 
-- Show likelihood of dying if you contract covid in your country 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectCovid19..CovidDeaths
where location = 'france'
order by 1,2; 

-- Looking at the Total cases vs Population
-- Shows what percentage of population got Covid

select location, date, Population, total_cases, (total_cases/population)*100 as CovidPercentagePop
from ProjectCovid19..CovidDeaths
-- where location = 'france'
order by 5 desc; 

-- Looking at Countries with Highest Infection Rate compared to Population 
select location, population, 
MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected 
from ProjectCovid19..CovidDeaths
group by location, population
order by PercentPopulationInfected desc;

-- Showing Countries with the highest Death Count per Population 

select location, max(cast(total_deaths as int)) as TotalDeathCount
from ProjectCovid19..CovidDeaths
group by location
order by TotalDeathCount desc; 

-- Showing continents with the highest death count per population 

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from ProjectCovid19..CovidDeaths
group by continent
order by TotalDeathCount desc; 

-- Global Numbers 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeatPercentage 
FROM ProjectCovid19..CovidDeaths 
order by 1,2;

-- Looking at tota population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from ProjectCovid19..CovidDeaths dea
join ProjectCovid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
	order by 2,3;

-- Use CTE

with PopvsVac (Continent, location , date, population, new_vaccinations, rollingpeoplevaccinated) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ProjectCovid19..CovidDeaths dea
join ProjectCovid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
-- where dea.location = 'france'
-- order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 as PercRollingppvaccinated
from PopvsVac

-- Temp Table 

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric, 
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ProjectCovid19..CovidDeaths dea
join ProjectCovid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
-- where dea.location = 'france'
-- order by 2,3

select *, (rollingpeoplevaccinated/population)*100 as PercRollingppvaccinated
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ProjectCovid19..CovidDeaths dea
join ProjectCovid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 

select *
from PercentPopulationVaccinated; 