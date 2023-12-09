CREATE TABLE [dbo].[ReqFriz] (
    [ReqFr]      INT           IDENTITY (1, 1) NOT NULL,
    [ND]         DATETIME      NULL,
    [DepIDCust]  INT           NULL,
    [DepIDExec]  INT           NULL,
    [Op]         INT           NULL,
    [B_ID]       INT           NOT NULL,
    [Contact]    VARCHAR (255) NULL,
    [Phone]      VARCHAR (20)  NULL,
    [AG_ID]      INT           NOT NULL,
    [NeedND]     DATETIME      NULL,
    [PlanND]     DATETIME      NULL,
    [FactND]     DATETIME      NULL,
    [Status]     INT           NULL,
    [RemarkCust] VARCHAR (255) NULL,
    [RemarkExec] VARCHAR (255) NULL,
    UNIQUE NONCLUSTERED ([ReqFr] ASC)
);

