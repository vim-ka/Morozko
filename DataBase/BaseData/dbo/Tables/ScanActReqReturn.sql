CREATE TABLE [dbo].[ScanActReqReturn] (
    [id]        INT          IDENTITY (1, 1) NOT NULL,
    [nd]        DATETIME     DEFAULT (getdate()) NULL,
    [OP]        INT          NULL,
    [reqnum]    INT          NULL,
    [host_name] VARCHAR (64) DEFAULT (host_name()) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ScanActReqReturn_idx2]
    ON [dbo].[ScanActReqReturn]([OP] ASC);


GO
 create trigger trg_ScanActReqReturn_i
      on ScanActReqReturn
      for insert
      as
      begin
          insert into ScanActReqReturnLog (id, nd, OP, reqnum, host_name, [type])
          select id, nd, OP, reqnum, host_name, 0  from inserted
      end
GO
 create trigger trg_ScanActReqReturn_d
      on ScanActReqReturn
      for delete
      as
      begin
          insert into ScanActReqReturnLog (id, nd, OP, reqnum, host_name, [type])
          select id, nd, OP, reqnum, host_name, 1 from deleted
      end
GO
 create trigger trg_ScanActReqReturn_u
      on ScanActReqReturn
      for update
      as
      begin
          insert into ScanActReqReturnLog (id, nd, OP, reqnum, host_name, [type])
          select id, nd, OP, reqnum, host_name, 2 from inserted
      end