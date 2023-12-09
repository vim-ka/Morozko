CREATE TABLE [db_FarLogistic].[dlDamage] (
    [id]         INT          IDENTITY (11, 1) NOT NULL,
    [DamageName] VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

