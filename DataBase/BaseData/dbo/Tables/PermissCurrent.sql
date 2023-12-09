CREATE TABLE [dbo].[PermissCurrent] (
    [pcid]    INT IDENTITY (1, 1) NOT NULL,
    [P_ID]    INT NULL,
    [Prg]     INT NULL,
    [Permiss] INT NULL,
    [uin]     INT NULL,
    CONSTRAINT [PermissCurrent_pk] PRIMARY KEY CLUSTERED ([pcid] ASC),
    UNIQUE NONCLUSTERED ([pcid] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PermissCurr_uq]
    ON [dbo].[PermissCurrent]([uin] ASC, [Prg] ASC);


GO
 create trigger trg_PermissCurrent_i
      on PermissCurrent
      for insert
      as
      begin
          insert into PermissCurrentLog (pcid, P_ID, Prg, Permiss, uin, [type])
          select pcid, P_ID, Prg, Permiss, uin, 0  from inserted
      end
GO
 create trigger trg_PermissCurrent_u
      on PermissCurrent
      for update
      as
      begin
          insert into PermissCurrentLog (pcid, P_ID, Prg, Permiss, uin, [type])
          select pcid, P_ID, Prg, Permiss, uin, 2 from inserted
      end
GO
 create trigger trg_PermissCurrent_d
      on PermissCurrent
      for delete
      as
      begin
          insert into PermissCurrentLog (pcid, P_ID, Prg, Permiss, uin, [type])
          select pcid, P_ID, Prg, Permiss, uin, 1 from deleted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Права', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PermissCurrent', @level2type = N'COLUMN', @level2name = N'Permiss';

