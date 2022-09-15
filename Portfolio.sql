-- select the table I will use 
select top 100* from CovidDeaths$
select top 100* from CovidVaccinations$
-- select data I will use in covidDeath table 
select
    location,
	date,
	continent,
	total_cases,
	new_cases,
	total_deaths,
	new_deaths,
	population
from CovidDeaths$
order by location,date
--select data i will use in covidvaccination table
select
    location,
	continent,
	date,
	total_vaccinations,
	people_vaccinated,
	people_fully_vaccinated
from CovidVaccinations$
order by location,date

-- Looking at total deaths and total cases
-- show what percentage between total deaths and total cases
select
    location,
	date,
    isnull(total_cases,0) as total_cases,
	isnull(total_deaths,0) as total_deaths,
	(isnull(total_deaths,0)/total_cases)*100 as ratio_totaldeaths_to_totalcases
from CovidDeaths$
order by 1,2

-- looking at total cases and population
-- show what percentage of population get covid
select
    location,
	date,
	population,
    isnull(total_cases,0) as total_cases,
	(isnull(total_cases,0)/population)*100 as infection_percentage
from CovidDeaths$
order by 1,2

--looking at total deaths and population
-- show avantage of population dead by covid
select
    location,
	date,
	population,
    isnull(total_deaths,0) as total_deaths,
	(isnull(total_deaths,0)/population)*100 as ratio_total_cases_to_populations
from CovidDeaths$
order by 1,2

-- looking at highest infection compare to population of each country
select
    location,
	population,
	Max(total_cases) as highest_infection,
	Max(isnull(total_cases,0)*100/population) as highest_percentage_infection
from CovidDeaths$
group by location,population
order by highest_percentage_infection desc

-- looking at highest death by covid compare to population of each countryselect
select 
	location,
	population,
	Max(total_deaths) as highest_deaths,
	Max(isnull(total_deaths,0)*100/population) as highest_percentage_death
from CovidDeaths$
group by location,population
order by highest_percentage_death desc

-- looking at the highest death at each country
select
    location,
	max(total_deaths) as highest_death
from CovidDeaths$
group by location
order by highest_death desc

-- looking at highest cases at each country
select
    location,
	max(total_cases) as highest_cases
from CovidDeaths$
group by location
order by highest_cases desc

-- Showing the increase rate of cases in the country
select
    location,
	date,
	isnull((total_cases - lag(total_cases,1) over(order by location))/lag(total_cases,1) over(order by location),0)as increase_rate,
	case
         when isnull((total_cases - lag(total_cases,1) over(order by location))/lag(total_cases,1) over(order by location),0) > 0 then 'up'
		 when isnull((total_cases - lag(total_cases,1) over(order by location))/lag(total_cases,1) over(order by location),0) = 0 then 'not change'
	     else 'down'
	end as situation
from CovidDeaths$
-- showing the increase rate of death tn the country
select
    location,
	date,
	isnull((cast(total_deaths as int) - lag(cast(total_deaths as int),1) over(order by location))/lag(cast(total_deaths as int),1) over(order by location),0)as increase_rate,
	case
         when isnull((cast(total_deaths as int) - lag(cast(total_deaths as int),1) over(order by location))/lag(cast(total_deaths as int),1) over(order by location),0) > 0 then 'up'
		 when isnull((cast(total_deaths as int) - lag(cast(total_deaths as int),1) over(order by location))/lag(cast(total_deaths as int),1) over(order by location),0) = 0 then 'not change'
	     else 'down'
	end as situation
from CovidDeaths$

--CONTINENT NUMBER ABOUT COVID19 SITUATION
select
    continent,
	date,
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths
from CovidDeaths$
where continent is not null
group by continent,date
order by continent

--GLOBAL NUMBER ABOUT COVID19 SITUATION
select
    date,
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths
from CovidDeaths$
group by date
order by date
--

-- Country number about vaccinations
-- looking at precentage between vaccinations and population
select
    CD.location,
	population,
	isnull(total_vaccinations,0) as total_vaccinations,
	Format((isnull(total_vaccinations,0)/population),'P') as percentage_vaccinations_populations
from CovidDeaths$ as CD
join CovidVaccinations$ as vaccin
on CD.location = vaccin.location
order by Cd.location

-- looking at percentage between people vaccinated and population
select
    CD.location,
	population,
	isnull(people_vaccinated,0) as people_vaccinated,
	Format((isnull(people_vaccinated,0)/population),'P') as percentage_peoplevaccinated_populations
from CovidDeaths$ as CD
join CovidVaccinations$ as vaccin
on CD.location = vaccin.location
order by Cd.location

--looking at percentage between people full vaccinated and population
select
    CD.location,
	population,
	isnull(people_fully_vaccinated,0) as people_vaccinated,
	Format((isnull(people_fully_vaccinated,0)/population),'P') as percentage_people_fully_vaccinated_populations
from CovidDeaths$ as CD
join CovidVaccinations$ as vaccin
on CD.location = vaccin.location
order by Cd.location

-- Showing the highest percentage between vaccinations and population of each country
select
    CD.location,
	max(Format((isnull(total_vaccinations,0)/population),'P')) as highest_percentage
from CovidDeaths$ as CD
join CovidVaccinations$ as vaccin
on CD.location = vaccin.location
Group by CD.location
order by highest_percentage desc
-- Showing the highest percentage between people vaccinated and population
select
    CD.location,
	max(Format((isnull(people_vaccinated,0)/population),'P')) as highest_percentage_people_vaccinated
from CovidDeaths$ as CD
join CovidVaccinations$ as vaccin
on CD.location = vaccin.location
Group by CD.location
order by highest_percentage_people_vaccinated desc

-- Showing the highest percentage between people fully vaccinated and population
select
    CD.location,
	max(Format((isnull(people_fully_vaccinated,0)/population),'P')) as highest_percentage_people_fully_vaccinated
from CovidDeaths$ as CD
join CovidVaccinations$ as vaccin
on CD.location = vaccin.location
Group by CD.location
order by highest_percentage_people_fully_vaccinated desc

-- Continent number about vaccination
select
    continent,
	date,
	Sum(cast(isnull(new_vaccinations,'0') as float)) as total_vaccinations,
	Sum(cast(isnull(people_vaccinated,'0') as float)) as total_people_vaccinated,
	Sum(cast(isnull(people_fully_vaccinated,'0') as float)) as total_people_fully_vaccinated
from CovidVaccinations$
where continent is not null
group by continent,date
order by continent

--Gloabal number about vaccination
select
	date,
	Sum(cast(isnull(new_vaccinations,'0') as float)) as total_vaccinations,
	Sum(cast(isnull(people_vaccinated,'0') as float)) as total_people_vaccinated,
	Sum(cast(isnull(people_fully_vaccinated,'0') as float)) as total_people_fully_vaccinated
from CovidVaccinations$
group by date
order by date










