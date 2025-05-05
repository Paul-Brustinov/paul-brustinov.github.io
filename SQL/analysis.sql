--print statistics

SET STATISTICS IO ON;
SELECT * FROM AGENTS
SET STATISTICS IO OFF;

--index usage
BEGIN
	SELECT DB_NAME(DATABASE_ID) AS DATABASENAME, 
		   SCHEMA_NAME(C.SCHEMA_id) AS SCHEMANAME, 
		   OBJECT_NAME(B.OBJECT_ID) AS TABLENAME, 
		   INDEX_NAME = (SELECT NAME 
						 FROM   SYS.INDEXES A 
						 WHERE  A.OBJECT_ID = B.OBJECT_ID 
						   AND  A.INDEX_ID = B.INDEX_ID), 
		   USER_SEEKS, 
		   USER_SCANS, 
		   USER_LOOKUPS, 
		   USER_UPDATES 
	FROM   SYS.DM_DB_INDEX_USAGE_STATS B 
		   INNER JOIN SYS.OBJECTS C ON B.OBJECT_ID = C.OBJECT_ID 
	WHERE  DATABASE_ID = DB_ID(DB_NAME()) 
		   AND C.TYPE = 'U' 
	--	   AND OBJECT_NAME(B.OBJECT_ID) = 'ObjectName'
	ORDER BY 2, 3, 4

	-- not used indexes
	SELECT DB_NAME() AS DATABASENAME, 
		   SCHEMA_NAME(A.SCHEMA_id) AS SCHEMANAME, 
		   OBJECT_NAME(B.OBJECT_ID) AS TABLENAME, 
		   B.NAME AS INDEXNAME, 
		   B.INDEX_ID 
	FROM   SYS.OBJECTS A 
		   INNER JOIN SYS.INDEXES B ON A.OBJECT_ID = B.OBJECT_ID 
	WHERE  NOT EXISTS (SELECT * 
					   FROM  SYS.DM_DB_INDEX_USAGE_STATS C 
					   WHERE DATABASE_ID = DB_ID(DB_NAME())
						 AND B.OBJECT_ID = C.OBJECT_ID 
						 AND B.INDEX_ID = C.INDEX_ID) 
		   AND A.TYPE = 'U' 
	ORDER BY 1, 2, 3

END

--index fragmentation
BEGIN
SELECT 
    dbschemas.[name] AS [Schema], 
    dbtables.[name] AS [Table], 
    dbindexes.[name] AS [Index], 
    indexstats.avg_fragmentation_in_percent,
    indexstats.page_count
FROM 
    sys.dm_db_index_physical_stats(DB_ID('Data_Load'), NULL, NULL, NULL, NULL) AS indexstats
    INNER JOIN sys.tables dbtables ON dbtables.[object_id] = indexstats.[object_id]
    INNER JOIN sys.schemas dbschemas ON dbtables.[schema_id] = dbschemas.[schema_id]
    INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
    AND indexstats.index_id = dbindexes.index_id
--WHERE 
--    indexstats.avg_fragmentation_in_percent > 10  -- Пороговое значение фрагментации
ORDER BY 
    1, 2
END

---------------------------------------------------------------------------------------------
-- diagnostic messages
DECLARE @t INT, @d DATETIME;
SET @t = DATEDIFF(ss, @d, GETUTCDATE()); SET @d = GETUTCDATE(); RAISERROR('D : %d', 0, 1, @t) WITH NOWAIT;


