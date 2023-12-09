CREATE TABLE [dbo].[ReqBudgetDet] (
    [id]          INT             IDENTITY (1, 1) NOT NULL,
    [rbid]        INT             NULL,
    [kso]         INT             NULL,
    [contr]       INT             NULL,
    [contr_new]   BIT             NULL,
    [contr_txt]   VARCHAR (128)   NULL,
    [sum_opl]     NUMERIC (16, 2) NULL,
    [tip_plat]    INT             NULL,
    [plan_nd]     DATETIME        NULL,
    [depCFO]      INT             NULL,
    [comm]        VARCHAR (1024)  NULL,
    [sum_req]     NUMERIC (16, 2) DEFAULT ((0)) NULL,
    [compens]     BIT             DEFAULT ((0)) NULL,
    [compensidx]  INT             NULL,
    [compensnd]   DATETIME        NULL,
    [constplat]   BIT             DEFAULT ((0)) NULL,
    [addtofp]     BIT             DEFAULT ((0)) NULL,
    [fp_nd_fix]   DATETIME        NULL,
    [fondsaldo]   NUMERIC (16, 2) DEFAULT ((0)) NULL,
    [fondplansum] NUMERIC (16, 2) DEFAULT ((0)) NULL,
    [issogl]      SMALLINT        CONSTRAINT [DF__ReqBudget__issog__1B4CF7A3] DEFAULT ((-1)) NULL,
    [mandatory]   BIT             DEFAULT ((0)) NULL,
    [raiting]     INT             DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
 CREATE TRIGGER dbo.trg_ReqBudgetDet_i ON dbo.ReqBudgetDet
WITH EXECUTE AS CALLER
FOR INSERT
AS
      begin
          insert into ReqBudgetDetLog (id, rbid, kso, contr, contr_new, contr_txt, sum_opl, tip_plat, plan_nd, depCFO, comm, sum_req, compens, compensidx, compensnd, constplat, addtofp, fp_nd_fix, fondsaldo, fondplansum, issogl, [type], mandatory)
          select id, rbid, kso, contr, contr_new, contr_txt, sum_opl, tip_plat, plan_nd, depCFO, comm, sum_req, compens, compensidx, compensnd, constplat, addtofp, fp_nd_fix, fondsaldo, fondplansum, issogl, 0, mandatory  from inserted
      end
GO
 CREATE TRIGGER dbo.trg_ReqBudgetDet_d ON dbo.ReqBudgetDet
WITH EXECUTE AS CALLER
FOR DELETE
AS
      begin
          insert into ReqBudgetDetLog (id, rbid, kso, contr, contr_new, contr_txt, sum_opl, tip_plat, plan_nd, depCFO, comm, sum_req, compens, compensidx, compensnd, constplat, addtofp, fp_nd_fix, fondsaldo, fondplansum, issogl, [type], mandatory)
          select id, rbid, kso, contr, contr_new, contr_txt, sum_opl, tip_plat, plan_nd, depCFO, comm, sum_req, compens, compensidx, compensnd, constplat, addtofp, fp_nd_fix, fondsaldo, fondplansum, issogl, 1, mandatory from deleted
      end
GO
 CREATE TRIGGER dbo.trg_ReqBudgetDet_u ON dbo.ReqBudgetDet
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
          insert into ReqBudgetDetLog (id, rbid, kso, contr, contr_new, contr_txt, sum_opl, tip_plat, plan_nd, depCFO, comm, sum_req, compens, compensidx, compensnd, constplat, addtofp, fp_nd_fix, fondsaldo, fondplansum, issogl, [type], mandatory)
          select id, rbid, kso, contr, contr_new, contr_txt, sum_opl, tip_plat, plan_nd, depCFO, comm, sum_req, compens, compensidx, compensnd, constplat, addtofp, fp_nd_fix, fondsaldo, fondplansum, issogl, 2, mandatory from inserted
      end