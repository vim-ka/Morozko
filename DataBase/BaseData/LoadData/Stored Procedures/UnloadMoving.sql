CREATE PROCEDURE [LoadData].UnloadMoving @DateStart datetime, @DateEnd datetime, @Our_id int, @From Bit=0, @PLID int=2
AS
BEGIN
    
  if @PLID = 2 /*Крым*/
  begin
    if @From = 0  
    begin
      select i.ND, 
             i.hitag, 
             iif(i.[Weight]>0,i.[Weight],i.Kol) as Qty,
             i.Cost*i.Kol as Seb
      from Izmen i join DefContract d on i.dck=d.DCK 
                   join SkladList s_old on i.sklad=s_old.SkladNo
                   join SkladList s_new on i.newsklad=s_new.SkladNo
                   join SkladGroups g_old on g_old.skg =s_old.Skg
                   join SkladGroups g_new on g_new.skg =s_new.Skg
      where i.ND>=@DateStart and i.ND<=@DateEnd and i.Act='Скла' 
            -- and i.NewSklad>99 and i.NewSklad<200 and i.Sklad<100
            and g_old.PLID=1 and g_new.PLID=2
            and d.ContrTip=1
      order by i.ND 
    end
    else
    begin
      select i.ND, 
             i.hitag, 
             iif(i.[Weight]>0,i.[Weight],i.Kol) as Qty,
             i.Cost*i.Kol as Seb
      from Izmen i join DefContract d on i.dck=d.DCK
                   join SkladList s_old on i.sklad=s_old.SkladNo
                   join SkladList s_new on i.newsklad=s_new.SkladNo
                   join SkladGroups g_old on g_old.skg =s_old.Skg
                   join SkladGroups g_new on g_new.skg =s_new.Skg
      where i.ND>=@DateStart and i.ND<=@DateEnd and i.Act='Скла' 
            --and i.Sklad>99 and i.Sklad<200 and i.NewSklad<100
            and g_old.PLID=2 and g_new.PLID=1
            and d.ContrTip=1
      order by i.ND 
    end  
  end
  else
  if @PLID = 3 /*Дорожка*/
  begin
    if @From = 0  
    begin
      select i.ND, 
             i.hitag, 
             iif(i.[Weight]>0,i.[Weight],i.Kol) as Qty,
             i.Cost*i.Kol as Seb
      from Izmen i join DefContract d on i.dck=d.DCK 
      where i.ND>=@DateStart and i.ND<=@DateEnd and i.Act='Скла' and i.NewSklad>399 and i.NewSklad<500 and i.Sklad<100
            and d.ContrTip=1
      order by i.ND 
    end
    else
    begin
      select i.ND, 
             i.hitag, 
             iif(i.[Weight]>0,i.[Weight],i.Kol) as Qty,
             i.Cost*i.Kol as Seb
      from Izmen i join DefContract d on i.dck=d.DCK
      where i.ND>=@DateStart and i.ND<=@DateEnd and i.Act='Скла'  and i.Sklad>399 and i.Sklad<500 and i.NewSklad<100
            and d.ContrTip=1
      order by i.ND 
    end  
  end
 
END