CREATE TABLE [dbo].[PreOrder] (
    [pID]           INT             IDENTITY (1, 1) NOT NULL,
    [ND]            DATETIME        CONSTRAINT [DF__PreOrder__ND__02B65403] DEFAULT ([dbo].[today]()) NOT NULL,
    [TM]            CHAR (8)        CONSTRAINT [DF__PreOrder__TM__03AA783C] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [DCK]           INT             NULL,
    [Ag_ID]         INT             NULL,
    [NDOrder]       DATETIME        NULL,
    [Hitag]         INT             NULL,
    [Qty]           NUMERIC (9, 3)  NULL,
    [Weight]        NUMERIC (15, 6) NULL,
    [CorrectQty]    NUMERIC (9, 3)  NULL,
    [CorrectWeight] NUMERIC (15, 6) NULL,
    [CommentROP]    VARCHAR (100)   NULL,
    [CommentZakup]  VARCHAR (100)   NULL,
    [RemarkAgent]   VARCHAR (100)   NULL,
    [POStatus]      INT             NULL,
    [NDCompl]       DATETIME        NULL,
    CONSTRAINT [UQ__PreOrder__DD36D5031E9E7DB5] UNIQUE NONCLUSTERED ([pID] ASC)
);

