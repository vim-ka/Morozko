CREATE TABLE [dbo].[ReestrPlat] (
    [NCOM]     NUMERIC (6)  NULL,
    [COM_DATE] DATETIME     NULL,
    [DATE]     DATETIME     NULL,
    [DOC_NOM]  VARCHAR (30) NULL,
    [DOC_DATE] DATETIME     NULL,
    [SUMMPL]   MONEY        NULL,
    [PLATR]    BIT          NULL,
    [NOMPP]    VARCHAR (30) NULL,
    [NCOD]     INT          NULL,
    [FAM]      VARCHAR (30) NULL,
    [ID]       INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_ReestrPlat] PRIMARY KEY CLUSTERED ([ID] ASC)
);

