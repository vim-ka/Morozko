CREATE TABLE [dbo].[tdviLog] (
    [ND]         DATETIME        NULL,
    [STARTID]    INT             NOT NULL,
    [NCOM]       INT             NULL,
    [NCOD]       INT             NULL,
    [DATEPOST]   DATETIME        NULL,
    [PRICE]      DECIMAL (13, 2) NULL,
    [START]      DECIMAL (12, 3) NULL,
    [STARTTHIS]  DECIMAL (12, 3) NULL,
    [HITAG]      INT             NULL,
    [SKLAD]      SMALLINT        NULL,
    [COST]       DECIMAL (13, 5) NULL,
    [NALOG5]     DECIMAL (1)     NULL,
    [MINP]       INT             NULL,
    [MPU]        INT             NULL,
    [SERT_ID]    INT             NULL,
    [RANG]       CHAR (1)        NULL,
    [MORN]       DECIMAL (12, 3) NOT NULL,
    [SELL]       DECIMAL (12, 3) NOT NULL,
    [ISPRAV]     DECIMAL (12, 3) NOT NULL,
    [REMOV]      DECIMAL (12, 3) NOT NULL,
    [BAD]        DECIMAL (12, 3) NOT NULL,
    [DATER]      DATETIME        NULL,
    [SROKH]      DATETIME        NULL,
    [COUNTRY]    VARCHAR (50)    NULL,
    [REZERV]     DECIMAL (12, 3) NULL,
    [UNITS]      VARCHAR (3)     NULL,
    [LOCKED]     BIT             NULL,
    [NCOUNTRY]   DECIMAL (3)     NULL,
    [GTD]        VARCHAR (100)   NULL,
    [VITR]       DECIMAL (12, 3) NULL,
    [OUR_ID]     SMALLINT        NULL,
    [WEIGHT]     DECIMAL (12, 3) NOT NULL,
    [SaveDate]   DATETIME        NULL,
    [MeasId]     TINYINT         NULL,
    [OnlyMinP]   BIT             NULL,
    [AddrID]     INT             NULL,
    [DCK]        INT             NOT NULL,
    [ProducerID] INT             NULL,
    [CountryID]  INT             NULL,
    [wsID]       TINYINT         NULL,
    [safeCust]   BIT             NULL,
    [Price_old]  DECIMAL (13, 2) NULL,
    [LockID]     INT             NULL,
    [PinOwner]   INT             NULL,
    [DCKOwner]   INT             NULL,
    [pin]        INT             NULL,
    [LogID]      INT             IDENTITY (1, 1) NOT NULL,
    [ID]         INT             NOT NULL,
    [type]       SMALLINT        NULL,
    [user_name]  NVARCHAR (256)  DEFAULT (suser_sname()) NULL,
    [datetime]   DATETIME        DEFAULT (getdate()) NULL,
    [host_name]  NCHAR (30)      DEFAULT (host_name()) NULL,
    [app_name]   NVARCHAR (128)  DEFAULT (app_name()) NULL
);


GO
CREATE NONCLUSTERED INDEX [tdviLog_idx]
    ON [dbo].[tdviLog]([ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tdviLog', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tdviLog', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tdviLog', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tdviLog', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tdviLog', @level2type = N'COLUMN', @level2name = N'type';

