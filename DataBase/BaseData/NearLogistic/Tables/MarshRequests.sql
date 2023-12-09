CREATE TABLE [NearLogistic].[MarshRequests] (
    [mrID]        INT             IDENTITY (1, 1) NOT NULL,
    [mhID]        INT             NOT NULL,
    [ReqID]       INT             NOT NULL,
    [ReqType]     INT             NOT NULL,
    [ReqAction]   INT             NOT NULL,
    [ReqOrder]    INT             DEFAULT ((0)) NOT NULL,
    [DT]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [OP]          INT             NOT NULL,
    [Comp]        VARCHAR (50)    DEFAULT (host_name()) NULL,
    [PINTo]       INT             NOT NULL,
    [PINFrom]     INT             DEFAULT ((0)) NOT NULL,
    [Cost_]       DECIMAL (15, 2) DEFAULT ((0)) NULL,
    [Weight_]     DECIMAL (15, 2) DEFAULT ((0)) NULL,
    [Volume_]     DECIMAL (18, 5) DEFAULT ((0)) NULL,
    [ReqRemark]   VARCHAR (500)   DEFAULT ('') NULL,
    [KolBox_]     DECIMAL (15, 2) DEFAULT ((0)) NULL,
    [ag_id]       INT             DEFAULT ((0)) NOT NULL,
    [tmArrival]   CHAR (5)        DEFAULT (N'00:00') NOT NULL,
    [DelivCancel] BIT             DEFAULT ((0)) NOT NULL,
    [ReqND]       DATETIME        NULL,
    [liter_id]    INT             DEFAULT ((0)) NOT NULL,
    [distance]    INT             NULL,
    CONSTRAINT [PK_MarshRequests_mrID] PRIMARY KEY CLUSTERED ([mrID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MarshRequests_uq]
    ON [NearLogistic].[MarshRequests]([ReqID] ASC, [ReqType] ASC, [ReqAction] ASC);


GO
CREATE NONCLUSTERED INDEX [MarshRequests_idx4]
    ON [NearLogistic].[MarshRequests]([ReqID] ASC);


GO
CREATE NONCLUSTERED INDEX [MarshRequests_idx3]
    ON [NearLogistic].[MarshRequests]([ReqAction] ASC);


GO
CREATE NONCLUSTERED INDEX [MarshRequests_idx2]
    ON [NearLogistic].[MarshRequests]([ReqType] ASC);


GO
CREATE NONCLUSTERED INDEX [MarshRequests_idx]
    ON [NearLogistic].[MarshRequests]([mhID] ASC);


GO
 CREATE TRIGGER [NearLogistic].trg_MarshRequests_u ON NearLogistic.MarshRequests
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE, DELETE
AS
begin
  declare @K int, @KD int, @FieldName varchar(50), @Temp sql_variant, @TempOLD sql_variant, @First bit, 
          @TN nvarchar(500), @ParmDefinition nvarchar(500), @mrID int, @mhID int, @type int
          
  if exists(select 1 from inserted) and exists(select 1 from deleted) set @type=0
  else
  if exists(select 1 from inserted) and not exists(select 1 from deleted) set @type=1
  else 
  set @type=2

  select 0 as nom,i.* into #TempTable from inserted i inner join inserted i1 on i.mrid=i1.mrid    
  insert into #TempTable select 1 as nom,* from deleted

  declare @cursor_fields cursor  
  declare @cursor_records cursor        	

  set @cursor_fields  = cursor scroll
  for select name 
      from sys.columns 
      where object_id=object_id('nearlogistic.marshrequests')     
  open @cursor_fields
        
  set @cursor_records  = cursor scroll
  for select distinct mrID,mhID
  		from #TempTable
  open @cursor_records
         
  fetch next from @cursor_records into @mrID,@mhID

  while @@fetch_status = 0
  begin
    set @First=1
    fetch first from @cursor_fields into @FieldName
    
    while @@fetch_status = 0
    begin
      set @ParmDefinition = N'@Temp1 sql_variant OUTPUT';
      set @TN=N'set @Temp1=(select '+@FieldName+' from #TempTable where Nom=0 and mrID='+cast(@mrID as varchar)+')'
      exec sp_executeSQL @TN, @ParmDefinition, @Temp1=@Temp OUTPUT
                   
      set @ParmDefinition = N'@TempOLD1 sql_variant OUTPUT';
      set @TN=N'set @TempOLD1=(select '+@FieldName+' from #TempTable where Nom=1 and mrID='+cast(@mrID as varchar)+')'
      exec sp_executeSQL @TN, @ParmDefinition, @TempOLD1=@TempOLD OUTPUT
      
      if isnull(@Temp,'')<>isnull(@TempOLD,'')
      begin
        if @First=1
        begin
          insert into nearlogistic.MarshRequestsRec(type,mrid,mhID)
          values (@type,@mrID,@mhID)
          set @KD=scope_identity()
          set @First=0
        end
        	
        insert into nearlogistic.MarshRequestsRecDET (ISPR,FieldName,Old_value,New_Value)
        values (@KD,@FieldName,@TempOLD,@Temp)
      end
      
      fetch next from @cursor_fields into @FieldName
    end

    fetch next from @cursor_records into @mrID,@mhID
  end

  close @cursor_records
  deallocate @cursor_records

  close @cursor_fields
  deallocate @cursor_fields
end
GO
DISABLE TRIGGER [NearLogistic].[trg_MarshRequests_u]
    ON [NearLogistic].[MarshRequests];

