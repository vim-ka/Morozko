CREATE TABLE [dbo].[FrizDiscount] (
    [fdisc] INT      IDENTITY (1, 1) NOT NULL,
    [Tip]   SMALLINT NULL,
    [Srok]  SMALLINT NULL,
    CONSTRAINT [FrizDiscount_pk] PRIMARY KEY CLUSTERED ([fdisc] ASC),
    CONSTRAINT [FrizDiscount_fk] FOREIGN KEY ([Tip]) REFERENCES [dbo].[FrizerTip] ([Tip]) ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([fdisc] ASC)
);

