declare @p nvarchar(120) = N'%Agent%'

select SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(o.object_id) --*
from sys.objects o
where OBJECT_DEFINITION(o.object_id) like @p

select SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(o.object_id), o.type, c.*
from sys.columns c
	inner join sys.objects o on o.object_id = c.object_id
where c.name like @p
  and o.type <> 'V'
order by o.name
