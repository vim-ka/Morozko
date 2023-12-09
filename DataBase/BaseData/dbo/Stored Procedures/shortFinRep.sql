create procedure shortFinRep @day0 datetime, @day1 datetime
as
declare @ND datetime
declare @FullDeb decimal (12,2),@OverDeb decimal (12,2)
declare @FullCred decimal (12,2),@OverCred decimal (12,2)
begin
  create table #t(ND datetime, FullDeb decimal(12,2), OverDeb decimal(12,2),
    FullCred decimal(12,2), OverCred decimal(12,2));
  set @nd=@day0
  
  while(@nd<=@day1) begin
    if DatePart(day,@nd)=1 begin
      -- Кредиторская задолженность и просрочка:
      select 
        @FullCred = sum(cm.summacost+cm.izmen-cm.plata+cm.remove+cm.corr),
        @OverCred = sum(case 
            when cm.[date]+cm.srok>=@nd or cm.summacost+cm.izmen-cm.plata+cm.remove+cm.corr<0
            then 0
            else cm.summacost+cm.izmen-cm.plata+cm.remove+cm.corr
            end) 
      from 
        morozarc.dbo.arccm cm
        inner join vendors Ve on ve.ncod=cm.Ncod
      where 
        cm.WorKdate=@nd-1
        and ve.fam not like '%/холод%'
        and ve.refncod=0;
        
      -- Дебиторская задолженность и просрочка:
      select 
        @FullDeb = sum(zc.sp-zc.fact+zc.izmen+zc.BACk),
        @OverDeb = sum(case when morozdata.dbo.DatNomInDate(zc.datnom)+zc.srok>=@nd 
            then 0 
            else zc.sp-zc.fact+zc.izmen+zc.BACk end
            )
      from 
        morozarc.dbo.arczc zc
        inner join NC on nc.datnom=zc.datnom
      where 
        workdate=@nd-1
        and zc.srok>0
        and nc.Actn=0
        and nc.Frizer=0
        and nc.Tara=0;
      -- Записываем результат:
      insert into #t(ND,FullDeb,OverDeb,FullCred, OverCred)
      values(@ND,@FullDeb,@OverDeb,@FullCred, @OverCred)      
    end;
    set @nd=@ND+1
  end;
  select * from #t order by nd;
end