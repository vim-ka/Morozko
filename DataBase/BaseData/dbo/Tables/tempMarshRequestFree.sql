CREATE TABLE [dbo].[tempMarshRequestFree] (
    [ID]      INT             IDENTITY (1, 1) NOT NULL,
    [nAZS]    VARCHAR (50)    NULL,
    [AddrAZS] VARCHAR (150)   NULL,
    [posx]    FLOAT (53)      NULL,
    [posy]    FLOAT (53)      NULL,
    [extcode] VARCHAR (50)    NULL,
    [weight]  DECIMAL (15, 4) NULL,
    [remark]  VARCHAR (500)   NULL,
    [cost]    MONEY           NULL,
    [Del]     BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tempMarshRequestFree_ID_copy] PRIMARY KEY CLUSTERED ([ID] ASC)
);

