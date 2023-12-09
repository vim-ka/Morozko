CREATE PROCEDURE dbo.DefCalcFields
AS
BEGIN
  Declare @Date Datetime
  set @Date=dbo.today()
  
  update Def set Oborot= (select  IsNull(Sum(Sp),0)
                          from  NC
                           where Nd>=@Date-31 and Nd<=@Date-1 
                              and NC.B_id=Def.pin)
  
  -- Нет больше поля SPICE:
--  update Def set OborotIce= (select IsNull(Sum(SPice),0)
--                             from  NC
--                             where Nd>=@Date-31 and Nd<=@Date-1 
--                              and NC.B_id=Def.pin)
                              
-- Нет больше поля SpPf:
--  update Def set OborotPf= (select IsNull(Sum(SPpf),0)
--                             from  NC
--                             where Nd>=@Date-31 and Nd<=@Date-1 
--                              and NC.B_id=Def.pin)
                              

/*   
  
  update NCOver set NDDolg=(select cast((GETDATE()- min(ND+Srok) )as int) as NDDolg
                            from NCOver nco
                            where Sp+Izmen>Fact and nco.DatNom=NCOver.DatNom)
                            
                            
  update NCOver set Overdue=(select Isnull(Sum(SP+Izmen-fact),0)
                            from NCOver nco
                            where SP+Izmen>Fact and nco.DatNom=NCOver.DatNom)
  
  update Def set Ag_GRP=(select
                            CASE
                                when (max(NDDolg)>=10) and (max(NDDolg)<=17) then 1
                                when  max(NDDolg)>17 then 2 else 0
                            END as AgGRP
						    from NCOver
                            where B_Id=Def.pin)*/
 

END