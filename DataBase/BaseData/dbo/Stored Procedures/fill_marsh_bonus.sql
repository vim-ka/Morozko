CREATE procedure dbo.fill_marsh_bonus
as
begin
  
  update dbo.tempmarsh set mhid=(select m.mhid from marsh m where m.marsh=dbo.tempmarsh.marsh and m.nd=dbo.tempmarsh.Nd)
  

  if object_id('tempdb..#tErrors') is not null
  drop table #tErrors
  
  select 'Рейс не существует' as rem, ND, Marsh, Bonus, mhid  into #tErrors from tempmarsh where mhid is null
  
  insert into #tErrors (rem, ND, Marsh, Bonus, mhid)
  select 'Рейс продублирован' as rem, ND, Marsh, Bonus, mhid  from tempmarsh where mhid in
  (select mhid from tempmarsh group by mhid having count(mhid)>1)
  
  if not exists(select * from #tErrors)
  begin
    update n set n.bonus=x.bonus
    from nearlogistic.nllistpaydet n
    join (select t.mhid, t.bonus from dbo.tempmarsh t) x on x.mhid=n.mhid
    
    print('Успешно обновлено')
  end
  else select * from #tErrors

end