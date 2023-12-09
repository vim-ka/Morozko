CREATE TABLE [dbo].[NEW_nvZakaz] (
    [nzid]      INT             IDENTITY (1, 1) NOT NULL,
    [datnom]    BIGINT          NULL,
    [Hitag]     INT             NULL,
    [Zakaz]     DECIMAL (10, 3) NULL,
    [Done]      BIT             DEFAULT ((0)) NULL,
    [ND]        DATE            DEFAULT (getdate()) NULL,
    [Price]     MONEY           NULL,
    [Cost]      MONEY           NULL,
    [comp]      VARCHAR (256)   CONSTRAINT [DF__nvZakaz__comp__18C4C55C_copy] DEFAULT (host_name()) NULL,
    [tm]        VARCHAR (8)     DEFAULT (CONVERT([varchar](8),getdate(),(108))) NOT NULL,
    [tmEnd]     VARCHAR (8)     NULL,
    [curWeight] DECIMAL (10, 3) NULL,
    [tekWeight] DECIMAL (10, 3) NULL,
    [dt]        DATETIME        CONSTRAINT [DF__nvZakaz__dt__04BDCCAF_copy] DEFAULT (CONVERT([varchar](10),getdate(),(104))) NULL,
    [dtEnd]     DATETIME        NULL,
    [ID]        INT             NULL,
    [Remark]    VARCHAR (50)    DEFAULT ('') NOT NULL,
    [skladNo]   INT             NULL,
    [OP]        INT             DEFAULT ((0)) NULL,
    [spk]       INT             DEFAULT ((0)) NULL,
    [AuthorOP]  INT             DEFAULT ((0)) NOT NULL,
    [NewDatnom] BIGINT          NULL,
    [group_id]  INT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([nzid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [nvZakaz_idx4]
    ON [dbo].[NEW_nvZakaz]([NewDatnom] ASC);


GO
CREATE NONCLUSTERED INDEX [nvZakaz_idx3]
    ON [dbo].[NEW_nvZakaz]([tm] ASC);


GO
CREATE NONCLUSTERED INDEX [nvZakaz_idx2]
    ON [dbo].[NEW_nvZakaz]([ND] ASC);


GO
CREATE NONCLUSTERED INDEX [nvZakaz_idx]
    ON [dbo].[NEW_nvZakaz]([datnom] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Куда ушла?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_nvZakaz', @level2type = N'COLUMN', @level2name = N'NewDatnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код складского работника из таблицы SkladPersonal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_nvZakaz', @level2type = N'COLUMN', @level2name = N'spk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оператора из таблицы usrPwd', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_nvZakaz', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код товара из таблицы TDVI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_nvZakaz', @level2type = N'COLUMN', @level2name = N'ID';

