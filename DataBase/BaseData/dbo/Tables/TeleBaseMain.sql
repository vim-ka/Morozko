CREATE TABLE [dbo].[TeleBaseMain] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [p_id]     INT          NULL,
    [uin]      INT          NULL,
    [tip]      INT          DEFAULT ((1)) NULL,
    [phonenum] VARCHAR (15) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 create trigger trg_telebasemain_d
      on telebasemain
      for delete
      as
      begin
          insert into telebasemainLog (id, p_id, uin, tip, phonenum, [type])
          select id, p_id, uin, tip, phonenum, 1 from deleted
      end
GO
 create trigger trg_telebasemain_u
      on telebasemain
      for update
      as
      begin
          insert into telebasemainLog (id, p_id, uin, tip, phonenum, [type])
          select id, p_id, uin, tip, phonenum, 2 from inserted
      end
GO
 create trigger trg_telebasemain_i
      on telebasemain
      for insert
      as
      begin
          insert into telebasemainLog (id, p_id, uin, tip, phonenum, [type])
          select id, p_id, uin, tip, phonenum, 0  from inserted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 - офис 2 - моб. рабочий 3 - личный дом. 4 - личный моб.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TeleBaseMain', @level2type = N'COLUMN', @level2name = N'tip';

