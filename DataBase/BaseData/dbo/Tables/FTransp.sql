CREATE TABLE [dbo].[FTransp] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [p_id]      INT           NULL,
    [tr_num]    VARCHAR (20)  NULL,
    [date_from] DATETIME      NULL,
    [date_to]   DATETIME      NULL,
    [comment]   VARCHAR (512) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

