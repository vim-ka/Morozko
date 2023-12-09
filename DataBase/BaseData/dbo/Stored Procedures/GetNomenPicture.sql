CREATE PROCEDURE dbo.GetNomenPicture
@ngrp int,
@producerID int
AS
BEGIN
  declare @preKPK varchar(3)
  declare @prePC varchar(3)
  declare @routeKPK varchar(100)
  declare @routePC varchar(100)
  declare @wKPK int
  declare @wPC int

  set @preKPK=(select top 1 substring(param,charindex('$',param)+1,len(param)-charindex('$',param)) prefKPK from Config where param like '%для КПК%')
  set @prePC=(select top 1 substring(param,charindex('$',param)+1,len(param)-charindex('$',param)) prefKPK from Config where param like '%для Десктопа%')
  set @wKPK=(select top 1 val from Config where param like '%для КПК%')
  set @wPC=(select top 1 val from Config where param like '%для Десктопа%')
  set @routeKPK=(select val from Config where param like '%КаталогИзображенийКПК%')
  set @routePC=(select val from Config where param like '%КаталогИзображений%')

  select n.hitag,
         n.name,
         iif(n.fname is null,'не заполнено',n.fname) fname,
         g.GrpName,
         (select gp.GrpName from gr gp where gp.Ngrp=g.Parent) [ParentName],
         (select gp.GrpName from gr gp where gp.Ngrp=g.MainParent) [MainParentName],
         @preKPK+'*'+cast(hitag as varchar) [KPK],
         @prePC+'*'+cast(hitag as varchar) [PC],
         @routeKPK [routeKPK],
         @routePC+cast(hitag as varchar)+'\' [routePC],
         @wKPK [wKPK],
         @wPC [wPC]
  from nomen n
  join gr g on g.ngrp=n.ngrp
  where n.ngrp=iif(@ngrp=-1,n.ngrp,@ngrp)
        and g.AgInvis=0
        and n.LastProducerID=iif(@producerID=-1,n.LastProducerID,@producerID)
        --and n.disab=0
        --and n.inactive=0
  order by g.MainParent,g.Parent,g.ngrp,n.[name]
END