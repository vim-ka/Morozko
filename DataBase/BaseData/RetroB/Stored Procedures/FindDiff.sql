

CREATE procedure retrob.FindDiff @RBV int, @VedID int
as
begin
  create table #t (rbid int, OldBonus decimal(12,2) default 0, NewBonus decimal(12,2) default 0)

  insert into #t(rbid, oldbonus)
    select r.rbid, sum(r.Bonus) Bonus
    FROM
      RB_VEDOMdet R
      inner join rb_Main m on m.RbID=r.rbID
      where R.rbv = @RBV
    group by r.rBid

  insert into #t(rbid, newbonus)
   select
      d.rbid, 
      round(sum(isnull(d.Bonus,0)),2) as NewBonus
    from
      retrob.rb_rawdet d
    where
      d.vedid = @VEDID
    group by
      d.rbid
    order by d.rbid

 
  select 
    rbid, 
    round(sum(oldbonus)/1000,3) b0, round(sum(newbonus)/1000,3) b1, 
    round(sum(oldbonus)/1000,3)-round(sum(newbonus)/1000,3) as Delta,
    round(sum(newbonus)/(sum(oldbonus)+0.01),2) as K
  from #t group by rbid
  having abs(sum(oldbonus)-sum(newbonus))>1;

  select 
    round(sum(oldbonus)/1000,1) as OldTRBonus, 
  round(sum(newbonus)/1000,1) as NewTRBonusfrom 
  from #t;
end;