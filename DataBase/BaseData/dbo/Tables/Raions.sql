CREATE TABLE [dbo].[Raions] (
    [Rn_id]  NUMERIC (3)  IDENTITY (0, 1) NOT NULL,
    [Obl_ID] NUMERIC (2)  NULL,
    [RName]  VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([Rn_id] ASC),
    CONSTRAINT [Raions_fk] FOREIGN KEY ([Obl_ID]) REFERENCES [dbo].[Obl] ([Obl_ID])
);


GO
ALTER TABLE [dbo].[Raions] NOCHECK CONSTRAINT [Raions_fk];

