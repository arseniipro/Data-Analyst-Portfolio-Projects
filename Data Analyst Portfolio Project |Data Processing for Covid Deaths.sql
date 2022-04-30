 -- Overview of the whole data
SELECT
  *
FROM
  owid_covid_data.INFORMATION_SCHEMA.TABLES;

  -- Seting a destination table (resultsovid_deaths) for query
SELECT
  iso_code,
  continent,
  location,
  date,
  population,
  total_cases,
  new_cases,
  new_cases_smoothed,
  total_deaths,
  new_deaths,
  new_deaths_smoothed,
  total_cases_per_million,
  new_cases_per_million,
  new_cases_smoothed_per_million,
  reproduction_rate,
  icu_patients,
  icu_patients_per_million,
  hosp_patients,
  hosp_patients_per_million,
  weekly_icu_admissions,
  weekly_icu_admissions_per_million,
  weekly_hosp_admissions,
  weekly_hosp_admissions_per_million
FROM
  `solar-sylph-346716.owid_covid_data.combined_data`;

  -- Seting a destination table (covid_vaccination) for query
SELECT
  iso_code,
  continent,
  location,
  date,
  total_tests,
  new_tests,
  total_tests_per_thousand,
  new_tests_per_thousand,
  new_tests_smoothed,
  new_tests_smoothed_per_thousand,
  positive_rate,
  tests_per_case,
  tests_units,
  total_vaccinations,
  people_vaccinated,
  people_fully_vaccinated,
  total_boosters,
  new_vaccinations,
  new_vaccinations_smoothed,
  total_vaccinations_per_hundred,
  people_vaccinated_per_hundred,
  people_fully_vaccinated_per_hundred,
  total_boosters_per_hundred,
  new_vaccinations_smoothed_per_million,
  new_people_vaccinated_smoothed,
  new_people_vaccinated_smoothed_per_hundred,
  stringency_index,
  population,
  population_density,
  median_age,
  aged_65_older,
  aged_70_older,
  gdp_per_capita,
  extreme_poverty,
  cardiovasc_death_rate,
  diabetes_prevalence,
  female_smokers,
  male_smokers,
  handwashing_facilities,
  hospital_beds_per_thousand,
  life_expectancy,
  human_development_index,
  excess_mortality_cumulative_absolute,
  excess_mortality_cumulative,
  excess_mortality,
  excess_mortality_cumulative_per_million
FROM
  `solar-sylph-346716.owid_covid_data.combined_data`;

  -- Checking if data has been migrated to new tables successfully
SELECT
  *
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
ORDER BY
  3,
  4;

SELECT
  *
FROM
  `solar-sylph-346716.owid_covid_data.covid_vaccination`
ORDER BY
  3,
  4;

  -- We got two tables, that's a fantastic news. So, now can keep going, select Data that are going to be used

SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
ORDER BY
  location,
  date;

  -- Tootal Cases vs Total Deaths

SELECT
  location,
  date,
  total_cases,
  total_deaths,
  ROUND(((total_deaths / total_cases) * 100), 2) AS DeathPercentage
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
WHERE
  location = 'Finland'
ORDER BY
  location,
  date;

  -- Total Cases vs Population e.g. what percentage of population contract the covid
SELECT
  location,
  date,
  total_cases,
  population,
  ROUND(((total_cases / population) * 100), 3) AS DeathPercentage
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
WHERE
  location = 'Finland'
ORDER BY
  location,
  date;

  -- Countries with higest infection rate
SELECT
  location,
  population,
  MAX(total_cases) AS HighestInfectionCount,
  MAX((total_cases / population) * 100) AS PercentagePopulationInfected
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
GROUP BY
  location,
  population
ORDER BY
  PercentagePopulationInfected DESC;

  -- Coutries with higest death count per popualtion
SELECT
  location,
  MAX(total_deaths) AS TotalDeathCount
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  TotalDeathCount DESC;

  -- Breaking down by continent e.g. continents with the highest death count per population
SELECT
  location AS Continent_Name,
  MAX(total_deaths) AS TotalDeathCount
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
WHERE
  continent IS NULL
  AND location NOT LIKE '%income'
GROUP BY
  Continent_Name
ORDER BY
  TotalDeathCount DESC;

  -- Breaking down by income e.g. income classe with the highest death count per population
SELECT
  location AS Income,
  MAX(total_deaths) AS TotalDeathCount
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
WHERE
  continent IS NULL
  AND location LIKE '%income'
GROUP BY
  location
ORDER BY
  TotalDeathCount DESC;

  -- Global numbers
SELECT
  SUM(new_cases) AS Total_Cases,
  SUM(new_deaths) AS Total_Deaths,
  SUM(new_deaths)/SUM(new_cases) * 100 AS Death_Percentage
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths`
WHERE
  continent IS NOT NULL
ORDER BY
  1,
  2;

  -- Population vs Vaccination
WITH PopvsVac AS (
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_people
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths` AS dea
FULL OUTER JOIN
  `solar-sylph-346716.owid_covid_data.covid_vaccination` AS vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (vaccinated_people/population)*100 AS percentage_vaccinated_people
FROM PopvsVac;

-- Creating view to store data for later viz

CREATE VIEW `.owid_covid_data.covid_percentage_vaccinated_people` AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_people
FROM
  `solar-sylph-346716.owid_covid_data.covid_deaths` AS dea
FULL OUTER JOIN
  `solar-sylph-346716.owid_covid_data.covid_vaccination` AS vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM `solar-sylph-346716.owid_covid_data.covid_percentage_vaccinated_people`