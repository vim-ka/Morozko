CREATE TABLE [dbo].[ReqTorgT] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [nd]              DATETIME        NULL,
    [naim]            VARCHAR (200)   NULL,
    [orgform]         VARCHAR (50)    NULL,
    [isseti]          INT             NULL,
    [setiname]        INT             NULL,
    [uraddress]       VARCHAR (250)   NULL,
    [factaddress]     VARCHAR (512)   NULL,
    [ogrn]            VARCHAR (100)   NULL,
    [postav]          INT             NULL,
    [inn]             VARCHAR (15)    NULL,
    [kpp]             VARCHAR (10)    NULL,
    [dogovornum]      VARCHAR (15)    NULL,
    [dogovordate]     DATETIME        NULL,
    [otsrochka]       INT             NULL,
    [oplataform]      INT             NULL,
    [banknaim]        VARCHAR (250)   NULL,
    [bankrs]          VARCHAR (20)    NULL,
    [bankcs]          VARCHAR (20)    NULL,
    [bankbik]         VARCHAR (9)     NULL,
    [contactlico]     VARCHAR (50)    NULL,
    [phonett]         VARCHAR (50)    NULL,
    [torgagent]       INT             NULL,
    [supername]       VARCHAR (50)    NULL,
    [regiondostavki]  VARCHAR (5)     NULL,
    [categorytt]      VARCHAR (100)   NULL,
    [squarett]        NUMERIC (7, 2)  NULL,
    [formattt]        INT             NULL,
    [pokuptt]         INT             NULL,
    [coordttX]        VARCHAR (50)    CONSTRAINT [DF__ReqTorgT__coordt__0AEADBFA] DEFAULT ((0)) NULL,
    [coordttY]        VARCHAR (50)    CONSTRAINT [DF__ReqTorgT__coordt__09F6B7C1] DEFAULT ((0)) NULL,
    [pechat]          INT             NULL,
    [dop1]            VARCHAR (100)   NULL,
    [dop2]            VARCHAR (100)   NULL,
    [dop3]            VARCHAR (100)   NULL,
    [dop4]            VARCHAR (100)   NULL,
    [dop5]            VARCHAR (100)   NULL,
    [dop6]            VARCHAR (100)   NULL,
    [dop7]            VARCHAR (100)   NULL,
    [dop8]            VARCHAR (100)   NULL,
    [dop9]            VARCHAR (100)   NULL,
    [dop10]           VARCHAR (100)   NULL,
    [p_id]            INT             NULL,
    [ogrn_date]       DATETIME        NULL,
    [newpin]          INT             NULL,
    [status]          INT             DEFAULT ((1)) NULL,
    [work_tm]         VARCHAR (15)    NULL,
    [dost_tm]         VARCHAR (8)     NULL,
    [urproverka]      BIT             DEFAULT ((0)) NULL,
    [comment]         VARCHAR (100)   NULL,
    [fromclosed]      BIT             DEFAULT ((0)) NULL,
    [bnk_code]        INT             DEFAULT ((-1)) NULL,
    [odz_buh]         INT             CONSTRAINT [DF__ReqTorgT__odz_bu__1C755AAF] DEFAULT ((-2)) NULL,
    [gosreg]          INT             DEFAULT ((-1)) NULL,
    [sudebprist]      INT             DEFAULT ((-1)) NULL,
    [sudebisp]        INT             DEFAULT ((-1)) NULL,
    [credit]          INT             DEFAULT ((-1)) NULL,
    [depchiefsolve]   INT             DEFAULT ((-1)) NULL,
    [sudebpristsum]   NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [sudebispsum]     NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [creditsum]       NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [creditproverka]  BIT             DEFAULT ((0)) NULL,
    [dop11]           VARCHAR (100)   NULL,
    [odz_otkaz_comm]  VARCHAR (512)   NULL,
    [email]           VARCHAR (64)    NULL,
    [gpkpp]           VARCHAR (10)    NULL,
    [taxvalue]        INT             DEFAULT ((0)) NULL,
    [naimgp]          VARCHAR (200)   NULL,
    [goid]            INT             NULL,
    [fullname]        VARCHAR (256)   NULL,
    [fiodir]          VARCHAR (256)   NULL,
    [osntxt]          VARCHAR (32)    NULL,
    [osnnum]          VARCHAR (32)    NULL,
    [osndate]         DATETIME        NULL,
    [fiodirrp]        VARCHAR (256)   NULL,
    [postindex]       VARCHAR (6)     NULL,
    [orgformidx]      INT             DEFAULT ((-1)) NULL,
    [ismaster]        BIT             DEFAULT ((0)) NULL,
    [scannd]          DATETIME        NULL,
    [dck]             INT             NULL,
    [nettype]         INT             DEFAULT ((0)) NULL,
    [defcontracttip]  INT             DEFAULT ((2)) NULL,
    [defcontractnaim] VARCHAR (128)   NULL,
    CONSTRAINT [UQ__ReqTorgT__3213E83E447F1221] UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE TRIGGER dbo.trg_ReqTorgT_u ON dbo.ReqTorgT
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
        where TABLE_NAME ='ReqTorgT' and TABLE_SCHEMA='dbo'     
        open @CURSOR
        

        
        select 0 as nom,i.* into #TempTable from inserted i inner join inserted i1 on i.id=i1.id
        
        insert into #TempTable select 1 as nom,* from deleted

        fetch next from @CURSOR into @FieldName


        while @@FETCH_STATUS = 0
        begin
        
             set @K=(select id from deleted)
            
             SET @ParmDefinition = N'@Temp1 sql_variant OUTPUT';
             set @TN=N'set @Temp1=(select '+@FieldName+' from #TempTable where Nom=0)'
             EXEC sp_executeSQL @TN, @ParmDefinition, @Temp1=@Temp OUTPUT
             
             SET @ParmDefinition = N'@TempOLD1 sql_variant OUTPUT';
             set @TN=N'set @TempOLD1=(select '+@FieldName+' from #TempTable where Nom=1)'
             EXEC sp_executeSQL @TN, @ParmDefinition, @TempOLD1=@TempOLD OUTPUT
             if isnull(@Temp,'')<>isnull(@TempOLD,'')
             begin
               if @First=1 
               begin
                 insert into ReqTorgTLog(type,id)
                 values (0,@K)
                 set @KD=SCOPE_IDENTITY()
                 set @First=0
               end
               insert into ReqTorgTLogDET (ISPR,FieldName,Old_value,New_Value)
               values (@KD,@FieldName,@TempOLD,@Temp) 
             end
             
          fetch next from @CURSOR into @FieldName
        end
        Close @CURSOR
        deallocate @CURSOR  end
GO
DISABLE TRIGGER [dbo].[trg_ReqTorgT_u]
    ON [dbo].[ReqTorgT];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'полное наименование контрагента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqTorgT', @level2type = N'COLUMN', @level2name = N'fullname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'грузоотправитель по договору', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqTorgT', @level2type = N'COLUMN', @level2name = N'goid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ag_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqTorgT', @level2type = N'COLUMN', @level2name = N'torgagent';

