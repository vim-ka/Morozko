CREATE procedure ReadLogDatsh
@StrDatnom varchar(15), @dn0 INT, @dn1 INT
as begin
  select top 1 
    l.lID, L.nd, L.tm, L.op, U.Fio,  L.comp, L.remark, L.param1, L.param3, L.param4
  from log L left join usrPwd U on U.Uin=L.Op
  where 
    (L.tip='datsh')
    and (L.param1 = @StrDatnom)
    and (cast(L.param1 as int) not in 
      (select datnom from nc where datnom between @dn0 and @dn1 and fam not like '%(ПЕРЕМЕЩЕНА)%'))
  order by l.lid desc
end