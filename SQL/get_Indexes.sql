select 
     t.name as TableName,
     ind.name as IndexName,
     ind.index_id as IndexId,
     ic.index_column_id as ColumnId,
     col.name as ColumnName,
     ind.*,
     ic.*,
     col.* 
from sys.indexes ind 
  inner join sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
  inner join sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
  inner join sys.tables t ON ind.object_id = t.object_id 

order by   t.name, ind.name, ind.index_id, ic.is_included_column, ic.key_ordinal;
