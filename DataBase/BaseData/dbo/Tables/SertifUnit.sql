CREATE TABLE [dbo].[SertifUnit] (
    [UnitID]         INT           IDENTITY (1, 1) NOT NULL,
    [guid]           VARCHAR (255) NULL,
    [uuid]           VARCHAR (255) NULL,
    [name]           VARCHAR (255) NULL,
    [fullname]       VARCHAR (255) NULL,
    [commonUnitGuid] VARCHAR (255) NULL,
    [factor]         INT           NULL,
    [MeasId]         INT           NULL,
    [active]         BIT           NULL,
    [last]           BIT           NULL,
    CONSTRAINT [PK_SertifUnit_UnitID_copy] PRIMARY KEY CLUSTERED ([UnitID] ASC)
);

