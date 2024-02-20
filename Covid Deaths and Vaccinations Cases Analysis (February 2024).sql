select * 
from PortafolioProjectCovid.dbo.CovidDeaths
WHERE continent is not null

Exec sp_help 'dbo.CovidDeaths';


ALTER TABLE PortafolioProjectCovid.dbo.CovidDeaths
ALTER COLUMN total_deaths float


ALTER TABLE PortafolioProjectCovid.dbo.CovidDeaths
ALTER COLUMN total_cases float


--Total Deaths Per Case
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortafolioProjectCovid.dbo.CovidDeaths
WHERE location like '%Mexico%'
ORDER BY 1, 2

-- Total Cases Per Population
SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 AS infection_rate
FROM PortafolioProjectCovid.dbo.CovidDeaths
WHERE location like '%Mexico%'
ORDER BY 1, 2

-- Countries with Highest Infection Rate Compared to Population
SELECT 
    location, 
    MAX(date) AS date,
    population,
    MAX(total_cases) AS highest_infection_count,
    (MAX(total_cases) / population) * 100 AS infection_rate_per_country
FROM 
    PortafolioProjectCovid.dbo.CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    location, population
ORDER BY 
    infection_rate_per_country DESC;


-- Countries with Highest Death Rate Compared to Population
SELECT 
    location, 
    MAX(date) AS date,
    population,
    MAX(total_deaths) AS highest_deaths_count,
    MAX(total_cases) AS total_cases,
    (MAX(total_deaths) / population) * 100 AS death_rate_per_country
FROM 
    PortafolioProjectCovid.dbo.CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY 
    location, population
ORDER BY 
    death_rate_per_country DESC;


-- Continents with Highest Death Count Per Population
SELECT 
    MAX(date) AS date,
    location,
    MAX(total_deaths) AS highest_deaths_count
FROM 
    PortafolioProjectCovid.dbo.CovidDeaths
WHERE
    continent is null
GROUP BY
    location
ORDER BY 
    highest_deaths_count DESC;

-- Global Numbers
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM 
    PortafolioProjectCovid.dbo.CovidDeaths
WHERE 
    continent IS NOT NULL
ORDER BY 
    1, 2;

-- Total Vaccinations Per Day On Countries
ALTER TABLE PortafolioProjectCovid.dbo.CovidVaccinations
ALTER COLUMN new_vaccinations FLOAT;

SELECT
    cd.location, 
    cd.continent, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date, cd.location) AS cumulative_vaccinations
FROM 
    PortafolioProjectCovid.dbo.CovidVaccinations AS cv
JOIN 
    PortafolioProjectCovid.dbo.CovidDeaths AS cd
ON 
    cv.location = cd.location
    AND cv.date = cd.date
WHERE 
    cd.continent IS NOT NULL
ORDER BY 
    cd.location, 
    cd.continent, 
    cd.date;

-- Total Population Vaccinated Per Country (CTE)
WITH PopVac (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
AS
(
    SELECT
        cd.location, 
        cd.continent, 
        cd.date, 
        cd.population, 
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date, cd.location) AS cumulative_vaccinations
    FROM 
        PortafolioProjectCovid.dbo.CovidVaccinations AS cv
    JOIN 
        PortafolioProjectCovid.dbo.CovidDeaths AS cd
    ON 
        cv.location = cd.location
        AND cv.date = cd.date
	WHERE 
    cd.continent IS NOT NULL
)
SELECT *, (cumulative_vaccinations/population) * 100 AS people_vaccinated_porcentage
FROM PopVac;


--Total Population Vaccinated Per Country (Temp Table)
ALTER TABLE PortafolioProjectCovid.dbo.CovidVaccinations
ALTER COLUMN new_vaccinations float

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    population numeric,
    date datetime,
    new_vaccinations numeric, 
    cumulative_vaccinations numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT
    cd.location, 
    cd.continent, 
    cd.population, 
    cd.date, 
    cv.new_vaccinations, 
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date, cd.location) AS cumulative_vaccinations
FROM 
    PortafolioProjectCovid.dbo.CovidVaccinations AS cv
JOIN 
    PortafolioProjectCovid.dbo.CovidDeaths AS cd
ON 
    cv.location = cd.location
    AND cv.date = cd.date;

SELECT *, (cumulative_vaccinations/population) * 100 AS people_vaccinated_percentage
FROM #PercentPopulationVaccinated;


-- Creating View For Later Visualizations
CREATE VIEW Continents_With_Highest_Death_Count_Per_Population AS
SELECT 
    MAX(date) AS date,
    location,
    MAX(total_deaths) AS highest_deaths_count
FROM 
    PortafolioProjectCovid.dbo.CovidDeaths
WHERE
    continent IS NULL
GROUP BY
    location
--ORDER BY 
--    highest_deaths_count DESC;

CREATE VIEW Countries_with_Highest_Death_Rate_Compared_to_Population AS
SELECT 
    location, 
    MAX(date) AS date,
    population,
    MAX(total_deaths) AS highest_deaths_count,
    MAX(total_cases) AS total_cases,
    (MAX(total_deaths) / population) * 100 AS death_rate_per_country
FROM 
    PortafolioProjectCovid.dbo.CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY 
    location, population
--ORDER BY 
--    death_rate_per_country DESC;

