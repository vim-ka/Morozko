CREATE TABLE [NearLogistic].[MarshRequestsRecDET] (
    [ISPR_DET]  INT           IDENTITY (1, 1) NOT NULL,
    [ISPR]      INT           NOT NULL,
    [FieldName] VARCHAR (128) NULL,
    [Old_Value] SQL_VARIANT   NULL,
    [New_Value] SQL_VARIANT   NULL
);

