CREATE TABLE [dbo].[SertifCondition] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [guid]        VARCHAR (255) NULL,
    [uuid]        VARCHAR (255) NULL,
    [number]      VARCHAR (255) NULL,
    [text]        VARCHAR (MAX) NULL,
    [strict]      BIT           NULL,
    [DiseaseUuid] VARCHAR (255) NULL,
    [DiseaseGuid] VARCHAR (255) NULL,
    [DiseaseName] VARCHAR (255) NULL,
    [active]      BIT           NULL,
    [last]        BIT           NULL,
    CONSTRAINT [PK_SertifCondition_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

