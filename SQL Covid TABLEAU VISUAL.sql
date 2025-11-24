/*

Queries used for Tableau Project

*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From `dataset00.ProjectSQL.CovidDeaths`
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
 --Just a double check based off the data provided

-- 2. 

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From `dataset00.ProjectSQL.CovidDeaths`
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- 3.

Select country, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `dataset00.ProjectSQL.CovidDeaths`
--Where location like '%states%'
Group by country, Population
order by PercentPopulationInfected desc


-- 4.


Select country, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `dataset00.ProjectSQL.CovidDeaths`
Where country IN ('China', 'India', 'United States' , 'Russia' , 'Mexico' , 'Japan', 'United Kingdom','Venuzuela')
Group by country, Population, date
order by PercentPopulationInfected desc


