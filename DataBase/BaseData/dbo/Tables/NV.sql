CREATE TABLE [dbo].[NV] (
    [nvId]      INT              IDENTITY (1, 1) NOT NULL,
    [DatNom]    BIGINT           NULL,
    [TekID]     INT              NULL,
    [Hitag]     INT              NULL,
    [Price]     DECIMAL (13, 5)  NOT NULL,
    [Cost]      DECIMAL (13, 5)  NOT NULL,
    [Kol]       DECIMAL (10, 3)  DEFAULT (0) NOT NULL,
    [Kol_B]     DECIMAL (10, 3)  DEFAULT (0) NOT NULL,
    [Sklad]     SMALLINT         NULL,
    [OrigPrice] DECIMAL (13, 5)  NULL,
    [ag_id]     INT              NULL,
    [UnID]      TINYINT          CONSTRAINT [DF__NV__UnID__088FF441] DEFAULT ((0)) NULL,
    [OrigUnid]  TINYINT          DEFAULT ((0)) NULL,
    [K]         DECIMAL (18, 10) DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([nvId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NV_hitag_idx]
    ON [dbo].[NV]([Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [NV_tekid_idx]
    ON [dbo].[NV]([TekID] ASC);


GO
CREATE NONCLUSTERED INDEX [NV_uq]
    ON [dbo].[NV]([DatNom] ASC, [TekID] ASC);


GO
CREATE NONCLUSTERED INDEX [NV_Datnom_idx]
    ON [dbo].[NV]([DatNom] ASC);


GO
CREATE TRIGGER [dbo].[trgNVIns] ON [dbo].[NV]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  declare @ID int,
          @Hitag int,
          @nvID int
  select @ID = TekID, @nvID = nvID, @Hitag=isnull(Hitag,0) from inserted
  if @Hitag = 0
  begin
    select @Hitag=Hitag from Visual where ID=@ID
    update NV set Hitag=@Hitag where nvID=@nvID
  end  
END
GO
DISABLE TRIGGER [dbo].[trgNVIns]
    ON [dbo].[NV];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ед.изм. в табл. Units', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NV', @level2type = N'COLUMN', @level2name = N'UnID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена склада в момент продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NV', @level2type = N'COLUMN', @level2name = N'OrigPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена закупки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NV', @level2type = N'COLUMN', @level2name = N'Cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NV', @level2type = N'COLUMN', @level2name = N'Price';

