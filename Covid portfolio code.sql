--select * from dbo.CovidDeaths
--select * from CovidVaccination


--Total cases vs Total Death
-- shows the chance of dying if you get infected with Covid in each country
Select Location,Date,Total_Cases,Total_Deaths,(Total_Deaths/Total_Cases)*100 as DeathPercentage
from CovidDeaths
order by 1,2

--Total cases vs population
--shows the percentage of people affected with Covid
Select Location,Date,Total_Cases,Population,(Total_Cases/Population)*100 as InfectedPercentage
from CovidDeaths
order by 1,2


--Countries with highest InfectionRate
Select Location,Population,max(Total_Cases) as HighestCount,max((Total_Cases/Population))*100 as MaxInfectionRate
from CovidDeaths
where Continent is not null
group by Location,Population
order by MaxInfectionRate desc


--Death by continent
select Continent,max(cast(total_Deaths as int)) as TotalDeathCount
from CovidDeaths
where Continent is not null
group by continent
order by TotalDeathCount desc


--global data

select date,sum(new_cases) as TotalGlobalCases, sum(cast(new_deaths as int)) as TotalGlobalDeath,
 (sum(cast(total_deaths as int))/sum(new_cases))* 100 as TotalGlobalDeathPercentage
 from CovidDeaths
 where continent is not null
 group by date
 order by 1,2

 select sum(new_cases) as GlobalCases, sum(cast(new_deaths as int)) as GlobalDeath,
 (sum(cast(new_deaths as int))/sum(new_cases))* 100 as GlobalDeathPercentage
 from CovidDeaths
 where continent is not null
 order by 1,2


 --cte table

 with PopvsVac (Continent,location,Date,population,new_vaccinations,RollingPeopleVaccinated) as(
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 sum(convert(bigint,new_vaccinations)) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
 from CovidDeaths d
 join CovidVaccination v
 on d.location=v.location
 and d.date=v.date
 where d.continent is not null
 and new_vaccinations is not null)

 select *,(RollingPeopleVaccinated/Population)*100 as percentVaccinated from PopvsVac

 --temp table
 IF OBJECT_ID('PercentPopulationVaccinated','U') is not null
 Begin
 DROP TABLE PercentPopulationVaccinated               --2014 edition drop query
 end
 CREATE TABLE PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into PercentPopulationVaccinated
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 sum(convert(bigint,new_vaccinations)) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
 from CovidDeaths d
 join CovidVaccination v
 on d.location=v.location
 and d.date=v.date
 where d.continent is not null
 and new_vaccinations is not null

 select *,(RollingPeopleVaccinated/Population)*100 as percentVaccinated from PercentPopulationVaccinated

 --creating view
 CREATE VIEW PercentPopulationVaccinated_vw as
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 sum(convert(bigint,new_vaccinations)) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
 from CovidDeaths d
 join CovidVaccination v
 on d.location=v.location
 and d.date=v.date
 where d.continent is not null
 and new_vaccinations is not null