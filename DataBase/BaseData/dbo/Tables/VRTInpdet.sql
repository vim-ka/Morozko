CREATE TABLE [dbo].[VRTInpdet] (
    [inId]   INT             IDENTITY (1, 1) NOT NULL,
    [nd]     DATETIME        NULL,
    [ncom]   INT             NULL,
    [id]     INT             NULL,
    [hitag]  INT             NULL,
    [dater]  VARCHAR (20)    NULL,
    [srokh]  VARCHAR (20)    NULL,
    [weight] DECIMAL (19, 3) NULL,
    CONSTRAINT [PK_VRTInpdet_inId] PRIMARY KEY CLUSTERED ([inId] ASC)
);

