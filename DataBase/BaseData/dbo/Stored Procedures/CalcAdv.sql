CREATE procedure CalcAdv @day0 datetime, @day1 datetime
as
BEGIN

  IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[TempAOMain]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
  DROP TABLE [dbo].[TempAOMain];

  select a.ag_id,  ag.fam,  a."pin",  d.brFam,  sum(a.qty/nm.minp)  as QBox
  into TempAOMain
  from advorder a 
   inner join agents ag on ag.ag_id=a.ag_id 
   inner join nomen nm on nm.hitag=a.hitag and nm.minp>0
   inner join SREP_BR d on d.b_id=a.pin
   where a."date" between @day0 and @day1
  group by a.ag_id,  ag.fam,  a."pin",  d.brFam
  order by a.ag_id,  a."pin";
  
end