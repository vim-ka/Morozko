CREATE TABLE [NearLogistic].[marshrequests_points] (
    [point_id]     INT            IDENTITY (1, 1) NOT NULL,
    [point_name]   NVARCHAR (50)  DEFAULT ('') NOT NULL,
    [point_adress] NVARCHAR (500) NOT NULL,
    [posx]         FLOAT (53)     NULL,
    [posy]         FLOAT (53)     NULL,
    [isdel]        BIT            DEFAULT ((0)) NOT NULL,
    [tmDeliv]      VARCHAR (5)    NULL,
    [extcode]      VARCHAR (50)   NULL,
    [reg_id]       VARCHAR (5)    NULL,
    CONSTRAINT [PK__marshreq__024136122AF6286E] PRIMARY KEY CLUSTERED ([point_id] ASC)
);

