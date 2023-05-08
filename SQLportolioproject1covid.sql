Select*
From portfolioproject1..coviddeaths
order by 3,4


--Select*
--From portfolioproject1..covidvaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From portfolioproject1..coviddeaths
order by 1,2

--Looking at the total cases vs total deaths
--Shows likelihood of dying if you contract COVID in your country
Select location, date, total_cases, total_deaths, CAST(total_deaths AS float)/CAST (total_cases AS float)*100 as DeathPercentage
From portfolioproject1..coviddeaths
Where location like '%state%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population contracted COVID

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From portfolioproject1..coviddeaths
Where location like '%state%'
order by 1,2

--Looking at Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioproject1..coviddeaths
--Where locaiton like %state%
Group by location, population
order by percentpopulationinfected desc

--Showing countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioproject1..coviddeaths
--Where location like %state%
Where continent is not null
Group by location
order by TotalDeathCount desc

--Breaking things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioproject1..coviddeaths
--Where location like %state%
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing the continents with the highest death count per population


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(cast(New_cases as int))*100 as DeathPercentage
From portfolioproject1..coviddeaths
--Where location like '%state%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
From portfolioproject1..coviddeaths dea
Join  portfolioproject1..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From portfolioproject1..coviddeaths dea
Join  portfolioproject1..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select* , (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From portfolioproject1..coviddeaths dea
Join  portfolioproject1..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (Rollingpeoplevaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From portfolioproject1..coviddeaths dea
Join  portfolioproject1..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
