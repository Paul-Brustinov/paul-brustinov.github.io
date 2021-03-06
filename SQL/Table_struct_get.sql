select c.name, TYPE_NAME(c.system_type_id)
  + case 
  when TYPE_NAME(c.system_type_id) = 'nvarchar' then 
    N'(' + 
        case when c.max_length <> -1 then cast(c.max_length /2 as nvarchar(10)) else 'max' end
        + N')'
        when TYPE_NAME(c.system_type_id) = 'varchar' then 
     N'(' + 
        case when c.max_length <> -1 then cast(c.max_length as nvarchar(10)) else 'max' end
        + N')'
         else ''
      end
  from sys.objects o
	  inner join sys.columns c on o.object_id = c.object_id
  where o.object_id = OBJECT_ID('dbo.Agents')
  order by c.name
