CREATE TABLE [dbo].[ReqReturn] (
    [id]       INT           IDENTITY (1, 1) NOT NULL,
    [reqnum]   INT           NULL,
    [pin]      INT           NULL,
    [ret_nd]   DATETIME      NULL,
    [comment]  VARCHAR (512) NULL,
    [dck]      INT           NULL,
    [mhID]     INT           DEFAULT ((0)) NOT NULL,
    [done]     BIT           DEFAULT ((0)) NULL,
    [doc_num]  VARCHAR (20)  NULL,
    [doc_date] DATETIME      NULL,
    [stf_num]  VARCHAR (20)  NULL,
    [stf_date] DATETIME      NULL,
    [pin_from] INT           DEFAULT ((0)) NULL,
    [isp_p_id] INT           DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ReqReturn_idx4]
    ON [dbo].[ReqReturn]([mhID] ASC);


GO
CREATE NONCLUSTERED INDEX [ReqReturn_idx3]
    ON [dbo].[ReqReturn]([dck] ASC);


GO
CREATE NONCLUSTERED INDEX [ReqReturn_idx2]
    ON [dbo].[ReqReturn]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [ReqReturn_idx]
    ON [dbo].[ReqReturn]([reqnum] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_mgid]
    ON [dbo].[ReqReturn]([mhID] ASC);


GO
 create trigger trg_reqreturn_u
      on reqreturn
      for update
      as
      begin
          insert into reqreturnLog (id, reqnum, pin, ret_nd, comment, dck, mhID, done, doc_num, doc_date, stf_num, stf_date, [type])
          select id, reqnum, pin, ret_nd, comment, dck, mhID, done, doc_num, doc_date, stf_num, stf_date, 2 from inserted
      end
GO
 create trigger trg_reqreturn_d
      on reqreturn
      for delete
      as
      begin
          insert into reqreturnLog (id, reqnum, pin, ret_nd, comment, dck, mhID, done, doc_num, doc_date, stf_num, stf_date, [type])
          select id, reqnum, pin, ret_nd, comment, dck, mhID, done, doc_num, doc_date, stf_num, stf_date, 1 from deleted
      end
GO
 create trigger trg_reqreturn_i
      on reqreturn
      for insert
      as
      begin
          insert into reqreturnLog (id, reqnum, pin, ret_nd, comment, dck, mhID, done, doc_num, doc_date, stf_num, stf_date, [type])
          select id, reqnum, pin, ret_nd, comment, dck, mhID, done, doc_num, doc_date, stf_num, stf_date, 0  from inserted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код точки, с которой фактически осуществлялся возврат (для сетей)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturn', @level2type = N'COLUMN', @level2name = N'pin_from';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturn', @level2type = N'COLUMN', @level2name = N'comment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата забора товара с торг. точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturn', @level2type = N'COLUMN', @level2name = N'ret_nd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код торговой точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturn', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на кросс-заявку', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturn', @level2type = N'COLUMN', @level2name = N'reqnum';

