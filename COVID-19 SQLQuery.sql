SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--Select Data that we are going to be using
-- SELECT *
--FROM PortfolioProject..CovidVaccinations
-- order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2 

-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you were to contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location, Population
order by TotalDeathCount desc

--Let's break things down by continent


--Showing Continents with Highest Death Count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--Group by date
order by 1,2 


--Looking at Total Population vs Vacciantions
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	order by 2,3

	--USE CTE

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3
	)
	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac

	--TEMP TABLE

	Create Table #PercentPoulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime, 
	Population numeric,
	New_vaccinations numeric, 
	RollingPeopleVaccinated numeric
	)

	Insert into #PercentPoulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPoulationVaccinated



	--Creating View to store data for later visaulization

	Create View PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3
