CREATE PROCEDURE [NearLogistic].PrintSkg 
@mhid int
AS
BEGIN
  select distinct 
      @mhid [mhid],
         sg.Skg,
   sg.SkgName,
         c.ND,
         c.Marsh,
   cast('013'+format(c.nd,'ddMMyy')+right('00'+cast(c.marsh as varchar),3)+iif(len(cast(sg.skg as varchar))>2,'00',right('0'+cast(sg.skg as varchar),2)) as varchar(14)) [barcode]
  from [NearLogistic].MarshRequests mr 
       join NC c on mr.ReqID=c.DatNom and mr.ReqType=0 
       join NV v on c.datnom=v.datnom
       join SkladList sl on v.Sklad=sl.SkladNo
       join SkladGroups sg on sg.skg=sl.skg
  where mr.mhid=@mhid
  order by Skg
END