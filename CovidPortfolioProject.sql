Select *
From PortfolioProject2..CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject2..CovidVaccinations
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths 
order by 1,2

-- Looking for Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject2..CovidDeaths 
Where location like '%states%'
order by 1,2


--Looking at Total Cases Vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_deaths/population)* 100 as DeathPercentage
From PortfolioProject2..CovidDeaths 
--Where location like '%states%'
order by 1,2


--Looking at countries with higher infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)* 100 as PercentPopulationInfected
From PortfolioProject2..CovidDeaths 
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing the countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths 
Where continent is not null
Group by location
order by TotalDeathCount desc


--Breaking things down by continent

-- Showing the continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths 
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))* 100 as DeathPercentage
From PortfolioProject2..CovidDeaths 
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


-- Looking at Total Population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	order by 2,3


--Use CTE to perform calculations on the partition
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100 
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated