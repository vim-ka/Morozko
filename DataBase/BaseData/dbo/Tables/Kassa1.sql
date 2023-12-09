CREATE TABLE [dbo].[Kassa1] (
    [KassID]      INT            IDENTITY (1, 1) NOT NULL,
    [nd]          DATETIME       CONSTRAINT [DF__Kassa1__nd__060EB63F] DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [tm]          CHAR (8)       DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Oper]        INT            NULL,
    [Act]         VARCHAR (4)    NULL,
    [SourDate]    DATETIME       NULL,
    [Nnak]        INT            NULL,
    [Plata]       MONEY          CONSTRAINT [DF__Kassa1__Plata__7B4643B2] DEFAULT (0) NOT NULL,
    [Fam]         VARCHAR (100)  NULL,
    [P_ID]        INT            NULL,
    [B_ID]        INT            NULL,
    [V_ID]        INT            NULL,
    [Ncod]        INT            NULL,
    [Remark]      VARCHAR (100)  NULL,
    [RashFlag]    INT            NULL,
    [LostFlag]    INT            NULL,
    [LastFlag]    TINYINT        NULL,
    [Op]          INT            NULL,
    [Bank_ID]     INT            DEFAULT ((0)) NULL,
    [Our_ID]      INT            NULL,
    [BankDay]     DATETIME       NULL,
    [Actn]        TINYINT        CONSTRAINT [DF__Kassa1__Actn__2C88998B] DEFAULT (0) NULL,
    [Ck]          TINYINT        NULL,
    [Thr]         INT            NULL,
    [ThrFam]      VARCHAR (100)  NULL,
    [DocNom]      INT            NULL,
    [OrigRecn]    INT            NULL,
    [ForPrint]    TINYINT        CONSTRAINT [DF__Kassa1__ForPrint__324172E1] DEFAULT (1) NULL,
    [SourDatNom]  BIGINT         NULL,
    [StNom]       INT            DEFAULT ((0)) NULL,
    [FromBank_ID] SMALLINT       DEFAULT ((0)) NULL,
    [SkladNo]     INT            NULL,
    [DepID]       INT            DEFAULT ((0)) NULL,
    [B_idPlat]    INT            DEFAULT ((0)) NULL,
    [OperOld]     INT            NULL,
    [NDInp]       DATETIME       NULL,
    [InBank]      BIT            DEFAULT ((0)) NULL,
    [Nalog]       NUMERIC (4, 2) DEFAULT ((0)) NULL,
    [RemarkPlat]  VARCHAR (100)  NULL,
    [pin]         INT            DEFAULT ((0)) NULL,
    [platarez]    MONEY          NULL,
    [DCK]         INT            DEFAULT ((0)) NULL,
    [KassaNo]     INT            DEFAULT ((0)) NULL,
    [RealOper]    BIT            DEFAULT ((0)) NULL,
    [OldKassID]   INT            DEFAULT ((0)) NULL,
    CONSTRAINT [Kassa1_pk] PRIMARY KEY CLUSTERED ([KassID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Kassa1_idx6]
    ON [dbo].[Kassa1]([OrigRecn] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20170224-134352]
    ON [dbo].[Kassa1]([StNom] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_idx5]
    ON [dbo].[Kassa1]([Oper] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161127-142410]
    ON [dbo].[Kassa1]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_idx3]
    ON [dbo].[Kassa1]([nd] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_idx2]
    ON [dbo].[Kassa1]([Bank_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_idx]
    ON [dbo].[Kassa1]([BankDay] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_idx4]
    ON [dbo].[Kassa1]([SourDatNom] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_Nd_Pid_idx]
    ON [dbo].[Kassa1]([nd] ASC, [P_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_Nd_Oper_idx]
    ON [dbo].[Kassa1]([nd] ASC, [Oper] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_Nd_Ncod_idx]
    ON [dbo].[Kassa1]([nd] ASC, [Ncod] ASC);


GO
CREATE NONCLUSTERED INDEX [Kassa1_Nd_Bid_idx]
    ON [dbo].[Kassa1]([nd] ASC, [B_ID] ASC);


GO


 CREATE TRIGGER [dbo].[trg_kassa1_u1] ON [dbo].[Kassa1]
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
          insert into kassa1Log (KassID, nd, tm, Oper, Act, SourDate, Nnak, Plata, Fam, P_ID, B_ID, V_ID, Ncod, Remark, RashFlag, LostFlag, LastFlag, Op, Bank_ID, Our_ID, BankDay, Actn, Ck, Thr, ThrFam, DocNom, OrigRecn, ForPrint, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, B_idPlat, OperOld, NDInp, InBank, Nalog, RemarkPlat, pin, platarez, DCK, KassaNo, RealOper, [type])
          select KassID, nd, tm, Oper, Act, SourDate, Nnak, Plata, Fam, P_ID, B_ID, V_ID, Ncod, Remark, RashFlag, LostFlag, LastFlag, Op, Bank_ID, Our_ID, BankDay, Actn, Ck, Thr, ThrFam, DocNom, OrigRecn, ForPrint, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, B_idPlat, OperOld, NDInp, InBank, Nalog, RemarkPlat, pin, platarez, DCK, KassaNo, RealOper, 2 from inserted
      end
GO
 create trigger trg_kassa1_d
      on kassa1
      for delete
      as
      begin
          insert into kassa1Log (KassID, nd, tm, Oper, Act, SourDate, Nnak, Plata, Fam, P_ID, B_ID, V_ID, Ncod, Remark, RashFlag, LostFlag, LastFlag, Op, Bank_ID, Our_ID, BankDay, Actn, Ck, Thr, ThrFam, DocNom, OrigRecn, ForPrint, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, B_idPlat, OperOld, NDInp, InBank, Nalog, RemarkPlat, pin, platarez, DCK, KassaNo, RealOper, [type])
          select KassID, nd, tm, Oper, Act, SourDate, Nnak, Plata, Fam, P_ID, B_ID, V_ID, Ncod, Remark, RashFlag, LostFlag, LastFlag, Op, Bank_ID, Our_ID, BankDay, Actn, Ck, Thr, ThrFam, DocNom, OrigRecn, ForPrint, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, B_idPlat, OperOld, NDInp, InBank, Nalog, RemarkPlat, pin, platarez, DCK, KassaNo, RealOper, 1 from deleted
      end
GO
CREATE TRIGGER [dbo].[trgInsKassa1] ON [dbo].[Kassa1]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  declare @Oper int
  declare @DCK int
  declare @StNom int
  declare @P_id int,@i int
  declare @Plata money
  declare @RealPlata money
  declare @Nalog float
   declare @Our_id_k int
  declare @FirmsGroup int
  declare @RashFlag bit
  
  select @Oper = Oper, @StNom = StNom, @Plata = Plata, @P_id=P_id, @Nalog = nalog, @Our_id_k=Our_id from inserted
  select @FirmsGroup=FirmGroup from firmsconfig where Our_id=@Our_id_k
  select @RashFlag=RashFlag from KsOper where Oper=@Oper
  
  update FirmsConfig set KassaVal=KassaVal+iif(@RashFlag=1,-1,1)*@Plata where Our_id=@Our_ID_k
  update FirmsGroup set KassaVal=KassaVal+iif(@RashFlag=1,-1,1)*@Plata where FirmsGroupID=@FirmsGroup
  if @Oper = -2
  begin
    declare @Nnak int,
            @SourDate datetime,
            @kassID int,  
            @Our_id int,
            @pin int
    select @Nnak = NNak,@SourDate = SourDate, @kassID = kassID, @pin = b_id, @DCK=DCK from inserted
    --select @ND = SourDate from inserted
    update NC set Fact=Fact+@Plata where DatNom=dbo.InDatNom(@NNak,@SourDate) 
    select @our_id = our_id from defcontract where dck=@DCK
    --if @our_id = 6 or @our_id = 8 update kassa1 set ck=3 where kassID=@kassID 
 
  end
  else
  if @Oper = -1
  begin
    declare @Ncom int
    select @Ncom = NNak from inserted
    update Comman set Plata=Plata+@Plata where Ncom=@Ncom
  end
  else
  if (@Oper = 59) and (@StNom is not null) and (@StNom > 0)
  begin
    if @Nalog>0 set @Plata=Round(@Plata/(1+@Nalog/100),2)
    if exists (select * from PsScores where StNom=@StNom)
       update psScores set Must=Must + @Plata where StNom=@StNom
    else
       insert into PSScores (p_id,stid,must,begdate) values (@StNom/100,@StNom-(@StNom/100)*100,@Plata,CONVERT([varchar],getdate(),(104)))
  end  
  else
  if (@Oper = 10) and (@StNom is not null) and (@StNom > 0)
  begin
    if @Nalog>0 set @Plata=Round(@Plata/(1+@Nalog/100),2)  
    if exists (select * from PsScores where StNom=@StNom)
    begin
      update psScores set Must=Must - @Plata where StNom=@StNom    
      update psScores set OverMust=OverMust - @Plata where StNom=@StNom and DaysDelay>0   
    end  
    else  
      insert into PSScores (p_id,stid,must,begdate) values (@StNom/100,@StNom-(@StNom/100)*100,-@Plata,CONVERT([varchar],getdate(),(104)))
  end    
 
END
GO
CREATE TRIGGER dbo.trg_Kassa1_u ON dbo.Kassa1
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
        declare @K int, @KD int, @FieldName varchar(50), @Temp sql_variant, @TempOLD sql_variant, @First bit
        declare @TN nvarchar(500)
        DECLARE @ParmDefinition nvarchar(500)
        set @First=1
        Declare @CURSOR Cursor  

        set @CURSOR  = Cursor scroll
        for select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS
        where TABLE_NAME ='Kassa1' and  TABLE_SCHEMA='dbo'    
        open @CURSOR
        

        
        select 0 as kls,i.* into #TempTable from inserted i inner join inserted i1 on i.KassID=i1.KassID
        
        insert into #TempTable select 1 as kls,* from deleted

        fetch next from @CURSOR into @FieldName


        while @@FETCH_STATUS = 0
        begin
        
             set @K=(select KassID from deleted)
            
             SET @ParmDefinition = N'@Temp1 sql_variant OUTPUT';
             set @TN=N'set @Temp1=(select '+@FieldName+' from #TempTable where kls=0)'
             EXEC sp_executeSQL @TN, @ParmDefinition, @Temp1=@Temp OUTPUT
             
             SET @ParmDefinition = N'@TempOLD1 sql_variant OUTPUT';
             set @TN=N'set @TempOLD1=(select '+@FieldName+' from #TempTable where kls=1)'
             EXEC sp_executeSQL @TN, @ParmDefinition, @TempOLD1=@TempOLD OUTPUT
             if @Temp<>@TempOLD
             begin
               if @First=1 
               begin
                 insert into Kassa1Rec(type,KassID)
                 values (0,@K)
                 set @KD=SCOPE_IDENTITY()
                 set @First=0
               end
               insert into Kassa1RecDET (ISPR,FieldName,Old_value,New_Value)
               values (@KD,@FieldName,@TempOLD,@Temp) 
             end
             
          fetch next from @CURSOR into @FieldName
        end
        Close @CURSOR
        deallocate @CURSOR  end
GO
 create trigger trg_kassa1_i
      on kassa1
      for insert
      as
      begin
          insert into kassa1Log (KassID, nd, tm, Oper, Act, SourDate, Nnak, Plata, Fam, P_ID, B_ID, V_ID, Ncod, Remark, RashFlag, LostFlag, LastFlag, Op, Bank_ID, Our_ID, BankDay, Actn, Ck, Thr, ThrFam, DocNom, OrigRecn, ForPrint, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, B_idPlat, OperOld, NDInp, InBank, Nalog, RemarkPlat, pin, platarez, DCK, KassaNo, RealOper, [type])
          select KassID, nd, tm, Oper, Act, SourDate, Nnak, Plata, Fam, P_ID, B_ID, V_ID, Ncod, Remark, RashFlag, LostFlag, LastFlag, Op, Bank_ID, Our_ID, BankDay, Actn, Ck, Thr, ThrFam, DocNom, OrigRecn, ForPrint, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, B_idPlat, OperOld, NDInp, InBank, Nalog, RemarkPlat, pin, platarez, DCK, KassaNo, RealOper, 0  from inserted
      end
GO
CREATE TRIGGER [dbo].[trgDelKassa1] ON [dbo].[Kassa1]
WITH EXECUTE AS CALLER
FOR DELETE
AS
BEGIN
  declare @Plata money
  declare @SourDatNom int
  declare @Oper int
  declare @Nnak int
  declare @StNom int
  declare @Our_id_k int
  declare @FirmsGroup int
  declare @RashFlag bit
  
  select @Plata=Plata, @SourDatNom=SourDatNom, @Oper=oper, @Nnak=Nnak, @StNom=StNom, @Our_id_k=Our_id from deleted
  select @FirmsGroup=FirmGroup from firmsconfig where Our_id=@Our_id_k
  select @RashFlag=RashFlag from KsOper where Oper=@Oper
  
  update FirmsConfig set KassaVal=KassaVal+iif(@RashFlag=1,1,-1)*@Plata where Our_id=@Our_ID_k
  update FirmsGroup set KassaVal=KassaVal+iif(@RashFlag=1,1,-1)*@Plata where FirmsGroupID=@FirmsGroup
    
  if (@Oper = -1) and (@Nnak > 0) 
  begin
    update Comman set Plata = Plata - @Plata where Ncom = @Nnak
  end
  else
  if (@Oper = -2) and (@SourDatNom > 0)
  begin
    update NC set Fact = Fact - @Plata where DatNom = @SourDatNom
  end
  else
  if (@Oper = 59) and (@StNom is not null) and (@StNom > 0)
  begin
    update psScores set Must=Must - @Plata where StNom=@StNom
  end  
  else
  if (@Oper = 10) and (@StNom is not null) and (@StNom > 0)
  begin
    update psScores set Must=Must + @Plata where StNom=@StNom
  end  
 
  insert into kassa1Log (KassID, nd, tm, Oper, Act, SourDate, Nnak, Plata, Fam, P_ID, B_ID, V_ID, Ncod, Remark, RashFlag, LostFlag, LastFlag, Op, Bank_ID, Our_ID, BankDay, Actn, Ck, Thr, ThrFam, DocNom, OrigRecn, ForPrint, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, B_idPlat, OperOld, NDInp, InBank, Nalog, RemarkPlat, pin, platarez, DCK, KassaNo, RealOper, [type])
  select KassID, nd, tm, Oper, Act, SourDate, Nnak, Plata, Fam, P_ID, B_ID, V_ID, Ncod, Remark, RashFlag, LostFlag, LastFlag, Op, Bank_ID, Our_ID, BankDay, Actn, Ck, Thr, ThrFam, DocNom, OrigRecn, ForPrint, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, B_idPlat, OperOld, NDInp, InBank, Nalog, RemarkPlat, pin, platarez, DCK, KassaNo, RealOper, 1 from deleted
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Реальная операция с деньгами', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'RealOper';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер кассового места', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'KassaNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор с контрагентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код поставщика услуг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Налог', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'Nalog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'По банку', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'InBank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата прихода ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'NDInp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код плательщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'B_idPlat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер склада', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'SkladNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код доверенности', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Kassa1', @level2type = N'COLUMN', @level2name = N'OrigRecn';

