CREATE TABLE [dbo].[PlanVisit2] (
    [idp]    INT          IDENTITY (1, 1) NOT NULL,
    [pin]    INT          NOT NULL,
    [ag_id]  SMALLINT     NULL,
    [dn]     TINYINT      NULL,
    [tm]     SMALLINT     NULL,
    [dck]    INT          NOT NULL,
    [tip]    TINYINT      DEFAULT ((0)) NULL,
    [MLID]   INT          NULL,
    [Remark] VARCHAR (40) NULL,
    [Hrono]  DATETIME     DEFAULT (getdate()) NULL,
    [Comp]   VARCHAR (30) DEFAULT (host_name()) NULL,
    [OP]     INT          NULL,
    PRIMARY KEY CLUSTERED ([idp] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PlanVisit2_uq]
    ON [dbo].[PlanVisit2]([pin] ASC, [dn] ASC, [ag_id] ASC);


GO
 CREATE TRIGGER dbo.trg_PlanVisit2_i ON dbo.PlanVisit2
WITH EXECUTE AS CALLER
FOR INSERT
AS
      begin
          insert into PlanVisit2Log (idp, pin, ag_id, dn, tm, dck, tip, [type], Op, Remark)
          select idp, pin, ag_id, dn, tm, dck, tip, 0, Op, Remark  from inserted
      end
GO
 CREATE TRIGGER dbo.trg_PlanVisit2_u ON dbo.PlanVisit2
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
          insert into PlanVisit2Log (idp, pin, ag_id, dn, tm, dck, tip, [type], Op, Remark)
          select idp, pin, ag_id, dn, tm, dck, tip, 2, Op, Remark from inserted
      end
GO
 CREATE TRIGGER dbo.trg_PlanVisit2_d ON dbo.PlanVisit2
WITH EXECUTE AS CALLER
FOR DELETE
AS
      begin
          insert into PlanVisit2Log (idp, pin, ag_id, dn, tm, dck, tip, [type], Op, Remark)
          select idp, pin, ag_id, dn, tm, dck, tip, 1, Op, Remark from deleted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ключ в guard.MatrixList', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PlanVisit2', @level2type = N'COLUMN', @level2name = N'MLID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PlanVisit2', @level2type = N'COLUMN', @level2name = N'dck';

