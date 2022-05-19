SELECT *
FROM project..covid_deaths
ORDER BY 3,4


SELECT *
FROM project..covid_vaccinations
ORDER BY 3,4

--Looking at total cases vs total deaths in India
-- Likelihood of death if covid is contracted in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_to_case_percentage
FROM project..covid_deaths
WHERE location LIKE '%India%'
ORDER BY 1,2 DESC

-- total cases vs population
-- Percent of population that got covid in India
SELECT location, date, total_cases, population, (total_cases/population)*100 AS case_to_population
FROM project..covid_deaths
WHERE location LIKE '%India%'
ORDER BY 1,2

-- Country with highest infection rate
SELECT location,MAX(total_cases) AS highest_cases, MAX(population) AS population, (MAX(total_cases)/MAX(population))*100 AS infection_rate
FROM project..covid_deaths
GROUP BY location,population
ORDER BY infection_rate DESC

 --Continent with highest death rate
SELECT location, MAX(cast(total_deaths AS bigint)) AS current_deaths, MAX(population) AS population, (MAX(cast(total_deaths AS bigint))/MAX(population)) AS death_rate
FROM project..covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 4 DESC


-- Continents with highest death count per population
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From project..covid_deaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Continents with highest death count *right way
--Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
--From project..covid_deaths
--Where continent IS null 
--Group by location
--order by TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT MAX(total_cases) as Total_cases, MAX(cast(total_deaths AS bigint)) AS total_deaths, (MAX(cast(total_deaths AS bigint))/MAX(total_cases))*100 AS death_to_case_percentage
FROM project..covid_deaths
--WHERE continent IS NOT NULL
----GROUP BY continent,date
--ORDER BY 1,2 DESC

--Population that have received atleast one vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..covid_deaths dea
Join project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations IS NOT NULL
order by 2,3


-- Using CTE to calculate Rolling population vaccination
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..covid_deaths dea
Join project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS rolling_vac_per_population
From PopvsVac
