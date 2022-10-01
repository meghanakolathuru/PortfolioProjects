SELECT *
FROM PortfolioProject..CovidVaccinations
Where Continent is not null
ORDER BY 3,4

SELECT LOCATION, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where Continent is not null
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS POPULATION

SELECT LOCATION, date, POPULATION, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%STATES%'
AND Continent is not null
ORDER BY 1,2

-- DEATH PERCENTAGE 
SELECT LOCATION, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%STATES%'
AND Continent is not null
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT LOCATION, POPULATION, Max(total_cases) as HighestInfectedRates, Max((total_deaths/total_cases))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
Where Continent is not null
Group by Location, population
ORDER BY PercentagePopulationInfected desc

--Showing countries with highest death count

SELECT LOCATION, POPULATION,  Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
WHERE Continent is not null
Group by Location, population
ORDER BY TotalDeathCount desc

--Let's break things down by continent
--Showing the continent with highest death count per population

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
WHERE Continent is not null
Group by Continent
ORDER BY TotalDeathCount desc

--Global numbers
SELECT Date, Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
WHERE Continent is not null
Group by date
ORDER BY 1,2

--Global numbers without Date

SELECT Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
WHERE Continent is not null
--Group by date
ORDER BY 1,2

-- Looking at total vaccinations vs population

with PopVsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
--We used SQL PARTITION BY to divide the result set into partitions and perform computation on each subset of partitioned data.

	From PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
			on dea.location= vac.location
			and dea.date= vac.date
	WHERE dea.Continent is not null
	--	Order by 2,3
)
Select * ,(RollingPeopleVaccinated/population)*100
from PopVsVac


--Temp Table

Drop Table if exists #PercentagePopulationVaccinated
create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/dea.population)*100
	--We used SQL PARTITION BY to divide the result set into partitions and perform computation on each subset of partitioned data.

	From PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
			on dea.location= vac.location
			and dea.date= vac.date
	--WHERE dea.Continent is not null
	--	Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/dea.population)*100
	--We used SQL PARTITION BY to divide the result set into partitions and perform computation on each subset of partitioned data.

	From PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
			on dea.location= vac.location
			and dea.date= vac.date
	WHERE dea.Continent is not null
	--	Order by 2,3

	select * 
	from PercentagePopulationVaccinated
