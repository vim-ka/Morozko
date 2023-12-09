CREATE TABLE [dbo].[NCIzmen] (
    [NID]      INT          IDENTITY (1, 1) NOT NULL,
    [ND]       DATETIME     CONSTRAINT [DF__NCIzmen__ND__0B679CE2] DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]       VARCHAR (8)  DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [DatNom]   INT          NULL,
    [Nnak]     INT          NULL,
    [SellDate] DATETIME     NULL,
    [B_ID]     INT          NULL,
    [Izmen]    MONEY        NULL,
    [Remark]   VARCHAR (40) NULL,
    [OP]       SMALLINT     NULL,
    [nrID]     INT          NULL,
    [DCK]      INT          NOT NULL,
    CONSTRAINT [NCIzmen_pk] PRIMARY KEY CLUSTERED ([NID] ASC),
    CONSTRAINT [NCIzmen_fk] FOREIGN KEY ([nrID]) REFERENCES [dbo].[NCIzmenReason] ([nrID]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [NCIzmen_idx4]
    ON [dbo].[NCIzmen]([B_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [NCIzmen_idx3]
    ON [dbo].[NCIzmen]([DatNom] ASC);


GO
CREATE NONCLUSTERED INDEX [NCIzmen_idx]
    ON [dbo].[NCIzmen]([ND] ASC);


GO
CREATE NONCLUSTERED INDEX [NCIzmen_idx2]
    ON [dbo].[NCIzmen]([DCK] ASC);


GO
CREATE TRIGGER [dbo].[trgInsNCIzmen] ON [dbo].[NCIzmen]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  declare @Izmen money
  declare @DatNom int
  select @DatNom = DatNom,@Izmen = Izmen from inserted
  update NC set Izmen=Izmen+@Izmen where DatNom=@DatNom
END