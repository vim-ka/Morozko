CREATE PROCEDURE dbo.DisplayDistPay

AS
BEGIN
  create table #Table1 (start float, finish float,pay money, tip int)
 
  declare @type int
  DECLARE @CUR CURSOR 
  SET @CUR  = CURSOR SCROLL
  FOR select typeID
      from MarshType
      order by typeID 

  OPEN @CUR 

  FETCH NEXT FROM @CUR INTO @type

  WHILE @@FETCH_STATUS = 0
  BEGIN
  
          Declare  @st float,@distPay money,@weight float
          DECLARE @CURSOR CURSOR 
          SET @CURSOR  = CURSOR SCROLL
          FOR select weight,distPay
              from DistKmPay
              where typeId=@type
              order by weight 

          OPEN @CURSOR 

          FETCH NEXT FROM @CURSOR INTO @weight,@distPay
          set @st=0;
          insert into #Table1 (start, finish,pay,tip)
           values(@st,@weight,@distPay,@type)
          set @st=@weight;
          
          WHILE @@FETCH_STATUS = 0
          BEGIN
            FETCH NEXT FROM @CURSOR INTO  @weight,@distPay
            if @st<>@weight
              insert into #Table1 (start, finish,pay,tip)
              values(@st,@weight,@distPay,@type)
            set @st=@weight;
          END
          CLOSE @CURSOR 
          
    FETCH NEXT FROM @CUR INTO @type

  END
  CLOSE @CUR 
  
  select 'от '+cast(start as varchar)+' до '+
               cast(finish as varchar)+' кг' as Name, pay,finish,tip,A.mtName,
               (select Max(finish) from #Table1  where tip=t.tip) as MaxFn
  from  #Table1 t
    
  left join
  (select mtName,typeid
  from MarshType)A on A.typeId=tip
  order by tip
END