CREATE TABLE [db_FarLogistic].[dlExpenseType] (
    [ExpenceTypeID]   INT          IDENTITY (1, 1) NOT NULL,
    [ExpenceTypeName] VARCHAR (20) NULL,
    CONSTRAINT [dlExpenseType_pk] PRIMARY KEY CLUSTERED ([ExpenceTypeID] ASC)
);

