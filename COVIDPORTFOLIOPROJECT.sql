/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT *
FROM [Portfolio project]..Coviddeaths
order by 3,4
-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio project]..Coviddeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal) / CAST(total_cases AS decimal)) * 100 AS DeathPercentage
FROM [Portfolio project]..Coviddeaths
Where location like '%nigeria%'
and continent is not null
ORDER BY Location, date;


-- Looking at Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, total_cases, Population, (CAST(total_cases AS decimal) / CAST(population AS decimal)) * 100 AS PercentPopulationInfected
FROM [Portfolio project]..Coviddeaths
--Where location like '%nigeria%'
ORDER BY Location, date;


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, Population, (CAST(MAX(total_cases) AS decimal) / CAST(Population AS decimal)) * 100 AS DeathPercentage
FROM [Portfolio project]..Coviddeaths
GROUP BY Location, Population
ORDER BY Location;

--Showing Countries with Highest Death Count per Population


SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio project]..Coviddeaths
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio project]..Coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS 

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio project]..Coviddeaths
--Where location like '%nigeria%'
where continent is not null
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from [Portfolio project]..Coviddeaths dea
Join [Portfolio project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3



  -- USE CTE 
  -- Using CTE to perform Calculation on Partition By in previous query

  WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
  FROM [Portfolio project]..Coviddeaths dea
  JOIN [Portfolio project]..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;


-- TEMP TABLE
-- Using Temp Table to perform Calculation on Partition By in previous query

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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
  FROM [Portfolio project]..Coviddeaths dea
  JOIN [Portfolio project]..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  --order by 2,3

  Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..Coviddeaths dea
Join [Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


 

