CREATE TABLE [dbo].[FLimLog] (
    [fLid]  INT      IDENTITY (1, 1) NOT NULL,
    [fLUin] INT      NULL,
    [fLND]  DATETIME NULL,
    [fLLim] INT      NULL,
    [p_id]  INT      NULL,
    UNIQUE NONCLUSTERED ([fLid] ASC)
);

