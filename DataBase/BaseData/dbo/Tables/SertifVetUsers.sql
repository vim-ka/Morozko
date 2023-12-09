CREATE TABLE [dbo].[SertifVetUsers] (
    [ID]    INT          IDENTITY (1, 1) NOT NULL,
    [Login] VARCHAR (50) NULL,
    [uin]   INT          NULL,
    CONSTRAINT [PK_SertifVetUsers_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

