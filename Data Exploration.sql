
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking for total Cases Vs total deaths
--
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths
where location like '%state%'
order by 1,2

 
--Looking for total Cases Vs population
--shows what percentage of population got covid


select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%state%'
order by 1,2


--countries with highest Infection rate compare to population

select location, population, max(total_cases) as HightestInfectionCount, (max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%state%'
group by location, population
order by 4 desc


--Countrues with highest Death Count per Population

select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location, population
order by TotalDeathCount desc


--Continent with highest Death Count per Population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Number

Select /*date,*/ sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
--order by 1,2 

--Total population Vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	   dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on
    dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE

with popvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	   dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on
    dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from popvsVac





--TEMP TABLE




drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	   dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on
    dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as Vaccinated
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations

drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	   dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on
    dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated
