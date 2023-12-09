CREATE TABLE [dbo].[SkanSklad3ByNaklOrSvod] (
    [id]     INT IDENTITY (1, 1) NOT NULL,
    [sknum]  INT NULL,
    [bynakl] BIT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

