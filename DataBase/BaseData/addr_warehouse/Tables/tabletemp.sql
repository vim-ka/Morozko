CREATE TABLE [addr_warehouse].[tabletemp] (
    [id]  INT           IDENTITY (1, 1) NOT NULL,
    [txt] VARCHAR (MAX) NULL,
    [nd]  DATETIME      DEFAULT (getdate()) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

