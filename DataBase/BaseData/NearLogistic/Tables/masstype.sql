CREATE TABLE [NearLogistic].[masstype] (
    [nlMt]     INT          NOT NULL,
    [MtName]   VARCHAR (20) NULL,
    [MtClName] VARCHAR (20) NULL,
    [Order]    INT          NULL,
    [Color]    VARCHAR (50) NULL,
    [min_term] INT          DEFAULT ((0)) NOT NULL
);

