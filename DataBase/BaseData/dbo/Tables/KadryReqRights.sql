CREATE TABLE [dbo].[KadryReqRights] (
    [id]   INT IDENTITY (1, 1) NOT NULL,
    [ltid] INT NULL,
    [p_id] INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 create trigger trg_kadryreqrights_d
      on kadryreqrights
      for delete
      as
      begin
          insert into kadryreqrightsLog (id, ltid, p_id, [type])
          select id, ltid, p_id, 1 from deleted
      end
GO
 create trigger trg_kadryreqrights_i
      on kadryreqrights
      for insert
      as
      begin
          insert into kadryreqrightsLog (id, ltid, p_id, [type])
          select id, ltid, p_id, 0  from inserted
      end
GO
 create trigger trg_kadryreqrights_u
      on kadryreqrights
      for update
      as
      begin
          insert into kadryreqrightsLog (id, ltid, p_id, [type])
          select id, ltid, p_id, 2 from inserted
      end