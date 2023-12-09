CREATE TABLE [dbo].[MarshLoad] (
    [ml]      INT         IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME    DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]      VARCHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Marsh]   INT         NULL,
    [NDMarsh] DATETIME    NULL,
    [begTM]   DATETIME    DEFAULT (getdate()) NULL,
    [endTM]   DATETIME    NULL,
    [OP]      INT         NULL,
    [mhid]    INT         NULL,
    PRIMARY KEY CLUSTERED ([ml] ASC),
    CONSTRAINT [MarshLoad_fk] FOREIGN KEY ([mhid]) REFERENCES [dbo].[Marsh] ([mhid]) ON DELETE SET NULL
);


GO
CREATE TRIGGER [dbo].[MarshLoad_triu] ON [dbo].[MarshLoad]
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE
AS
declare @begTM varchar(5), @ND datetime, @Marsh int, @endTM varchar(5)
BEGIN
  select @begTM = CONVERT([varchar](5),begTM,(108)),
         @endTM = CONVERT([varchar](5),endTM,(108)),
         @ND=NDMarsh, @Marsh=Marsh from inserted;
  if @begTM is not Null update Marsh set TimeStart=@begTM where ND=@ND and Marsh=@Marsh;
  if @endTM is not Null update Marsh set TimeFinish=@endTM where ND=@ND and Marsh=@Marsh;
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshLoad', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Завершение погрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshLoad', @level2type = N'COLUMN', @level2name = N'endTM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начало погрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshLoad', @level2type = N'COLUMN', @level2name = N'begTM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshLoad', @level2type = N'COLUMN', @level2name = N'NDMarsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshLoad', @level2type = N'COLUMN', @level2name = N'Marsh';

