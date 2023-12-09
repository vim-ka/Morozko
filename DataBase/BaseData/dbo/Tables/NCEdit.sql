CREATE TABLE [dbo].[NCEdit] (
    [NCID]      INT            IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME       DEFAULT ([dbo].[today]()) NULL,
    [TM]        CHAR (8)       DEFAULT (CONVERT([varchar],getdate(),(8))) NULL,
    [Nnak]      INT            NULL,
    [DatNom]    BIGINT         NULL,
    [B_ID]      INT            NULL,
    [BrName]    VARCHAR (100)  NULL,
    [OP]        SMALLINT       NULL,
    [SP]        MONEY          NULL,
    [SC]        MONEY          NULL,
    [NewSP]     MONEY          NULL,
    [NewSC]     MONEY          NULL,
    [Mode]      INT            NULL,
    [Extra]     NUMERIC (6, 2) NULL,
    [Srok]      SMALLINT       NULL,
    [NalogEXST] BIT            NULL,
    [Nalog]     MONEY          NULL,
    [Our_ID]    TINYINT        NULL,
    [DCK]       INT            DEFAULT ((0)) NULL,
    [NewDCK]    INT            DEFAULT ((0)) NULL,
    [NewExtra]  NUMERIC (6, 2) NULL,
    CONSTRAINT [NCEdit_pk] PRIMARY KEY CLUSTERED ([NCID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NCEdit_idx]
    ON [dbo].[NCEdit]([DatNom] ASC);


GO
 create trigger trg_NCEdit_u
      on NCEdit
      for update
      as
      begin
          insert into NCEditLog (NCID, ND, TM, Nnak, DatNom, B_ID, BrName, OP, SP, SC, NewSP, NewSC, Mode, Extra, Srok, NalogEXST, Nalog, Our_ID, DCK, NewDCK, NewExtra, [type])
          select NCID, ND, TM, Nnak, DatNom, B_ID, BrName, OP, SP, SC, NewSP, NewSC, Mode, Extra, Srok, NalogEXST, Nalog, Our_ID, DCK, NewDCK, NewExtra, 2 from inserted
      end
GO
 create trigger trg_NCEdit_d
      on NCEdit
      for delete
      as
      begin
          insert into NCEditLog (NCID, ND, TM, Nnak, DatNom, B_ID, BrName, OP, SP, SC, NewSP, NewSC, Mode, Extra, Srok, NalogEXST, Nalog, Our_ID, DCK, NewDCK, NewExtra, [type])
          select NCID, ND, TM, Nnak, DatNom, B_ID, BrName, OP, SP, SC, NewSP, NewSC, Mode, Extra, Srok, NalogEXST, Nalog, Our_ID, DCK, NewDCK, NewExtra, 1 from deleted
      end
GO
 create trigger trg_NCEdit_i
      on NCEdit
      for insert
      as
      begin
          insert into NCEditLog (NCID, ND, TM, Nnak, DatNom, B_ID, BrName, OP, SP, SC, NewSP, NewSC, Mode, Extra, Srok, NalogEXST, Nalog, Our_ID, DCK, NewDCK, NewExtra, [type])
          select NCID, ND, TM, Nnak, DatNom, B_ID, BrName, OP, SP, SC, NewSP, NewSC, Mode, Extra, Srok, NalogEXST, Nalog, Our_ID, DCK, NewDCK, NewExtra, 0  from inserted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Новая наценка по накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCEdit', @level2type = N'COLUMN', @level2name = N'NewExtra';

