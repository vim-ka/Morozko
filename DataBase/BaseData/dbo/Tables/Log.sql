CREATE TABLE [dbo].[Log] (
    [LID]    INT          IDENTITY (1, 1) NOT NULL,
    [ND]     DATETIME     DEFAULT (dateadd(day,(0),datediff(day,(0),getdate()))) NULL,
    [Tm]     VARCHAR (8)  DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [OP]     INT          NULL,
    [Tip]    VARCHAR (5)  NULL,
    [Mess]   VARCHAR (80) NULL,
    [Param1] VARCHAR (15) NULL,
    [Param2] VARCHAR (15) NULL,
    [Param3] VARCHAR (15) NULL,
    [Comp]   VARCHAR (12) DEFAULT (host_name()) NULL,
    [Remark] VARCHAR (20) NULL,
    [Param4] VARCHAR (15) NULL,
    UNIQUE NONCLUSTERED ([LID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'комп с которого изменения производились', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Log', @level2type = N'COLUMN', @level2name = N'Comp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'либо Delta  либо Rest:', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Log', @level2type = N'COLUMN', @level2name = N'Param3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'либо Hitag либо ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Log', @level2type = N'COLUMN', @level2name = N'Param2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'либо №накл либо Hitag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Log', @level2type = N'COLUMN', @level2name = N'Param1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'строка содержащая тип действия и описания параметров Param1 Param2 Param3

код номенклатуры заблокирован/разблокирован
накладная добавлена\удалена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Log', @level2type = N'COLUMN', @level2name = N'Mess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логирование в сертификации W8', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Log';

