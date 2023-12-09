CREATE TABLE [dbo].[MarketRequestRes] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [mrid]      INT             NULL,
    [ag_id]     INT             NULL,
    [b_id]      INT             NULL,
    [hitag]     INT             NULL,
    [kol]       NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [planval]   NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [cnt]       INT             DEFAULT ((0)) NULL,
    [tip]       INT             DEFAULT ((0)) NULL,
    [host_name] VARCHAR (48)    DEFAULT (host_name()) NULL,
    [Obl_ID]    INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

