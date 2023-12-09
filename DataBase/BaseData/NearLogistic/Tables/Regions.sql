CREATE TABLE [NearLogistic].[Regions] (
    [Reg_ID]   VARCHAR (5)     NOT NULL,
    [Place]    VARCHAR (250)   NULL,
    [Rast]     NUMERIC (10, 2) NULL,
    [MainReg]  VARCHAR (2)     NULL,
    [Priority] SMALLINT        DEFAULT ((1)) NULL,
    CONSTRAINT [Regions_pk_Regions] PRIMARY KEY CLUSTERED ([Reg_ID] ASC)
);

