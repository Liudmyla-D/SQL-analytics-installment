/* Returns one row per month between @date_from and @date_to (inclusive, by month) */

IF OBJECT_ID('dbo.my_period','IF') IS NOT NULL
  DROP FUNCTION dbo.my_period;
GO
CREATE FUNCTION dbo.my_period (
  @date_from DATE,
  @date_to   DATE
)
RETURNS @t TABLE (
  p_year  INT,
  p_month INT
)
AS
BEGIN
  DECLARE @d   DATE = DATEFROMPARTS(YEAR(@date_from), MONTH(@date_from), 1);
  DECLARE @end DATE = DATEFROMPARTS(YEAR(@date_to),   MONTH(@date_to),   1);

  WHILE @d <= @end
  BEGIN
    INSERT INTO @t(p_year, p_month) VALUES (YEAR(@d), MONTH(@d));
    SET @d = DATEADD(MONTH, 1, @d);
  END
  RETURN;
END
GO
