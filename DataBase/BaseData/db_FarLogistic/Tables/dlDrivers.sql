CREATE TABLE [db_FarLogistic].[dlDrivers] (
    [ID]          INT           NULL,
    [Surname]     VARCHAR (100) NULL,
    [Firstname]   VARCHAR (100) NULL,
    [Middlename]  VARCHAR (100) NULL,
    [DriverDoc]   VARCHAR (15)  NULL,
    [Phone]       VARCHAR (100) NULL,
    [DateOfbirth] DATETIME      NULL,
    [PassNum]     VARCHAR (15)  NULL,
    [PassSeria]   VARCHAR (15)  NULL,
    [PassOtd]     VARCHAR (100) NULL,
    [PassDate]    DATETIME      NULL,
    [PassCode]    VARCHAR (10)  NULL,
    [PersID]      INT           NULL,
    [isDel]       BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [dlDrivers_uq] UNIQUE NONCLUSTERED ([ID] ASC)
);

