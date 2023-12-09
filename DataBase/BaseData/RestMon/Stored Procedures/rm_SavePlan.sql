CREATE procedure RestMon.rm_SavePlan
  @Hitag int,  @Sklad smallint, @MinRest int, @GetPart int, @tip smallint=1
as
begin
  if exists(select * from RestMon.rm_job where Sklad=@sklad and @Hitag=Hitag) 
    update RestMon.rm_job set MinRest=@MinRest, GetPart=@GetPart, Tip=@Tip where Sklad=@sklad and @Hitag=Hitag;
  else 
    insert into RestMon.rm_job(hitag,sklad,minrest,getpart, Tip)
    values(@hitag, @sklad, @minrest, @getpart, @Tip);
end;