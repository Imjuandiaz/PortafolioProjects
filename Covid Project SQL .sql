SELECT *
FROM `dataset00.ProjectSQL.CovidDeaths`  
order by 1,2 ;

-- Looking at the Distinct Countries in the DataSet

SELECT DISTINCT country 
FROM `dataset00.ProjectSQL.CovidDeaths`
ORDER BY country;

--Looking at Total Cases vs Total Death(in usa)

SELECT
  country,
  date,
  total_cases,
  new_cases,
  total_deaths,
  (total_deaths / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM `dataset00.ProjectSQL.CovidDeaths`
WHERE country like '%States%' 
and continent IS NOT NULL
ORDER BY country, date;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT
  country,
  date,
  total_cases,
  population,
  (NULLIF(total_cases, 0)/population) * 100 AS DeathPercentage
FROM `dataset00.ProjectSQL.CovidDeaths`
WHERE country like '%States%'
and continent is not null
ORDER BY country, date;

-- Countries with Highest Infection Rate compared to Population
SELECT
  country,
  population,
  MAX(total_cases) AS HighestInfectionCount,
  MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM `dataset00.ProjectSQL.CovidDeaths`
WHERE population IS NOT NULL AND population > 0
GROUP BY country, population
ORDER BY PercentPopulationInfected DESC;

--Countries with Highest Death Count per Population

SELECT country, MAX(total_deaths) AS total_death_count
FROM `dataset00.ProjectSQL.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY total_death_count DESC
LIMIT 20;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From `dataset00.ProjectSQL.CovidDeaths`
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from `dataset00.ProjectSQL.CovidDeaths`
where continent is not null
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
  dea.continent,
  dea.country,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) 
    OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM `dataset00.ProjectSQL.CovidDeaths` AS dea
JOIN `dataset00.ProjectSQL.CovidVaccinations` AS vac
  ON dea.country = vac.country
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL and new_vaccinations is not null
ORDER BY dea.country, dea.date;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac as 
(Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int64)) OVER (Partition by dea.country Order by dea.country, dea.Date) as RollingPeopleVaccinated
From `dataset00.ProjectSQL.CovidDeaths` dea
Join `dataset00.ProjectSQL.CovidVaccinations` vac
	On dea.country = vac.country
	and dea.date = vac.date
where dea.continent is not null )
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
From PopvsVac
ORDER BY country, date;

-- Using Temp Table to perform Calculation on Partition By in previous query

CREATE TEMP TABLE PercentPopulationVaccinated AS
SELECT
  dea.continent,
  dea.country,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64))
    OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date)
    AS RollingPeopleVaccinated
FROM `dataset00.ProjectSQL.CovidDeaths` AS dea
JOIN `dataset00.ProjectSQL.CovidVaccinations` AS vac
  ON dea.country = vac.country
 AND dea.date = vac.date;

SELECT *,
       (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated
ORDER BY country, date;

-- Creating View to store data for later visualizations

CREATE OR REPLACE VIEW `dataset00.ProjectSQL.PercentPopulationVaccinated` AS
SELECT 
  dea.continent,
  dea.country,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) 
    OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM `dataset00.ProjectSQL.CovidDeaths` AS dea
JOIN `dataset00.ProjectSQL.CovidVaccinations` AS vac
  ON dea.country = vac.country
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;















