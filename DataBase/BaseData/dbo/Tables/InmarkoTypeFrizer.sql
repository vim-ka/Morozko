CREATE TABLE [dbo].[InmarkoTypeFrizer] (
    [mdl]    INT            NOT NULL,
    [Name]   VARCHAR (60)   NULL,
    [Value]  DECIMAL (8, 3) NULL,
    [Parent] VARCHAR (20)   NULL,
    UNIQUE NONCLUSTERED ([mdl] ASC)
);

