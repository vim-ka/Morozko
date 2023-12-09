CREATE PROCEDURE dbo.FrizerList @Tip integer
AS
BEGIN

SELECT  f.Nom ,f.Tip ,f.Mode ,f.InvNom ,f.FabNom ,f.Nname ,f.Ncod ,f.DatePost ,f.OurId ,f.Ob ,f.Korzin ,f.Zamok ,f.Sticker ,f.B_ID,
        f.DateSell ,f.Remark ,f.DogNom ,f.Price ,f.DateCheck ,f.DateCheckAgent ,f.NCom ,f.SkladNo ,f.Procreator ,f.NCountry ,f.Cost,
        f.fsID ,f.mID ,f.CondID ,f.hitag ,f.StartPrice ,f.DateStart ,f.DateAct ,f.InmarkoTip ,f.InvNom2 ,f.ffid ,f.DCK ,f.length ,f.high,
        f.depth ,f.FMod ,f.Weight ,D.ContractNo,D.NDBeg, e.gpAddr, u.FuncName, k.StickName, m.Length as FLength, 
        m.High as FHigh, m.Depth as FDepth, m.Model,
        iif(isnull(dc.AG_ID,0) in (17,33,641), isnull(dc.PrevAG_ID,0),isnull(dc.AG_ID,0))  as Ag_ID,   
        a.SV_AG_ID as SV_ID, a.DepID, e.gpName, ev.brName AS Vendor
FROM frizer f LEFT JOIN
(select 
  CASE
    when isnull(NestNo,0)<>0 then cast(max(NestNo) as  varchar) +'Н'
    when DopContrNo=0 then cast(max(ContractNo) as  varchar)
    else
      cast(max(ContractNo) as  varchar)+'/'+cast(DopContrNo as Varchar) 
  end as ContractNo, C.nom, NDBeg from FrizContract fc
 join
 (select nom,max(Contractid) as Contractid
 from FrizContractDet where kol>0 and isnull(DopNoExcep,0)=0
 group by nom) C on C.Contractid=fc.Contractid
 group by C.nom,DopContrNo,NDBeg,NestNo) D on f.nom=D.nom
 left join Def e on f.b_id=e.pin 
 left join Def ev on f.ncod=ev.pin 
 left join FrizerFunc u on f.ffid=u.ffid
 left join FrizerStick k on f.fsID=k.fsID
 left join FrizerModel m on f.Fmod=m.Fmod
 left join DefContract dc on f.dck=dc.dck
 left join AgentList a on a.ag_id=iif(isnull(dc.AG_ID,0) in (17,33,641),isnull(dc.PrevAG_ID,0),isnull(dc.AG_ID,0)) 
 where f.tip=@Tip
 order by f.nom      

END