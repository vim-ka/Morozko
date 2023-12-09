CREATE TABLE [dbo].[SertifDelLog] (
    [sid]       INT          IDENTITY (1, 1) NOT NULL,
    [nd]        DATETIME     NULL,
    [tm]        VARCHAR (8)  NULL,
    [act]       VARCHAR (4)  NULL,
    [DatNom]    INT          NULL,
    [Op]        INT          NULL,
    [CompName]  VARCHAR (15) NULL,
    [SertifDoc] INT          NULL,
    CONSTRAINT [PK_SertifDelLog_sid] PRIMARY KEY CLUSTERED ([sid] ASC)
);

