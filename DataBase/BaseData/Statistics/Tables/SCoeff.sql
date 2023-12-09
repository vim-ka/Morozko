CREATE TABLE [Statistics].[SCoeff] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [statid]   INT             DEFAULT ((-1)) NULL,
    [datefrom] DATETIME        NULL,
    [dateto]   DATETIME        NULL,
    [hi]       NUMERIC (12, 3) DEFAULT ((1)) NULL,
    [lo]       NUMERIC (12, 3) DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица коэффициентов', @level0type = N'SCHEMA', @level0name = N'Statistics', @level1type = N'TABLE', @level1name = N'SCoeff';

