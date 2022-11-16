-- select the table I will use 
select top 100* from CovidDeaths$
select top 100* from CovidVaccinations$
-- select data I will use in covidDeath table 
select
    location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from CovidDeaths$
order by 1,2

-- Looking at total deaths and total cases
-- show what percentage between total deaths and total cases
select
    location,
	date,
	total_deaths,
	total_cases,
	(total_deaths/total_cases)*100 as Death_percentage
from CovidDeaths$
--where location = 'VietNam'
order by 1,2

-- looking at total cases and population
-- show what percentage of population got covid
select
    location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 as infect_percentage
from CovidDeaths$
--where location like '%VietNam%'
order by 1,2

-- looking at highest infection compare to population of each country
select
    location,
	population,
	Max(total_cases) as highest_infection,
	Max((total_cases/population))*100 as highest_percentage_infection
from CovidDeaths$
group by location,population
order by highest_percentage_infection desc

-- showing countries with highest death count
select 
	location,	
	Max(cast(total_deaths as int)) as total_deaths_count
from CovidDeaths$
where continent is not null
group by location
order by total_deaths_count desc

-- break things down by continent

-- showing continents with the highest death count per population
select
    continent,
	Max(cast(total_deaths as int)) as total_deaths_count
from CovidDeaths$
where continent is not null
group by continent
order by total_deaths_count desc

-- Global number
select
	Sum(new_cases) as total_case,
	Sum(cast(new_deaths as int)) as total_death,
	(sum(new_cases)/Sum(cast(new_deaths as int))) as death_percentage
from CovidDeaths$
where continent is not null
-- use cte
-- looking at total population and vaccinations
with popvsVac as (
select
    dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as People_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
--order by 1,2,3 desc
)
select
    *,
	(People_vaccinated/population)*100
from popvsVac
 
 -- temp table

 drop table if exists #percent_population_vaccinated
 create table #percent_population_vaccinated
 (continent nvarchar(15),
 location nvarchar(25),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 People_vaccinated numeric)
 SET ANSI_WARNINGS OFF
 insert into #percent_population_vaccinated
 select
    dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as People_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
--order by 1,2,3 desc
SET ANSI_WARNINGS On
select *,(People_vaccinated/population)*100
from #percent_population_vaccinated

-- create view for visualization
create view PercentPopulationvaccinated as 
 select
    dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as People_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3 desc