select 
	SCHEMA_NAME(e.schema_id) +'.'+ object_name(a.parent_object_id) as ParentTable
  ,SCHEMA_NAME(f.schema_id) +'.'+ object_name(b.referenced_object_id) as ReferencedTable
  
	,'ALTER TABLE '+ SCHEMA_NAME(e.schema_id) +'.'+ object_name(a.parent_object_id) 
  + ' DROP CONSTRAINT ' + a.name
  
	,'ALTER TABLE '+ SCHEMA_NAME(e.schema_id) +'.'+ object_name(a.parent_object_id) +
  ' ADD CONSTRAINT '+ a.name +
    ' FOREIGN KEY (' + c.name + ') REFERENCES ' +
    object_name(b.referenced_object_id) +
    ' (' + d.name + ')'
    
from    sys.foreign_keys a
    inner join sys.foreign_key_columns b on a.object_id=b.constraint_object_id
    inner join sys.columns c on b.parent_column_id = c.column_id and a.parent_object_id=c.object_id
    inner join sys.columns d on b.referenced_column_id = d.column_id and a.referenced_object_id = d.object_id
		inner join sys.objects e on c.object_id = e.object_id
    inner join sys.objects f on d.object_id = f.object_id
    
where   b.referenced_object_id in (object_id('dbo.Agents'))
and SCHEMA_NAME(e.schema_id) not in ('', '')
order by SCHEMA_NAME(f.schema_id) +'.'+ object_name(b.referenced_object_id), c.name
