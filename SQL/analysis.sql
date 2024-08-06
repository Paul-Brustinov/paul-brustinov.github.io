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
	select  *
	into    #STAT 
	from    sys.dm_db_index_physical_stats(DB_ID('Data_Load'), null, null, null, null) s
	where   avg_fragmentation_in_percent > 10;


	select object_name(s.object_id) as object, i.name, s.* 
	from    #STAT s
	left join    sys.indexes i with (nolock) on i.object_id = s.object_id and i.index_id = s.index_id
	order by 1, 2;

	drop table #STAT;
END

