CREATE TABLE [dbo].[KadryReqDet] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [krmid]     INT             NULL,
    [ltid]      INT             NULL,
    [kol]       NUMERIC (12, 2) NULL,
    [chk]       BIT             NULL,
    [txt]       VARCHAR (256)   NULL,
    [init_p_id] INT             NULL,
    [init_nd]   DATETIME        NULL,
    CONSTRAINT [KadryReqDet_fk] FOREIGN KEY ([krmid]) REFERENCES [dbo].[KadryReqMain] ([id]) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 create trigger trg_kadryreqdet_i
      on kadryreqdet
      for insert
      as
      begin
          insert into kadryreqdetLog (id, krmid, ltid, kol, chk, txt, [type])
          select id, krmid, ltid, kol, chk, txt, 0  from inserted
      end
GO
 create trigger trg_kadryreqdet_u
      on kadryreqdet
      for update
      as
      begin
          insert into kadryreqdetLog (id, krmid, ltid, kol, chk, txt, [type])
          select id, krmid, ltid, kol, chk, txt, 2 from inserted
      end
GO
 create trigger trg_kadryreqdet_d
      on kadryreqdet
      for delete
      as
      begin
          insert into kadryreqdetLog (id, krmid, ltid, kol, chk, txt, [type])
          select id, krmid, ltid, kol, chk, txt, 1 from deleted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'строка отмечена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KadryReqDet', @level2type = N'COLUMN', @level2name = N'chk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на таблицу строк', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KadryReqDet', @level2type = N'COLUMN', @level2name = N'ltid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на главную таблицу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KadryReqDet', @level2type = N'COLUMN', @level2name = N'krmid';

