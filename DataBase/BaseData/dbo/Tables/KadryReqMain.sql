CREATE TABLE [dbo].[KadryReqMain] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [nd]        DATETIME      DEFAULT (getdate()) NULL,
    [p_id]      INT           NULL,
    [depid]     INT           NULL,
    [cnt]       INT           DEFAULT ((0)) NULL,
    [cnt_max]   INT           DEFAULT ((0)) NULL,
    [lastnd]    DATETIME      NULL,
    [tip]       INT           NULL,
    [dolzhn]    VARCHAR (256) NULL,
    [locked]    BIT           DEFAULT ((0)) NULL,
    [init_p_id] INT           DEFAULT ((-1)) NULL,
    [comment]   VARCHAR (512) NULL,
    [kol]       INT           DEFAULT ((0)) NULL,
    [reason_id] INT           DEFAULT ((-1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 create trigger trg_kadryreqmain_u
      on kadryreqmain
      for update
      as
      begin
          insert into kadryreqmainLog (id, nd, p_id, depid, cnt, cnt_max, lastnd, tip, dolzhn, locked, init_p_id, comment, kol, [type])
          select id, nd, p_id, depid, cnt, cnt_max, lastnd, tip, dolzhn, locked, init_p_id, comment, kol, 2 from inserted
      end
GO
 create trigger trg_kadryreqmain_i
      on kadryreqmain
      for insert
      as
      begin
          insert into kadryreqmainLog (id, nd, p_id, depid, cnt, cnt_max, lastnd, tip, dolzhn, locked, init_p_id, comment, kol, [type])
          select id, nd, p_id, depid, cnt, cnt_max, lastnd, tip, dolzhn, locked, init_p_id, comment, kol, 0  from inserted
      end
GO
 create trigger trg_kadryreqmain_d
      on kadryreqmain
      for delete
      as
      begin
          insert into kadryreqmainLog (id, nd, p_id, depid, cnt, cnt_max, lastnd, tip, dolzhn, locked, init_p_id, comment, kol, [type])
          select id, nd, p_id, depid, cnt, cnt_max, lastnd, tip, dolzhn, locked, init_p_id, comment, kol, 1 from deleted
      end