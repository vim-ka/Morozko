CREATE TABLE [dbo].[lgRemAgBase] (
    [IDL]       INT           IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME      NULL,
    [OP]        NUMERIC (3)   NULL,
    [Ag_id]     INT           NULL,
    [Add_ag_id] VARCHAR (254) NULL,
    [Rem]       TEXT          NULL,
    UNIQUE NONCLUSTERED ([IDL] ASC)
);

