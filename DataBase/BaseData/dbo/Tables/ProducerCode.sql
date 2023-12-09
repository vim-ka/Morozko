CREATE TABLE [dbo].[ProducerCode] (
    [ProducerCodeId] INT          IDENTITY (1, 1) NOT NULL,
    [ProducerId]     INT          NULL,
    [Code]           VARCHAR (50) NULL,
    CONSTRAINT [PK_ProducerCode_IdCode] PRIMARY KEY CLUSTERED ([ProducerCodeId] ASC)
);

