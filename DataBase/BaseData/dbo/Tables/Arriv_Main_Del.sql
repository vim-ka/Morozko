CREATE TABLE [dbo].[Arriv_Main_Del] (
    [AM_ID]    INT          IDENTITY (1, 1) NOT NULL,
    [ND]       DATETIME     DEFAULT (getdate()) NULL,
    [Ncod]     INT          NULL,
    [Doc_Nom]  VARCHAR (10) NULL,
    [Doc_Date] DATETIME     NULL,
    [Comp]     VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([AM_ID] ASC)
);

