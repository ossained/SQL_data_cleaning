-- Creating staging_data in case of data safety
-- layoffs_staging contains all data from layoffs
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging
;

INSERT layoffs_staging
SELECT * 
FROM layoffs
;

