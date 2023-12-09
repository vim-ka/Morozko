CREATE TABLE [dbo].[PrintBillLog] (
    [pbl]    INT          IDENTITY (1, 1) NOT NULL,
    [ND]     DATETIME     DEFAULT ([dbo].[today]()) NULL,
    [tm]     CHAR (8)     DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [OP]     INT          NULL,
    [kassid] INT          NULL,
    [Comp]   VARCHAR (60) NULL,
    UNIQUE NONCLUSTERED ([pbl] ASC)
);

