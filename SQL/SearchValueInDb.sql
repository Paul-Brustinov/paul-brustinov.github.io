IF OBJECT_ID('tempdb..#srch') IS NOT NULL
DROP TABLE #srch


SELECT c.TABLE_NAME, c.TABLE_SCHEMA, c.COLUMN_NAME 
INTO #srch
FROM INFORMATION_SCHEMA.[COLUMNS] c 
WHERE DATA_TYPE IN ('nvarchar')
ORDER BY TABLE_NAME

DECLARE @cmd VARCHAR(2048)
DECLARE @tbl VARCHAR(100)
DECLARE @tbl_old VARCHAR(100)
DECLARE @clm VARCHAR(100)
DECLARE @own VARCHAR(50)
DECLARE @what VARCHAR(100)
DECLARE @bar INT
DECLARE @i int
SET @cmd=''
SET @what= 'êîâáàñà'
SET @i=1
SET @tbl_old=''

SELECT @bar=COUNT(1) FROM #srch

WHILE EXISTS (SELECT TOP 1 1 from #srch) 
  BEGIN
  	SELECT TOP 1 @own=TABLE_SCHEMA, @tbl=TABLE_NAME, @clm=COLUMN_NAME
  	FROM #srch
  	
  	IF @tbl_old!=@tbl 
  	  BEGIN
  	  	SELECT @cmd='Analyzing table :  '+QUOTENAME(@own)+'.'+QUOTENAME(@tbl)
  	  	PRINT @cmd
  	  END
  	
  	SELECT @cmd='set nocount on; if exists (select 1 from '+QUOTENAME(@own)+'.'+QUOTENAME(@tbl)+' where lower('+QUOTENAME(@clm)+') like ''%'+@what+'%'') '+
  	'select '''+QUOTENAME(@own)+'.'+QUOTENAME(@tbl)+'.'+QUOTENAME(@clm)+''' as [Object], '+
  	     '''select '++QUOTENAME(@clm)+', * from '+QUOTENAME(@own)+'.'+QUOTENAME(@tbl) +
  	        ' where lower('+QUOTENAME(@clm)+') like ''''%'+@what+'%'''''' as [cmd]'
  	
  	--PRINT @cmd
  	EXEC (@cmd)
  	
  	SELECT @i=@i+1
  	IF ((@i*100/@bar)%5)=0
  	   BEGIN
  	   	 SELECT @cmd='************************** Search progress: '+CONVERT(VARCHAR(10),@i*100/@bar)+'% ('+ CONVERT(VARCHAR(10),@i)+' / '+CONVERT(VARCHAR(10),@bar)+')'
  	     PRINT @cmd
  	   END  
  	
  	DELETE #srch
  	WHERE TABLE_SCHEMA=@own
  	AND TABLE_NAME=@tbl
  	AND COLUMN_NAME=@clm
  	
  	SELECT @tbl_old=@tbl
  END 
