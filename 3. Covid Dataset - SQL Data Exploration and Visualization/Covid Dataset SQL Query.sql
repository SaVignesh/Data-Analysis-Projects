--Our dataset also contains world and continent data in addition to country data
--So, we will be adding a condition 'WHERE continent is not NULL' to get only country data
--Similarly, we will use 'WHERE continent is NULL' to get world and continent data

--Viewing all data
SELECT *
FROM CovidDB..CovidCases
WHERE continent IS NOT NULL


SELECT *
FROM CovidDB..CovidVaccinations
WHERE continent IS NOT NULL


-- Viewing the Coulmns that we need to Analyse
SELECT continent,location, date, population, total_cases, new_cases, total_deaths, new_deaths
FROM CovidDB..CovidCases
WHERE continent IS NOT NULL
ORDER BY location, date


--Checking Data Types of the columns
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CovidCases' 
AND COLUMN_NAME IN ('continent','location', 'date', 'population', 'total_cases', 
'new_cases', 'total_deaths', 'new_deaths')


SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CovidVaccinations' 
AND COLUMN_NAME IN ('continent','location', 'date', 'population', 'people_vaccinated', 
'new_vaccinations', 'total_vaccinations')


--Changing Data Type of total_cases and total_deaths as they have 'nvarchar' as data type
ALTER TABLE CovidCases ALTER COLUMN total_cases float NULL
ALTER TABLE CovidCases ALTER COLUMN total_deaths float NULL


--Changing Data Type of new_vaccinations, total_vaccinations and people_vaccinated as they have 'nvarchar' as data type
ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations float NULL
ALTER TABLE CovidVaccinations ALTER COLUMN total_vaccinations float NULL
ALTER TABLE CovidVaccinations ALTER COLUMN people_vaccinated float NULL


-- Total casualty rate for each country sorted from highest to lowest
SELECT location, MAX(total_cases) as total_cases, MAX(total_deaths) as total_deaths, 
		(MAX(total_deaths)/MAX(total_cases))*100 AS casualty_rate 
FROM CovidDB..CovidCases
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY casualty_rate DESC


-- Daily percentage of Casualties in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS casualty_rate 
FROM CovidDB..CovidCases
WHERE location = 'India'
ORDER BY date


-- Infection rate for each country sorted from highest to lowest
SELECT location, MAX(population) as population, MAX(total_cases) as total_cases, 
		(MAX(total_cases)/MAX(population))*100 AS infection_rate 
FROM CovidDB..CovidCases
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY infection_rate DESC


-- Daily percentage of people affected by covid in India
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate 
FROM CovidDB..CovidCases
WHERE location = 'India'
ORDER BY date


--Number of Covid Cases for each country sorted from highest to lowest 
SELECT location, MAX(total_cases) as total_cases
FROM CovidDB..CovidCases
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_cases DESC


--Number of Casualties for each country sorted from highest to lowest 
SELECT location, MAX(total_deaths) as total_deaths
FROM CovidDB..CovidCases
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths DESC


--Number of Covid Cases in the world and each Continent sorted from highest to lowest 
SELECT location, MAX(total_cases) as total_cases
FROM CovidDB..CovidCases
WHERE continent IS NULL
GROUP BY location
-- adding below condition as the dataset also has separate location data based on income of people
HAVING location NOT LIKE  '%income'      
ORDER BY total_cases DESC


--Number of Casualties in the world and each Continent sorted from highest to lowest 
SELECT location, MAX(total_deaths) as total_deaths
FROM CovidDB..CovidCases
WHERE continent IS NULL
GROUP BY location
-- adding below condition as the dataset also has separate location data based on income of people
HAVING location NOT LIKE  '%income'
ORDER BY total_deaths DESC


-- Daily percentage of Casualties in the world
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS casualty_rate 
FROM CovidDB..CovidCases
WHERE location = 'World'
ORDER BY date

--Total Cases and Casualties in the world
SELECT MAX(total_cases) as total_cases, MAX(total_deaths) as total_deaths,
	(MAX(total_deaths)/MAX(total_cases))*100 AS casualty_rate 
FROM CovidDB..CovidCases
WHERE location = 'World'


--Finding Cumulative Sum of covid cases for each country to check whether values in total_cases column is correct
WITH cum_sum AS (
SELECT location, date, new_cases, total_cases,
SUM(new_cases) OVER (PARTITION BY location ORDER BY date) cumulative_sum
FROM CovidDB..CovidCases)

SELECT location, MAX(cumulative_sum) cumulative_sum, MAX(total_cases) total_cases
FROM cum_sum
GROUP BY location
ORDER BY location


--Finding the dates when highest number of covid cases were identified for 
--each country sorted from highest to lowest
WITH highest_infection_date_country AS (
	SELECT location, date, new_cases,
	ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_cases DESC) AS row_num
	FROM CovidDB..CovidCases
	WHERE continent IS NOT NULL)

SELECT date, location, new_cases
FROM highest_infection_date_country
WHERE row_num = 1
ORDER BY location

--Finding the dates when highest number of covid cases were identified for 
--the world and continents
WITH highest_infection_date_world AS (
	SELECT location, date, new_cases,
	ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_cases DESC) AS row_num
	FROM CovidDB..CovidCases
	WHERE continent IS NULL
	AND location NOT LIKE  '%income')

SELECT date, location, new_cases
FROM highest_infection_date_world
WHERE row_num = 1
ORDER BY new_cases DESC


