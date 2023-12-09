CREATE TABLE [dbo].[NCLOG] (
    [ND]           DATETIME        NULL,
    [B_ID]         INT             NOT NULL,
    [Fam]          VARCHAR (35)    NULL,
    [TM]           CHAR (8)        NULL,
    [Op]           INT             NULL,
    [SP]           MONEY           NOT NULL,
    [SC]           MONEY           NOT NULL,
    [Extra]        DECIMAL (6, 2)  NULL,
    [Srok]         INT             NOT NULL,
    [Fact]         MONEY           NULL,
    [OurID]        TINYINT         NULL,
    [Pko]          TINYINT         NULL,
    [man_id]       TINYINT         NULL,
    [BankId]       TINYINT         NULL,
    [Tovchk]       TINYINT         NULL,
    [Frizer]       TINYINT         NULL,
    [Ag_Id]        INT             NULL,
    [StfNom]       VARCHAR (17)    NULL,
    [StfDate]      DATETIME        NULL,
    [Qtyfriz]      INT             NULL,
    [Remark]       VARCHAR (255)   NULL,
    [Printed]      TINYINT         NULL,
    [Marsh]        INT             NULL,
    [BoxQty]       DECIMAL (8, 2)  NULL,
    [Weight]       DECIMAL (8, 2)  NULL,
    [Actn]         TINYINT         NULL,
    [CK]           TINYINT         NULL,
    [Tara]         TINYINT         NULL,
    [RefDatnom]    BIGINT          NOT NULL,
    [MarshDay]     TINYINT         NULL,
    [Sk50prn]      TINYINT         NULL,
    [SPice]        MONEY           NULL,
    [SCice]        MONEY           NULL,
    [Izmen]        MONEY           NULL,
    [Back]         MONEY           NULL,
    [SpPF]         MONEY           NULL,
    [ScPF]         MONEY           NULL,
    [SpOther]      MONEY           NULL,
    [ScOther]      MONEY           NULL,
    [Done]         BIT             NULL,
    [Tomorrow]     BIT             NULL,
    [RemarkOp]     VARCHAR (255)   NULL,
    [Marsh2]       TINYINT         NULL,
    [Ready]        BIT             NULL,
    [DelivCancel]  BIT             NULL,
    [DayShift]     TINYINT         NULL,
    [PrintedNak]   TINYINT         NULL,
    [NeedCK]       BIT             NULL,
    [SertifDoc]    INT             NULL,
    [SPE]          DECIMAL (10, 2) NULL,
    [DeltaSpecSC]  DECIMAL (9, 2)  NULL,
    [TimeArrival]  CHAR (5)        NULL,
    [BruttoWeight] DECIMAL (12, 3) NULL,
    [TranspRashod] DECIMAL (10, 2) NULL,
    [Comp]         VARCHAR (30)    NULL,
    [SertND]       DATETIME        NULL,
    [SertNo]       VARCHAR (40)    NULL,
    [Sk50present]  BIT             NULL,
    [DCK]          INT             NOT NULL,
    [B_Id2]        INT             NULL,
    [NeedDover]    BIT             NULL,
    [XMLDocs]      INT             NULL,
    [LastIzm]      DATETIME        NULL,
    [State]        TINYINT         NULL,
    [DocNom]       VARCHAR (20)    NULL,
    [DocDate]      DATETIME        NULL,
    [STip]         TINYINT         NULL,
    [gpOur_ID_old] TINYINT         NULL,
    [LogID]        INT             IDENTITY (1, 1) NOT NULL,
    [datnom]       BIGINT          NOT NULL,
    [type]         SMALLINT        NULL,
    [user_name]    NVARCHAR (256)  DEFAULT (suser_sname()) NULL,
    [datetime]     DATETIME        DEFAULT (getdate()) NULL,
    [host_name]    NCHAR (30)      DEFAULT (host_name()) NULL,
    [app_name]     NVARCHAR (128)  DEFAULT (app_name()) NULL,
    [gpOur_ID]     INT             DEFAULT ((0)) NULL,
    [mhid]         INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_nclog1]
    ON [dbo].[NCLOG]([datnom] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCLOG', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCLOG', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCLOG', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCLOG', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCLOG', @level2type = N'COLUMN', @level2name = N'type';

