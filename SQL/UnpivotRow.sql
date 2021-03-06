	--alter proc UnpivotRow
	declare
		 @TableName  nvarchar(max)
		 ,@Parameter nvarchar(max) = null -- For Table Functions
		 ,@WhereClause  nvarchar(max) = null
		 ,@Sql nvarchar(max) --output
		 
	select @TableName = 'dbo.AGENTS', @WhereClause = 'AG_ID = 71'
	
	--as
	
	declare @TableNameClear nvarchar(max) select @TableNameClear = right(@TableName, len(@TableName)-patindex('%.%', @TableName))
	
	declare @Columns   nvarchar(max) select @Columns   = (select ','+ Cast('['+fld.name+']' as varchar(max))                                          from sysobjects tab left join syscolumns fld on tab.id=fld.id  where tab.name = @TableNameClear and tab.type in (N'TF', N'U') and fld.number = 0 FOR XML PATH(''))
	declare @ColumnsVM nvarchar(max) select @ColumnsVM = (select ','+'['+fld.name+'] = '+ 'Cast('+Cast(fld.name as varchar(max))+' as varchar(max))'  from sysobjects tab left join syscolumns fld on tab.id=fld.id  where tab.name = @TableNameClear and tab.type in (N'TF', N'U') and fld.number = 0 FOR XML PATH(''))
	select @Columns   = substring(@columns  , 2, len(@columns  ))
	select @ColumnsVM = substring(@columnsVM, 2, len(@columnsVM))
	   
	select @Sql = 
	'select unpiv.ColumnName, unpiv.ColumnValue 
		from (	SELECT '+ @columnsVM + ' 
		FROM ' 
				+ @TableName 
				+ case when @Parameter is null or @Parameter = N'' then N'' else N'(' + @Parameter + N')' end
				+ ' ' + case when @WhereClause is null or @WhereClause = N'' then '' else  'where '+ @WhereClause end
			+') pv
		UNPIVOT (ColumnValue FOR ColumnName IN ('+@columns+')) unpiv'

	--select @SQL
	
	EXEC sys.sp_executesql @SQL
	
