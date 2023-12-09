CREATE TABLE [dbo].[FFuel95] (
    [fId]      INT          IDENTITY (1, 1) NOT NULL,
    [fuin]     INT          NULL,
    [fmonth]   INT          NULL,
    [fyear]    VARCHAR (4)  NULL,
    [fcardnom] VARCHAR (25) NULL,
    [fvol]     INT          NULL,
    [p_id]     INT          NULL,
    UNIQUE NONCLUSTERED ([fId] ASC)
);

