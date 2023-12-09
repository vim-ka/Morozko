CREATE TABLE [dbo].[Phone] (
    [PhID]   INT          IDENTITY (1, 1) NOT NULL,
    [Number] VARCHAR (20) NULL,
    [Region] CHAR (3)     NULL,
    [DogNo]  VARCHAR (20) NULL,
    UNIQUE NONCLUSTERED ([PhID] ASC),
    CONSTRAINT [Phone_uq] UNIQUE NONCLUSTERED ([Number] ASC)
);

