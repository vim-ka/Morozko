CREATE TABLE [dbo].[MarketRequestSogl] (
    [id]           INT             IDENTITY (1, 1) NOT NULL,
    [mrid]         INT             NULL,
    [depid]        INT             NULL,
    [upplankol]    INT             DEFAULT ((0)) NULL,
    [upplanweight] NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [upplanproc]   NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [extplankol]   INT             DEFAULT ((0)) NULL,
    [ostplankol]   INT             DEFAULT ((0)) NULL,
    [comm]         VARCHAR (512)   NULL,
    [sogl]         BIT             DEFAULT ((0)) NULL,
    [nd_sogl]      DATETIME        DEFAULT (getdate()) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

