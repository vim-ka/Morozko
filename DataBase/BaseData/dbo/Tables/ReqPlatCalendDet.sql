CREATE TABLE [dbo].[ReqPlatCalendDet] (
    [id]      INT             IDENTITY (1, 1) NOT NULL,
    [reqnum]  INT             NULL,
    [sum_opl] NUMERIC (16, 2) NULL,
    [nd]      DATETIME        DEFAULT (getdate()) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

