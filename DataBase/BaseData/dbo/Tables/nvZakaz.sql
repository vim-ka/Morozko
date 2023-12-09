CREATE TABLE [dbo].[nvZakaz] (
    [nzid]      INT             IDENTITY (1, 1) NOT NULL,
    [ND]        DATE            DEFAULT (getdate()) NULL,
    [tm]        VARCHAR (8)     DEFAULT (CONVERT([varchar](8),getdate(),(108))) NOT NULL,
    [dt]        DATETIME        CONSTRAINT [DF__nvZakaz__dt__04BDCCAF] DEFAULT (CONVERT([varchar](10),getdate(),(104))) NULL,
    [datnom]    BIGINT          NULL,
    [Hitag]     INT             NULL,
    [Zakaz]     DECIMAL (10, 3) NULL,
    [unID]      INT             NULL,
    [skladNo]   INT             NULL,
    [Price]     MONEY           NULL,
    [Cost]      MONEY           NULL,
    [comp]      VARCHAR (256)   CONSTRAINT [DF__nvZakaz__comp__18C4C55C] DEFAULT (host_name()) NULL,
    [Done]      BIT             DEFAULT ((0)) NULL,
    [dtEnd]     DATETIME        NULL,
    [tmEnd]     VARCHAR (8)     NULL,
    [ID]        INT             NULL,
    [confKol]   DECIMAL (12, 3) NULL,
    [rest]      DECIMAL (12, 3) NULL,
    [curWeight] DECIMAL (10, 3) NULL,
    [tekWeight] DECIMAL (10, 3) NULL,
    [Remark]    VARCHAR (50)    DEFAULT ('') NOT NULL,
    [OP]        INT             DEFAULT ((0)) NULL,
    [spk]       INT             DEFAULT ((0)) NULL,
    [AuthorOP]  INT             DEFAULT ((0)) NOT NULL,
    [NewDatnom] BIGINT          NULL,
    [group_id]  INT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([nzid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [nvZakaz_idx]
    ON [dbo].[nvZakaz]([datnom] ASC);


GO
CREATE NONCLUSTERED INDEX [nvZakaz_idx2]
    ON [dbo].[nvZakaz]([ND] ASC);


GO
CREATE NONCLUSTERED INDEX [nvZakaz_idx3]
    ON [dbo].[nvZakaz]([tm] ASC);


GO
CREATE NONCLUSTERED INDEX [nvZakaz_idx4]
    ON [dbo].[nvZakaz]([NewDatnom] ASC);


GO
CREATE TRIGGER nvZakaz_trd ON dbo.nvZakaz
WITH EXECUTE AS CALLER
FOR DELETE
AS
BEGIN
  insert into nvzakaz_log(nzid,datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,ActionLog)
  select nzid,datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,'DEL'	
  from deleted
END
GO
CREATE TRIGGER nvZakaz_tri ON dbo.nvZakaz
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  insert into nvzakaz_log(nzid,datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,ActionLog)
  select nzid,datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,'INS'	
  from inserted
END
GO
CREATE TRIGGER nvZakaz_tru ON dbo.nvZakaz
WITH EXECUTE AS CALLER
FOR UPDATE
AS
BEGIN
  insert into nvzakaz_log(nzid,datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,ActionLog)
  select nzid,datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,'UPD'	
  from deleted
  
  insert into nvzakaz_log(nzid,datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,ActionLog)
  select nzid,datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,curWeight,tekWeight,dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,'UPD'	
  from inserted
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Куда ушла?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvZakaz', @level2type = N'COLUMN', @level2name = N'NewDatnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код складского работника из таблицы SkladPersonal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvZakaz', @level2type = N'COLUMN', @level2name = N'spk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оператора из таблицы usrPwd', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvZakaz', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код товара из таблицы TDVI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvZakaz', @level2type = N'COLUMN', @level2name = N'ID';

