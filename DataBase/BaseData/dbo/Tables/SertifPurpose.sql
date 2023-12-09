CREATE TABLE [dbo].[SertifPurpose] (
    [PurposeID] INT           IDENTITY (1, 1) NOT NULL,
    [guid]      VARCHAR (255) NULL,
    [uuid]      VARCHAR (255) NULL,
    [name]      VARCHAR (255) NULL,
    [active]    BIT           NULL,
    [last]      BIT           NULL,
    CONSTRAINT [PK_SertifPurpose_PurposeID_copy] PRIMARY KEY CLUSTERED ([PurposeID] ASC)
);

