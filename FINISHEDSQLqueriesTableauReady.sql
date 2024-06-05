Select *
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
Where continent is not null
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
order by 1,2



--Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if contracted in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage --no conversion null
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
Where location like '%states%'
order by 1,2



Select Location, date, total_cases,total_deaths, 
(convert(decimal,total_deaths)/NULLIF(CONVERT(decimal, total_cases),0)) * 100 AS Deathpercentage --change to decimal, wont work with float or numeric value
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
Where location like '%states%'
order by 1,2


Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage --YT commenter query
from [JACKSON-COVID-Portfolio-Project]..covidDeaths
order by 1,2


--Looking at total cases vs Population 
--Shows what % of People tested postive for Covid

Select location, date, total_cases, Population, (total_cases/Population)*100 as DeathPercentage
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
--where locatin like '%states%'\
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Population, must convert total_deaths to int

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
--where locatin like '%states%'\
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the Continents with the highest death count

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
--where locatin like '%states%'\
Where continent is null
Group by location
order by TotalDeathCount desc


-- Looking at continents with highest infection rate compared to population 

Select continent, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
--where location like '%states%'
--where continent is not null
Group by continent, population
order by PercentPopulationInfected desc


-- GLOBAL Numbers for entire globe no grouping

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM (New_cases)*100 as Deathpercentage
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
--Where location like '%states'
where continent is not null
--group by date 
order by 1,2


-- GLOBAL grouped by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM (New_cases)*100 as Deathpercentage
From [JACKSON-COVID-Portfolio-Project]..CovidDeaths
--Where location like '%states'
where continent is not null
group by date 
order by 1,2


--Joined tables, Looking at total population vs vaccinations
-- Would like to showcase rolling vaccinations, by location and date, use sum and partition
-- partition needs to run through table and count sum for each country, then count resets upon new country value


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [JACKSON-COVID-Portfolio-Project]..CovidDeaths dea
join [JACKSON-COVID-Portfolio-Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE , in order to use our previous query and use it for calculations in our new query 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [JACKSON-COVID-Portfolio-Project]..CovidDeaths dea
join [JACKSON-COVID-Portfolio-Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- Temp Table with toggle drop

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [JACKSON-COVID-Portfolio-Project]..CovidDeaths dea
join [JACKSON-COVID-Portfolio-Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- CREATING VIEW to store data for later visualizations Tableau


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [JACKSON-COVID-Portfolio-Project]..CovidDeaths dea
join [JACKSON-COVID-Portfolio-Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated
