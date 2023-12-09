CREATE TABLE [db_FarLogistic].[dlExpenceList] (
    [ExpenceListID] INT          IDENTITY (1, 1) NOT NULL,
    [ExpenceName]   VARCHAR (50) NULL,
    [ForFact]       BIT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ExpenceListID] ASC)
);

