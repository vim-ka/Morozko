CREATE TABLE [dbo].[RentabCalcTypes] (
    [id]        SMALLINT      IDENTITY (1, 1) NOT NULL,
    [type_name] VARCHAR (255) NULL,
    [active]    BIT           DEFAULT ((1)) NULL,
    [sign]      SMALLINT      CONSTRAINT [DF__FinCalcTyp__Sign__5D6EF564] DEFAULT ((1)) NULL,
    [fixed]     BIT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

