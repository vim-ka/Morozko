CREATE TABLE [dbo].[NFTipDet] (
    [id]       INT           IDENTITY (1, 1) NOT NULL,
    [tip_id]   INT           NULL,
    [rs]       INT           NULL,
    [chk]      BIT           DEFAULT ((0)) NULL,
    [comment]  VARCHAR (255) NULL,
    [dt]       DATETIME      NULL,
    [chk_p_id] INT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 create trigger trg_NFTipDet_d
      on NFTipDet
      for delete
      as
      begin
          insert into NFTipDetLog (id, tip_id, rs, chk, comment, dt, [type])
          select id, tip_id, rs, chk, comment, dt, 1 from deleted
      end
GO
 create trigger trg_NFTipDet_i
      on NFTipDet
      for insert
      as
      begin
          insert into NFTipDetLog (id, tip_id, rs, chk, comment, dt, [type])
          select id, tip_id, rs, chk, comment, dt, 0  from inserted
      end
GO
 create trigger trg_NFTipDet_u
      on NFTipDet
      for update
      as
      begin
          insert into NFTipDetLog (id, tip_id, rs, chk, comment, dt, [type])
          select id, tip_id, rs, chk, comment, dt, 2 from inserted
      end