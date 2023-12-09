CREATE TABLE [dbo].[PremRequestDet] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [prid]      INT             NULL,
    [p_id]      INT             DEFAULT ((-1)) NULL,
    [main_proc] NUMERIC (5, 2)  DEFAULT ((0)) NULL,
    [main_sum]  NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [linkdet]   INT             DEFAULT ((-1)) NULL,
    [comm]      VARCHAR (512)   NULL,
    [vednum]    INT             DEFAULT ((-1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 create trigger trg_premrequestdet_d
      on premrequestdet
      for delete
      as
      begin
          insert into premrequestdetLog (id, prid, p_id, main_proc, main_sum, linkdet, comm, vednum, [type])
          select id, prid, p_id, main_proc, main_sum, linkdet, comm, vednum, 1 from deleted
      end
GO
 create trigger trg_premrequestdet_i
      on premrequestdet
      for insert
      as
      begin
          insert into premrequestdetLog (id, prid, p_id, main_proc, main_sum, linkdet, comm, vednum, [type])
          select id, prid, p_id, main_proc, main_sum, linkdet, comm, vednum, 0  from inserted
      end
GO
 create trigger trg_premrequestdet_u
      on premrequestdet
      for update
      as
      begin
          insert into premrequestdetLog (id, prid, p_id, main_proc, main_sum, linkdet, comm, vednum, [type])
          select id, prid, p_id, main_proc, main_sum, linkdet, comm, vednum, 2 from inserted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tip 0 - обычный бюджет
tip 1 - бюджет по превышениям
tip 2 - бюджет компенсации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PremRequestDet';

