CREATE TABLE [NearLogistic].[nlMassType] (
    [nlMt]     INT          NOT NULL,
    [MtName]   VARCHAR (20) NULL,
    [MtClName] VARCHAR (20) NULL,
    [Order]    INT          DEFAULT ((0)) NULL,
    [Color]    VARCHAR (50) DEFAULT ('') NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__nlMassTy__6F8EEB70E44133DC]
    ON [NearLogistic].[nlMassType]([nlMt] ASC);

