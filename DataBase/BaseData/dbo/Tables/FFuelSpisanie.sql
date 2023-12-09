CREATE TABLE [dbo].[FFuelSpisanie] (
    [fsid]   INT           IDENTITY (1, 1) NOT NULL,
    [fsuin]  INT           NULL,
    [fsdate] DATETIME      NULL,
    [fsprim] VARCHAR (200) NULL,
    [fsvol]  INT           NULL,
    [p_id]   INT           NULL,
    UNIQUE NONCLUSTERED ([fsid] ASC)
);

