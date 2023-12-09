CREATE TABLE [dbo].[FUserStartPoint] (
    [id]   INT            IDENTITY (1, 1) NOT NULL,
    [uin]  INT            NULL,
    [posx] NUMERIC (9, 6) NULL,
    [posy] NUMERIC (9, 6) NULL,
    [prim] VARCHAR (255)  NULL,
    [p_id] INT            NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

