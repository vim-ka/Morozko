CREATE TABLE [dbo].[TSDGraf] (
    [id]     INT           IDENTITY (1, 1) NOT NULL,
    [nd]     DATETIME      NULL,
    [p_id]   INT           NULL,
    [fio]    VARCHAR (100) NULL,
    [sklnum] INT           NULL,
    [tsdnum] INT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

