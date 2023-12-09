CREATE TABLE [dbo].[TSDReg] (
    [id]     INT          IDENTITY (1, 1) NOT NULL,
    [name]   VARCHAR (60) NULL,
    [ip]     VARCHAR (15) NULL,
    [status] INT          NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

