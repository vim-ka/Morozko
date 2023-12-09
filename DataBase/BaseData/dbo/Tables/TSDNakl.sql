CREATE TABLE [dbo].[TSDNakl] (
    [id]       INT           NOT NULL,
    [mhid]     INT           NULL,
    [marsh]    INT           NULL,
    [nnak]     INT           NULL,
    [nm]       INT           NULL,
    [hitag]    INT           NULL,
    [name]     VARCHAR (100) NULL,
    [qty]      INT           NULL,
    [sklad]    INT           NULL,
    [minp]     INT           NULL,
    [barcode]  VARCHAR (20)  NULL,
    [barcodem] VARCHAR (20)  NULL,
    [mstatus]  INT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

