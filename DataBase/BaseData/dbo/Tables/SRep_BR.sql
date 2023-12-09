CREATE TABLE [dbo].[SRep_BR] (
    [B_ID]   INT           NOT NULL,
    [BrFam]  VARCHAR (100) NULL,
    [Ag_id]  INT           DEFAULT (0) NULL,
    [Master] INT           DEFAULT (0) NULL,
    PRIMARY KEY CLUSTERED ([B_ID] ASC)
);

