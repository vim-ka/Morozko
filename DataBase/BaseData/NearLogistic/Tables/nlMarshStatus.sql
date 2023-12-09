CREATE TABLE [NearLogistic].[nlMarshStatus] (
    [MStatus]    INT          IDENTITY (1, 1) NOT NULL,
    [StatusName] VARCHAR (25) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__nlMarshS__533279242E8E8202]
    ON [NearLogistic].[nlMarshStatus]([MStatus] ASC);

