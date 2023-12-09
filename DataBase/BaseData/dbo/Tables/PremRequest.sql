CREATE TABLE [dbo].[PremRequest] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [nd]         DATETIME       NULL,
    [p_id]       INT            NULL,
    [depid]      INT            NULL,
    [month]      INT            NULL,
    [year]       INT            NULL,
    [dep_dir]    INT            NULL,
    [comm]       VARCHAR (1024) NULL,
    [stat]       INT            DEFAULT ((1)) NULL,
    [locked]     BIT            DEFAULT ((0)) NULL,
    [tip]        TINYINT        DEFAULT ((0)) NULL,
    [parent_id]  INT            DEFAULT ((-1)) NULL,
    [dir_nd]     DATETIME       NULL,
    [dir_comm]   VARCHAR (512)  NULL,
    [hr_nd]      DATETIME       NULL,
    [hr_comm]    VARCHAR (512)  NULL,
    [buh_nd]     DATETIME       NULL,
    [buh_comm]   VARCHAR (512)  NULL,
    [sendsoglnd] DATETIME       NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 create trigger trg_premrequest_i
      on premrequest
      for insert
      as
      begin
          insert into premrequestLog (id, nd, p_id, depid, month, year, dep_dir, comm, stat, locked, tip, parent_id, dir_nd, dir_comm, hr_nd, hr_comm, buh_nd, buh_comm, [type])
          select id, nd, p_id, depid, month, year, dep_dir, comm, stat, locked, tip, parent_id, dir_nd, dir_comm, hr_nd, hr_comm, buh_nd, buh_comm, 0  from inserted
      end
GO
 create trigger trg_premrequest_u
      on premrequest
      for update
      as
      begin
          insert into premrequestLog (id, nd, p_id, depid, month, year, dep_dir, comm, stat, locked, tip, parent_id, dir_nd, dir_comm, hr_nd, hr_comm, buh_nd, buh_comm, [type])
          select id, nd, p_id, depid, month, year, dep_dir, comm, stat, locked, tip, parent_id, dir_nd, dir_comm, hr_nd, hr_comm, buh_nd, buh_comm, 2 from inserted
      end
GO
 create trigger trg_premrequest_d
      on premrequest
      for delete
      as
      begin
          insert into premrequestLog (id, nd, p_id, depid, month, year, dep_dir, comm, stat, locked, tip, parent_id, dir_nd, dir_comm, hr_nd, hr_comm, buh_nd, buh_comm, [type])
          select id, nd, p_id, depid, month, year, dep_dir, comm, stat, locked, tip, parent_id, dir_nd, dir_comm, hr_nd, hr_comm, buh_nd, buh_comm, 1 from deleted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tip 0 - обычный бюджет
tip 1 - бюджет по превышениям
tip 2 - бюджет компенсации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PremRequest';

