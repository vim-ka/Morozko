CREATE TABLE [dbo].[SertifInpdetStock] (
    [ID]      INT IDENTITY (1, 1) NOT NULL,
    [EntryID] INT NULL,
    [StartID] INT NULL,
    [Our_id]  INT NULL,
    CONSTRAINT [PK_SertifInpdetStock_ID_copy] PRIMARY KEY CLUSTERED ([ID] ASC)
);

