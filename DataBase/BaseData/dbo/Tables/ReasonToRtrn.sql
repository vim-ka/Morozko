CREATE TABLE [dbo].[ReasonToRtrn] (
    [Reason_Id] INT           IDENTITY (1, 1) NOT NULL,
    [Reason]    VARCHAR (100) NULL,
    [Parent_Id] INT           NULL,
    [isDel]     BIT           DEFAULT ((0)) NOT NULL
);

