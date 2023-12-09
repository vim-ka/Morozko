CREATE TABLE [dbo].[InpdetVetSvid] (
    [IDIVS]          INT           IDENTITY (1, 1) NOT NULL,
    [inId]           INT           NULL,
    [VetId]          INT           NULL,
    [id]             INT           NULL,
    [IdIs]           INT           NULL,
    [OurID]          INT           NULL,
    [ProducerCodeID] INT           NULL,
    [VetUuid]        VARCHAR (255) NULL,
    CONSTRAINT [PK_InpdetVetSvid_ID] PRIMARY KEY CLUSTERED ([IDIVS] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_InpdetVetSvid_id]
    ON [dbo].[InpdetVetSvid]([id] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_InpdetVetSvid_VetId]
    ON [dbo].[InpdetVetSvid]([VetId] ASC);

