CREATE TABLE [dbo].[CK] (
    [CkId]     INT          IDENTITY (1, 1) NOT NULL,
    [NoOper]   INT          NULL,
    [ND]       DATETIME     DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [TM]       CHAR (8)     DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [B_ID]     INT          NULL,
    [Plata]    MONEY        NULL,
    [Nds0]     MONEY        NULL,
    [Nds10]    MONEY        NULL,
    [Nds18]    MONEY        NULL,
    [Op]       INT          NULL,
    [remark]   VARCHAR (50) NULL,
    [Our_ID]   SMALLINT     NULL,
    [datnom]   INT          NULL,
    [KassID]   INT          NULL,
    [CompName] VARCHAR (60) DEFAULT (host_name()) NULL,
    [Back]     BIT          DEFAULT ((0)) NULL,
    [Nds20]    MONEY        DEFAULT ((0)) NOT NULL,
    [typeCK]   TINYINT      NULL,
    PRIMARY KEY CLUSTERED ([CkId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [CK_idx2]
    ON [dbo].[CK]([ND] ASC);


GO
CREATE NONCLUSTERED INDEX [CK_idx]
    ON [dbo].[CK]([B_ID] ASC);


GO
 create trigger trg_CK_i
      on CK
      for insert
      as
      begin
          insert into CKLog (CkId, NoOper, ND, TM, B_ID, Plata, Nds0, Nds10, Nds18, Op, remark, Our_ID, datnom, KassID, [type])
          select CkId, NoOper, ND, TM, B_ID, Plata, Nds0, Nds10, Nds18, Op, remark, Our_ID, datnom, KassID, 0  from inserted
      end
GO
 create trigger trg_CK_u
      on CK
      for update
      as
      begin
          insert into CKLog (CkId, NoOper, ND, TM, B_ID, Plata, Nds0, Nds10, Nds18, Op, remark, Our_ID, datnom, KassID, [type])
          select CkId, NoOper, ND, TM, B_ID, Plata, Nds0, Nds10, Nds18, Op, remark, Our_ID, datnom, KassID, 2 from inserted
      end
GO
 create trigger trg_CK_d
      on CK
      for delete
      as
      begin
          insert into CKLog (CkId, NoOper, ND, TM, B_ID, Plata, Nds0, Nds10, Nds18, Op, remark, Our_ID, datnom, KassID, [type])
          select CkId, NoOper, ND, TM, B_ID, Plata, Nds0, Nds10, Nds18, Op, remark, Our_ID, datnom, KassID, 1 from deleted
      end