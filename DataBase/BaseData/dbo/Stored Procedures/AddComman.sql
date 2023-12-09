CREATE procedure AddComman
  @Ncom int OUTPUT,@Ncod int,
  @Date datetime, @Time varchar(8), @SummaPrice money, 
  @SummaCost money, @izmen money, @isprav money, @remove money,
  @ostat money, @realiz money, @plata money, @closdate datetime,
  @srok int, @Op smallint, @Our_ID smallint,
  @doc_nom varchar(10), @doc_date datetime, @comp varchar(16), @izmensc money,
  @corr money, @errflag int, @copyexists int, @origdate datetime
as
begin
  if (@ClosDate<'19500101') set @ClosDate=null; 
  if (@doc_date<'19500101') set @doc_date=null;   
  if (@origdate<'19500101') set @origdate=null;   
  set @srok=(select srok from vendors where ncod=@Ncod);
  set @Ncom=(select Max(Ncom)+1 from Comman where Ncom>0); 
insert into Comman_ (Ncom,Ncod,
   Date ,Time ,SummaPrice ,SummaCost ,izmen, isprav, remove, ostat, realiz,
   plata, closdate, srok, op, Our_ID, doc_nom, doc_date, comp, izmensc, corr, errflag,
   copyexists, origdate)
values (@Ncom, @Ncod,
   @Date, @Time, @SummaPrice, @SummaCost, @izmen, @isprav, @remove, @ostat, @realiz,
   @plata, @closdate, @srok, @op, @Our_ID, @doc_nom, @doc_date, @comp, @izmensc, @corr, @errflag,
   @copyexists, @origdate);
   
end