CREATE TABLE [dbo].[Meas] (
    [MeasId] TINYINT       NOT NULL,
    [mName]  NVARCHAR (20) NULL,
    [ShortN] VARCHAR (5)   NULL,
    CONSTRAINT [Meas_pk] PRIMARY KEY CLUSTERED ([MeasId] ASC)
);

