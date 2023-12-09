CREATE TABLE [dbo].[ReqStatus] (
    [Status]     INT          IDENTITY (1, 1) NOT NULL,
    [StatusName] VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([Status] ASC)
);