--Finding the dates when highest number of casualties were identified for 
--each country sorted from highest to lowest
WITH highest_casualty_date_country AS (
	SELECT location, date, new_deaths,
	ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_deaths DESC) AS row_num
	FROM CovidDB..CovidCases
	WHERE continent IS NOT NULL)

SELECT date, location, new_deaths
FROM highest_casualty_date_country
WHERE row_num = 1
ORDER BY location


--Finding the dates when highest number of casualties were identified for 
--the world and continents
WITH highest_casualty_date_world AS (
	SELECT location, date, new_deaths,
	ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_deaths DESC) AS row_num
	FROM CovidDB..CovidCases
	WHERE continent IS NULL
	AND location NOT LIKE  '%income')

SELECT date, location, new_deaths
FROM highest_casualty_date_world
WHERE row_num = 1
ORDER BY new_deaths DESC

--Percentage of people vaccinated in each country sorted from highest to lowest
SELECT cas.location, MAX(cas.population) AS population, 
	MAX(vac.people_vaccinated) AS people_vaccinated, 
	MAX(vac.people_vaccinated)/MAX(cas.population)*100 as vaccination_rate
FROM CovidDB..CovidCases cas
JOIN CovidDB..CovidVaccinations vac 
	ON cas.location = vac.location
	AND cas.date = vac.date
WHERE cas.continent IS NOT NULL
GROUP BY cas.location
ORDER BY vaccination_rate DESC

--Dates with highest Number of vaccinations for each country
DROP TABLE IF EXISTS #highest_Vaccinations
CREATE TABLE #highest_Vaccinations
(
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
row_num int)

INSERT INTO #highest_Vaccinations
SELECT cas.location, cas.date, cas.population, vac.new_vaccinations, 
	ROW_NUMBER() OVER (PARTITION BY vac.location ORDER BY new_vaccinations DESC) 
	AS row_num
FROM CovidDB..CovidCases cas
JOIN CovidDB..CovidVaccinations vac
	ON cas.location = vac.location
	AND cas.date = vac.date
WHERE cas.continent IS NOT NULL

SELECT location, date, new_vaccinations
FROM #highest_Vaccinations
WHERE row_num = 1
ORDER BY new_vaccinations DESC


--Storing Country data in view for visualization
CREATE OR ALTER VIEW Covid_countries_view AS
SELECT cas.location, cas.date, cas.population, cas.new_cases, cas.total_cases,
	cas.new_deaths, cas.total_deaths, vac.new_vaccinations, vac.total_vaccinations,
	vac.people_vaccinated
FROM CovidDB..CovidCases cas
JOIN CovidDB..CovidVaccinations vac
	ON cas.location = vac.location
	AND cas.date = vac.date
WHERE cas.continent IS NOT NULL


--Storing world and continent data in view for visualization
CREATE OR ALTER VIEW Covid_world_view AS
SELECT cas.location, cas.date, cas.population, cas.new_cases, cas.total_cases,
	cas.new_deaths, cas.total_deaths, vac.new_vaccinations, vac.total_vaccinations,
	vac.people_vaccinated
FROM CovidDB..CovidCases cas
JOIN CovidDB..CovidVaccinations vac
	ON cas.location = vac.location
	AND cas.date = vac.date
WHERE cas.continent IS NULL
AND cas.location NOT LIKE  '%income'

--Storing total world covid cases data in view for visualization
CREATE OR ALTER VIEW total_world_cases_values AS
SELECT MAX(population) AS world_population, MAX(total_cases) as total_cases, MAX(total_deaths) AS total_deaths, 
	(MAX(total_cases)/MAX(population))*100 AS infection_rate,
	(MAX(total_deaths)/MAX(total_cases))*100 AS casualty_rate
FROM CovidDB..CovidCases
WHERE location = 'World'

--Storing continent number of cases data for visualization
CREATE OR ALTER VIEW continent_covid_cases AS
SELECT location, MAX(total_cases) as total_cases
FROM CovidDB..CovidCases
WHERE continent IS NULL
GROUP BY location
-- adding below condition as the dataset also has separate location data based on income of people
HAVING location NOT LIKE  '%income' 
AND location NOT LIKE 'World'



--Storing world vaccination data for visualization
CREATE OR ALTER VIEW world_vaccination_values AS
SELECT MAX(population) as world_population, MAX(people_vaccinated) people_vaccinated, 
	(MAX(people_vaccinated)/MAX(population))*100 AS vaccination_rate
FROM CovidDB..CovidCases cas
JOIN CovidDB..CovidVaccinations vac
	ON cas.location = vac.location
	AND cas.date = vac.date
WHERE cas.location = 'World'

--Storing countrywise total cases data for visualization
CREATE OR ALTER VIEW countrywise_infection_rate AS
SELECT location, MAX(total_cases) AS total_cases, 
	(MAX(total_cases)/(MAX(population)))*100 AS infection_rate
FROM CovidDB..CovidCases
WHERE continent IS NOT NULL
GROUP BY location

--Storing countrywise new cases by date for visualization
CREATE OR ALTER VIEW datewise_infection_rate AS
SELECT location, date, population, MAX(total_cases) as total_cases ,  
	(MAX(total_cases)/(MAX(population)))*100 AS infection_rate
FROM CovidDB..CovidCases
WHERE continent IS NOT NULL
GROUP BY location, date, population