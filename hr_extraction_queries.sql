use hr_workforce_analytics;
-- SELECT * FROM ibm_hr_data_clean;
USE hr_workforce_analytics;

-- Step 1: Clean up, build Demographics, and fix the Age column name
DROP TABLE IF EXISTS employee_demographics_dimension;

CREATE TABLE employee_demographics_dimension AS
SELECT DISTINCT 
    `EmployeeNumber` AS employee_id,
    `ï»¿Age` AS Age,              -- <--- This line fixes the glitch instantly!
    `Gender`,
    `MaritalStatus`,
    `EducationField`
FROM ibm_hr_data_clean;
-- Step 2: Clean up and build the central Job Performance Fact Table
DROP TABLE IF EXISTS job_performance_fact;

CREATE TABLE job_performance_fact AS
SELECT 
    `EmployeeNumber` AS employee_id,
    `Department`,
    `JobRole`,
    `MonthlyIncome`,
    `PercentSalaryHike`,
    `YearsAtCompany`,
    `PerformanceRating`,
    CASE WHEN `Attrition` = 'Yes' THEN 1 ELSE 0 END AS attrition_flag
FROM ibm_hr_data_clean;

SELECT * FROM employee_demographics_dimension LIMIT 5;
SELECT * FROM job_performance_fact LIMIT 5;

WITH DepartmentSalaries AS (
    SELECT 
        j.`Department`,
        j.`JobRole`,
        AVG(j.`MonthlyIncome`) AS avg_income,
        SUM(j.`attrition_flag`) AS total_resignations,
        DENSE_RANK() OVER (PARTITION BY j.`Department` ORDER BY AVG(j.`MonthlyIncome`) DESC) as income_rank
    FROM job_performance_fact j
    GROUP BY j.`Department`, j.`JobRole`
)
SELECT * FROM DepartmentSalaries 
WHERE income_rank <= 3;

