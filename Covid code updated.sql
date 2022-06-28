--select * from dbo.CovidDeaths
--select * from CovidVaccination

--Total cases vs Total Death
-- shows the chance of dying if you get infected with Covid in each country

SELECT   location,
         Max(total_deaths)/Max(total_cases) AS Death_percentage
FROM     coviddeaths
GROUP BY location
ORDER BY location


--Total cases vs population
--shows the percentage of people affected with Covid

SELECT   location,
         Max(total_cases)/Max(population) AS InfectedPercentage
FROM     coviddeaths
GROUP BY location
ORDER BY location


--Countries with highest InfectionRate

SELECT   location,
         population,
         Max(total_cases)                  AS HighestCount,
         Max((total_cases/population))*100 AS MaxInfectionRate
FROM     coviddeaths
WHERE    continent IS NOT NULL
GROUP BY location,
         population
ORDER BY maxinfectionrate DESC


--Death by continent

SELECT   continent,
         Max(Cast(total_deaths AS INT)) AS TotalDeathCount,
         Max(total_cases)               AS TotalCases
FROM     coviddeaths
WHERE    continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC


--global data

SELECT   date,
         Sum(new_cases)                                       AS TotalGlobalCases,
         Sum(Cast(new_deaths AS INT))                         AS TotalGlobalDeath,
         (Sum(Cast(total_deaths AS INT))/Sum(new_cases))* 100 AS TotalGlobalDeathPercentage
FROM     coviddeaths
WHERE    continent IS NOT NULL
GROUP BY date
ORDER BY 1,
         2SELECT   Sum(new_cases)                                     AS globalcases,
         Sum(Cast(new_deaths AS INT))                       AS globaldeath,
         (Sum(Cast(new_deaths AS INT))/Sum(new_cases))* 100 AS globaldeathpercentage
FROM     coviddeaths
WHERE    continent IS NOT NULL
ORDER BY 1,
         2


--cte table

with popvsvac
     (
          continent,
          location,
          date,
          population,
          new_vaccinations,
          rollingpeoplevaccinated
     )
     AS
     (
              SELECT   d.continent,
                       d.location,
                       d.date,
                       d.population,
                       v.new_vaccinations,
                       sum(CONVERT(bigint,new_vaccinations)) OVER(partition BY d.location ORDER BY d.location,d.date) AS rollingpeoplevaccinated
              FROM     coviddeaths d
              JOIN     covidvaccination v
              ON       d.location=v.location
              AND      d.date=v.date
              WHERE    d.continent IS NOT NULL
              AND      new_vaccinations IS NOT NULL
     )SELECT                        *,
       rollingpeoplevaccinated/population*100 AS percentVaccinated
FROM   popvsvac


--temp table

IF Object_id('PercentPopulationVaccinated','U') IS NOT NULL
BEGIN
  DROP TABLE percentpopulationvaccinated --2014 edition drop query
ENDCREATE TABLE percentpopulationvaccinated
             (
                          continent               NVARCHAR(255),
                          location                NVARCHAR(255),
                                                  date DATETIME,
                          population              NUMERIC,
                          new_vaccinations        NUMERIC,
                          rollingpeoplevaccinated NUMERIC
             )INSERT INTO percentpopulationvaccinated
SELECT   d.continent,
         d.location,
         d.date,
         d.population,
         v.new_vaccinations,
         Sum(CONVERT(BIGINT,new_vaccinations)) OVER(partition BY d.location ORDER BY d.location,d.date) AS RollingPeopleVaccinated
FROM     coviddeaths d
JOIN     covidvaccination v
ON       d.location=v.location
AND      d.date=v.date
WHERE    d.continent IS NOT NULL
AND      new_vaccinations IS NOT NULLSELECT *,
       (rollingpeoplevaccinated/population)*100 AS percentVaccinated
FROM   percentpopulationvaccinated


--creating view

CREATE VIEW percentpopulationvaccinated_vw AS
SELECT   d.continent,
         d.location,
         d.date,
         d.population,
         v.new_vaccinations,
         Sum(CONVERT(BIGINT,new_vaccinations)) OVER(partition BY d.location ORDER BY d.location,d.date) AS RollingPeopleVaccinated
FROM     coviddeaths d
JOIN     covidvaccination v
ON       d.location=v.location
AND      d.date=v.date
WHERE    d.continent IS NOT NULL
AND      new_vaccinations IS NOT NULL