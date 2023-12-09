CREATE TABLE [RetroB].[BasFond] (
    [FondID]   INT             IDENTITY (1, 1) NOT NULL,
    [FondName] VARCHAR (80)    NULL,
    [Remark]   VARCHAR (40)    NULL,
    [RestRub]  DECIMAL (12, 2) NULL,
    [Otv]      INT             DEFAULT ((-1)) NULL,
    PRIMARY KEY CLUSTERED ([FondID] ASC)
);

