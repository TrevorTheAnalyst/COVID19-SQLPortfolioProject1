SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4;

--Selecting Data to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS numeric)/CAST(total_cases AS numeric))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'South Africa'
AND continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Cases vs Population
--Show what percentage of population got Covid

SELECT Location, date, Population, total_cases, (CAST(total_cases AS numeric)/CAST(population AS numeric))*100 AS InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'South Africa'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS numeric)/CAST(population AS numeric)))*100 AS InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'South Africa'
GROUP BY Location, Population
ORDER BY InfectionPercentage DESC;

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'South Africa'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--BREAKING DOWN BY CONTINENT
--Sorting continents by death count per population
SELECT continent, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'South Africa'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;




--GLOBAL NUMBERS
--Global daily Deaths as a percentage of New Cases
SELECT date, SUM(CAST(new_cases AS numeric)) total_cases, SUM(CAST(new_deaths AS numeric)) as total_deaths, ISNULL(SUM(CAST(new_deaths AS numeric))/NULLIF(SUM(CAST(new_cases AS numeric)),0),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Exploring both tables by creating an inner join

SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--Looking at Total Population vs Vaccinations with rolling totals of new vacinnations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS numeric)) OVER(Partition by  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USE A CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS numeric)) OVER(Partition by  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT* , (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPercentage
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS numeric)) OVER(Partition by  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS numeric)) OVER(Partition by  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *
FROM PercentPopulationVaccinated

