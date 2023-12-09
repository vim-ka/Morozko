CREATE TABLE [dbo].[InpdetVetSvid_copy] (
    [IDIVS]          INT           IDENTITY (1, 1) NOT NULL,
    [inId]           INT           NULL,
    [VetId]          INT           NULL,
    [id]             INT           NULL,
    [IdIs]           INT           NULL,
    [OurID]          INT           NULL,
    [ProducerCodeID] INT           NULL,
    [VetUuid]        VARCHAR (255) NULL,
    CONSTRAINT [PK_InpdetVetSvid_ID_copy] PRIMARY KEY CLUSTERED ([IDIVS] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_InpdetVetSvid_VetId]
    ON [dbo].[InpdetVetSvid_copy]([VetId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_InpdetVetSvid_id]
    ON [dbo].[InpdetVetSvid_copy]([id] ASC);

