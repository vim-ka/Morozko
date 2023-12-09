CREATE TABLE [dbo].[Lgs] (
    [LgsId]  INT          IDENTITY (101, 1) NOT NULL,
    [Fam]    VARCHAR (50) NULL,
    [Answer] CHAR (32)    NULL,
    [OP]     SMALLINT     NULL,
    PRIMARY KEY CLUSTERED ([LgsId] ASC)
);

