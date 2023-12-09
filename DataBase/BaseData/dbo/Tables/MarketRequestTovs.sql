CREATE TABLE [dbo].[MarketRequestTovs] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [mrid]     INT             NULL,
    [hitag]    INT             NULL,
    [price]    NUMERIC (16, 2) DEFAULT ((0)) NULL,
    [bonus]    BIT             DEFAULT ((0)) NULL,
    [active]   BIT             DEFAULT ((1)) NULL,
    [inactn]   BIT             DEFAULT ((1)) NULL,
    [slotid]   INT             CONSTRAINT [DF__MarketReq__sloti__1B02DEE0] DEFAULT ((-1)) NULL,
    [kol]      NUMERIC (16, 2) CONSTRAINT [DF__MarketReq__minvk__491EAF4B] DEFAULT ((1)) NULL,
    [required] BIT             DEFAULT ((0)) NULL,
    [edizm]    INT             DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [mrt_hitag_idx]
    ON [dbo].[MarketRequestTovs]([hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [mrt_mrid_idx]
    ON [dbo].[MarketRequestTovs]([mrid] ASC);

