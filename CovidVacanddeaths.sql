Select *
From ProfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From ProfolioProject..CovidVacc
--order by 3,4

Select Location, date, total_cases,new_cases, total_deaths, population
From ProfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total deaths
--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at Total cases vs Population
--Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
From ProfolioProject..CovidDeaths
-- Where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentofPopulationInfected
From ProfolioProject..CovidDeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentofPopulationInfected desc


--LETS BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

Select continent, Max(cast (Total_deaths as int)) as TotalDeathCount
From ProfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc




-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Popluation vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated