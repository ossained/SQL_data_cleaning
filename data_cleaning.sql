-- DATA CLEANING

SELECT *
FROM layoffs
;

-- 1. Remove Duplicates
-- 2. Standardize data 
-- 3. Deal with null/blank values
-- 4. Remove unnecessary columns


-- 1. REMOVE DUPLICATES


SELECT *
FROM layoffs_staging
;

SELECT *,
ROW_NUMBER() OVER (PARTITION BY 
company, location, industry, total_laid_off,
percentage_laid_off, 'date', stage, country,
funds_raised_millions) AS row_num
FROM layoffs_staging
;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY 
company, location, industry, total_laid_off,
percentage_laid_off, 'date', stage, country,
funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging
WHERE company = 'Better.com'
;

-- layoff_staging2 contains data from layoff_staging with removed duplicates entries, standardized data
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (PARTITION BY 
company, location, industry, total_laid_off,
percentage_laid_off, 'date', stage, country,
funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE company = 'Better.com';


-- 2. STANDARDIZED DATA : Finding issue in data and fixing it

SELECT *
FROM layoffs_staging2;

-- TRIM data
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company)
;

-- Generalize data

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

-- changing datatypes if required (here date is in text datatype)

SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') 
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. WORKING WITH NULL/BLANK VALUES


SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
 
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
 
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;

-- Deleting unwanted rows (blank/null values)

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;


-- 4. REMOVE UNWANTED COLUMN (in this case row_num is of no use now)
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

-- layoffs_staging2 is final cleaned data
