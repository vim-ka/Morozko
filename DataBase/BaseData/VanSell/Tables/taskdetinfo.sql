CREATE TABLE [VanSell].[taskdetinfo] (
    [id]   INT IDENTITY (1, 1) NOT NULL,
    [tdid] INT NOT NULL,
    [sell] INT CONSTRAINT [DF__taskdetinf__sell__32D8D1C3] DEFAULT ((0)) NULL,
    [pin]  INT CONSTRAINT [DF__taskdetinfo__pin__31E4AD8A] DEFAULT ((-1)) NULL,
    [ord]  INT NULL,
    CONSTRAINT [UQ__taskdeti__3213E83EF6994B64] UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE TRIGGER [VanSell].[taskdetinfo_tri] ON [VanSell].[taskdetinfo]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  declare @tdid int
  declare @pin int
  declare @ord int
  select @tdid = tdid, @pin = pin, @ord = ord from inserted
  if (select count(*) from vansell.taskdetinfo where tdid = @tdid and pin = @pin and ord = @ord) > 1
  BEGIN
    ROLLBACK TRAN
/*  PRINT 
  	'Такой товар уже есть для данного контрагента'*/
  END
END
GO
DISABLE TRIGGER [VanSell].[taskdetinfo_tri]
    ON [VanSell].[taskdetinfo];

