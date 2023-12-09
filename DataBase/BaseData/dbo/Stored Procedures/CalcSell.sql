

create procedure CalcSell
  @day0 datetime, @day1 datetime, @day2 datetime, @day3 datetime
as begin
--  if EXISTS(select * from sysobjects where id = object_id('temp1') and sysstat & 0xf = 3) drop table temp1;
  declare @temp1 table (B_ID  int, fam varchar(35), sell1 money, sell2 money, sell3 money);
  insert  into @temp1 select b_id, max(fam) as fam, sum(sp) as sell1, 0 as sell2, 0 as sell3 from NC where ND between @Day0 and @Day1-1 group by b_id;
  insert  into @temp1 select b_id, max(fam) as fam, 0 as sell1, sum(sp) as sell2, 0 as sell3 from NC where ND between @Day1 and @Day2-1 group by b_id;
  insert  into @temp1 select b_id, max(fam) as fam, 0 as sell1, 0 as sell2, sum(sp) as sell3 from NC where ND between @Day2 and @Day3 group by b_id;
  select b_id, max(fam),sum(sell1)as sell1, sum(sell2)as sell2, sum(sell3)as sell3 from @temp1 group by b_id order by b_id;
end