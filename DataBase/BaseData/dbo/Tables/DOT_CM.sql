CREATE TABLE [dbo].[DOT_CM] (
    [Ncom]     INT             IDENTITY (1, 1) NOT NULL,
    [NcDatNom] INT             NULL,
    [Dot]      INT             NULL,
    [ND]       DATETIME        DEFAULT (CONVERT([char](10),getdate(),(104))) NULL,
    [SC]       DECIMAL (12, 2) NULL,
    [SP]       DECIMAL (12, 2) NULL,
    [Plata]    DECIMAL (12, 2) CONSTRAINT [DF__DOT_CM__Plata__4CC12A4A] DEFAULT ((0)) NULL,
    [NcStfNom] VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([Ncom] ASC)
);

