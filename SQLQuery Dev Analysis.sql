
SELECT * 
From PortfolioProject..CovidDeaths$
Where continent Is Not Null

--SELECT * FROM CovidDeaths$

SELECT location, continent, date, population, total_cases, new_cases, total_deaths From CovidDeaths$
Order By 1,2

--Looking at total_cases vs total_deaths
-- Shows the likelihood of dying in the country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage From CovidDeaths$
Where location like 'India%'
Order By 1,2

--Looking at the TotalCases Vs Population
--Shows the percentage of the people that got covid
SELECT location, date, population, (total_cases/population)*100 as DeathPercentage 
From CovidDeaths$
Where location like 'India%'
Order By 1,2


-- Countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as 
PercentPopulationInfected  From CovidDeaths$
--Where location like 'India%'
Group By location, population
Order By PercentPopulationInfected  desc

-- Showing the countries with the highest death count per population

-- Lets Break things down by continent



SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeaths$
--Where location like 'India%'
Where continent Is Null
Group By continent
Order By TotalDeathCount  desc


--Showing the continents withnthe highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeaths$
--Where location like 'India%'
Where continent Is Null
Group By continent
Order By TotalDeathCount  desc


-- Global numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as
DeathPercentage
From CovidDeaths$
--Where location like 'India%'
Where continent is not null
--GROUP By date
Order By 1,2



-- Total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over(Partition by dea.location 
Order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN
PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
order by 2,3



--Use CTE


With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over(Partition by dea.location 
Order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN
PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TempTables
Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over(Partition by dea.location 
Order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN
PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- creating views to sore data for visualisations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over(Partition by dea.location 
Order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN
PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3







IF OBJECT_ID('dbo.PercentPopulationVaccinated', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.PercentPopulationVaccinated;
END

-- Step 2: Create the new view

CREATE VIEW dbo.PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths$ dea
JOIN 
    PortfolioProject..CovidVaccinations$ vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated