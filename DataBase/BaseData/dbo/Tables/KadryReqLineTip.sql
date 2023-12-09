CREATE TABLE [dbo].[KadryReqLineTip] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [tipname]    VARCHAR (255) NULL,
    [tipgr]      INT           DEFAULT ((-1)) NULL,
    [tipord]     INT           NULL,
    [tipotvname] VARCHAR (64)  NULL,
    [tipparent]  INT           CONSTRAINT [DF__KadryReqL__tippa__2219F0C3] DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 create trigger trg_kadryreqlinetip_i
      on kadryreqlinetip
      for insert
      as
      begin
          insert into kadryreqlinetipLog (id, tipname, tipgr, tipord, tipotvname, tipparent, [type])
          select id, tipname, tipgr, tipord, tipotvname, tipparent, 0  from inserted
      end
GO
 create trigger trg_kadryreqlinetip_d
      on kadryreqlinetip
      for delete
      as
      begin
          insert into kadryreqlinetipLog (id, tipname, tipgr, tipord, tipotvname, tipparent, [type])
          select id, tipname, tipgr, tipord, tipotvname, tipparent, 1 from deleted
      end
GO
 create trigger trg_kadryreqlinetip_u
      on kadryreqlinetip
      for update
      as
      begin
          insert into kadryreqlinetipLog (id, tipname, tipgr, tipord, tipotvname, tipparent, [type])
          select id, tipname, tipgr, tipord, tipotvname, tipparent, 2 from inserted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipgr -1 общие строки
	   1 строки по условию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KadryReqLineTip';

