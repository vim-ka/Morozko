CREATE TABLE [dbo].[PrintAttrib] (
    [paID]     INT          IDENTITY (1, 1) NOT NULL,
    [Our_ID]   INT          NULL,
    [gpOur_ID] INT          NULL,
    [DocType]  SMALLINT     NULL,
    [FieldNo]  SMALLINT     NULL,
    [FieldVal] VARCHAR (50) NULL,
    [day0]     DATETIME     DEFAULT ((20000101)) NULL,
    [day1]     DATETIME     DEFAULT ((20991231)) NULL,
    [PLID]     INT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([paID] ASC)
);

