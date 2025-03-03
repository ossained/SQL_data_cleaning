-- Final Results

DELIMITER $$
DROP PROCEDURE IF EXISTS `result`;
CREATE PROCEDURE result()
BEGIN
	SELECT * FROM layoffs AS raw_data;
    SELECT * FROM layoffs_staging AS staging_data;
    SELECT * FROM layoffs_staging2 AS cleaned_data;
END $$
DELIMITER ;

CALL result();