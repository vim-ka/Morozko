CREATE TABLE [dbo].[NC_StateLog] (
    [SlID]   INT         IDENTITY (1, 1) NOT NULL,
    [ND]     DATETIME    DEFAULT ([dbo].[today]()) NULL,
    [TM]     VARCHAR (8) CONSTRAINT [DF__NC_StateLog__TM__128BFDC2] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Datnom] INT         NULL,
    [OldST]  TINYINT     NULL,
    [NewSt]  TINYINT     NULL,
    [Op]     INT         NULL,
    PRIMARY KEY CLUSTERED ([SlID] ASC)
);

