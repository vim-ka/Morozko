CREATE TABLE [dbo].[FrizContractDet] (
    [cdID]       INT          IDENTITY (1, 1) NOT NULL,
    [ContractID] INT          NULL,
    [DetTip]     SMALLINT     NULL,
    [CondID]     INT          NULL,
    [Nom]        INT          NULL,
    [InvNom]     VARCHAR (20) NULL,
    [FabNom]     VARCHAR (15) NULL,
    [Nname]      VARCHAR (60) NULL,
    [Korzin]     SMALLINT     NULL,
    [fsID]       INT          NULL,
    [mPrice]     MONEY        NULL,
    [B_ID]       INT          NULL,
    [Kol]        SMALLINT     DEFAULT ((1)) NULL,
    [DopNoExcep] INT          DEFAULT ((0)) NULL,
    [fsIDold]    INT          NULL,
    [DCK]        INT          DEFAULT ((0)) NULL,
    CONSTRAINT [PK_FRIZCONTRACTDET] PRIMARY KEY NONCLUSTERED ([cdID] ASC),
    CONSTRAINT [FrizContractDet_fk] FOREIGN KEY ([ContractID]) REFERENCES [dbo].[FrizContract] ([ContractID]) ON UPDATE CASCADE,
    CONSTRAINT [FrizContractDet_fk2] FOREIGN KEY ([DetTip]) REFERENCES [dbo].[FrizerTip] ([Tip]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [Relationship_3_FK]
    ON [dbo].[FrizContractDet]([CondID] ASC);


GO
CREATE NONCLUSTERED INDEX [Relationship_2_FK]
    ON [dbo].[FrizContractDet]([DetTip] ASC);


GO
CREATE NONCLUSTERED INDEX [Relationship_1_FK]
    ON [dbo].[FrizContractDet]([ContractID] ASC);


GO
CREATE TRIGGER [dbo].[FrizContractDet_tri] ON [dbo].[FrizContractDet]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  declare @ND datetime, @Nom int
  set @ND=cast(floor(cast(getdate() as decimal(38,19))) as datetime)
  select @Nom = Nom from inserted
  update Frizer set DateSell=@ND where Nom=@Nom
  update Frizer set DateStart=@ND where Nom=@Nom and DateStart is null
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ доп. согл. (оборудование исключено из договора) ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizContractDet', @level2type = N'COLUMN', @level2name = N'DopNoExcep';

