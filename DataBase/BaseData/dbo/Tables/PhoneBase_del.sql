CREATE TABLE [dbo].[PhoneBase_del] (
    [p_id]  INT           IDENTITY (1, 1) NOT NULL,
    [fio]   VARCHAR (100) NULL,
    [phone] VARCHAR (15)  NULL,
    UNIQUE NONCLUSTERED ([p_id] ASC)
);

