CREATE TABLE [dbo].[sDevices] (
    [DevID]        INT           IDENTITY (1, 1) NOT NULL,
    [DevK]         VARCHAR (100) NOT NULL,
    [Model]        VARCHAR (50)  NULL,
    [SerialNumber] VARCHAR (50)  NULL,
    CONSTRAINT [sTSD_pk] PRIMARY KEY CLUSTERED ([DevID] ASC)
);

