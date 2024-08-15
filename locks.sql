--to lock virtual resource and prevent deadlock
BEGIN TRANSACTION
  EXEC sp_getapplock @Resource = 'WorkspaceGroupingLock', @LockMode = 'Exclusive'
  EXEC sp_releaseapplock @Resource = 'WorkspaceGroupingLock'
COMMIT

--to lock some rows
BEGIN TRANSACTION
    SELECT * FROM [TableName] WITh(XLOCK, HOLDLOCK)
    SELECT * FROM [TableName] WITh(XLOCK, SERIALISABLE)
COMMIT

