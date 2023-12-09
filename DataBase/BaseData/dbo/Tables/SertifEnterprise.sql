CREATE TABLE [dbo].[SertifEnterprise] (
    [SertifEnterpriseID] INT            IDENTITY (1, 1) NOT NULL,
    [guid]               VARCHAR (255)  NULL,
    [uuid]               VARCHAR (255)  NULL,
    [name]               VARCHAR (255)  NULL,
    [number]             VARCHAR (255)  NULL,
    [address]            VARCHAR (2000) NULL,
    [type]               SMALLINT       NULL,
    [ownerGuid]          VARCHAR (255)  NULL,
    [ownerUuid]          VARCHAR (255)  NULL,
    [active]             BIT            NULL,
    [last]               BIT            NULL,
    [activityLocation]   VARCHAR (255)  NULL,
    CONSTRAINT [PK_SertifEnterprise_SertifBranchID] PRIMARY KEY CLUSTERED ([SertifEnterpriseID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [SertifEnterprise_idx3]
    ON [dbo].[SertifEnterprise]([number] ASC);


GO
CREATE NONCLUSTERED INDEX [SertifEnterprise_idx2]
    ON [dbo].[SertifEnterprise]([uuid] ASC);


GO
CREATE NONCLUSTERED INDEX [SertifEnterprise_idx]
    ON [dbo].[SertifEnterprise]([guid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на ХС, у которго это предприятие в ActivityLocationList', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifEnterprise';

