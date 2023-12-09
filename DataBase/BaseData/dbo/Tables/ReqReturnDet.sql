CREATE TABLE [dbo].[ReqReturnDet] (
    [id]           INT             IDENTITY (1, 1) NOT NULL,
    [reqretid]     INT             NULL,
    [hitag]        INT             NULL,
    [kol]          INT             NULL,
    [fact_weight]  NUMERIC (12, 3) NULL,
    [ret_reason]   INT             NULL,
    [sourcedatnom] INT             NULL,
    [tovprice]     NUMERIC (15, 2) CONSTRAINT [DF__ReqReturn__tovpr__716BCC70] DEFAULT ((0)) NULL,
    [Sklad]        INT             NULL,
    [doc_num]      VARCHAR (20)    NULL,
    [doc_date]     DATETIME        NULL,
    [stf_num]      VARCHAR (20)    NULL,
    [stf_date]     DATETIME        NULL,
    [done]         BIT             DEFAULT ((0)) NULL,
    [reftekid]     INT             NULL,
    [isChanged]    BIT             DEFAULT ((0)) NULL,
    [skladOP]      INT             DEFAULT ((-1)) NOT NULL,
    [spk]          INT             DEFAULT ((0)) NOT NULL,
    [fact_weight2] NUMERIC (12, 3) DEFAULT ((0)) NULL,
    [fact_kol2]    INT             DEFAULT ((0)) NULL,
    [groupid]      INT             DEFAULT ((0)) NOT NULL,
    [rqID]         INT             DEFAULT ((1)) NOT NULL,
    [fact_srokh]   DATETIME        NULL,
    [non_srokh]    BIT             DEFAULT ((0)) NOT NULL,
    UNIQUE NONCLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ReqReturnDet_idx4]
    ON [dbo].[ReqReturnDet]([sourcedatnom] ASC);


GO
CREATE NONCLUSTERED INDEX [ReqReturnDet_idx3]
    ON [dbo].[ReqReturnDet]([hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [ReqReturnDet_idx2]
    ON [dbo].[ReqReturnDet]([reqretid] ASC);


GO
CREATE NONCLUSTERED INDEX [ReqReturnDet_idx]
    ON [dbo].[ReqReturnDet]([reqretid] ASC);


GO
 CREATE TRIGGER dbo.trg_ReqReturnDet_d ON dbo.ReqReturnDet
WITH EXECUTE AS CALLER
FOR DELETE
AS
      begin
          insert into ReqReturnDetLog (id, reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, Sklad, doc_num, doc_date, stf_num, stf_date, done, [type], fact_weight2, fact_kol2)
          select id, reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, Sklad, doc_num, doc_date, stf_num, stf_date, done, 1, fact_weight2, fact_kol2 from deleted
      end
GO
 CREATE TRIGGER dbo.trg_ReqReturnDet_i ON dbo.ReqReturnDet
WITH EXECUTE AS CALLER
FOR INSERT
AS
      begin
          insert into ReqReturnDetLog (id, reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, Sklad, doc_num, doc_date, stf_num, stf_date, done, [type], fact_weight2, fact_kol2)
          select id, reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, Sklad, doc_num, doc_date, stf_num, stf_date, done, 0, fact_weight2, fact_kol2  from inserted
      end
GO
 create trigger trg_ReqReturnDet_u
      on ReqReturnDet
      for update
      as
      begin
          insert into ReqReturnDetLog (id, reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, Sklad, doc_num, doc_date, stf_num, stf_date, done, [type])
          select id, reqretid, hitag, kol, fact_weight, ret_reason, sourcedatnom, tovprice, Sklad, doc_num, doc_date, stf_num, stf_date, done, 2 from inserted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'dbo.return_quality', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnDet', @level2type = N'COLUMN', @level2name = N'rqID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'фактически принятое количество', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnDet', @level2type = N'COLUMN', @level2name = N'fact_kol2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'фактически принятый вес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnDet', @level2type = N'COLUMN', @level2name = N'fact_weight2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnDet', @level2type = N'COLUMN', @level2name = N'spk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'работник склада', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnDet', @level2type = N'COLUMN', @level2name = N'skladOP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Склад', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnDet', @level2type = N'COLUMN', @level2name = N'Sklad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'возвращаемый вес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnDet', @level2type = N'COLUMN', @level2name = N'fact_weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на запись в reqreturn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnDet', @level2type = N'COLUMN', @level2name = N'reqretid';

