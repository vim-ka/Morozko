CREATE TABLE [dbo].[NV_State] (
    [tip]     INT          NOT NULL,
    [tipName] VARCHAR (50) NULL,
    CONSTRAINT [UQ__NV_State__DC105B32C9CC9858] UNIQUE NONCLUSTERED ([tip] ASC)
);

