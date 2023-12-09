CREATE TABLE [dbo].[TSDList] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [tsdid]    VARCHAR (60) NOT NULL,
    [tsdname]  VARCHAR (20) NULL,
    [tsdmodel] VARCHAR (25) NULL,
    [srID]     INT          NULL,
    UNIQUE NONCLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([tsdid] ASC)
);

