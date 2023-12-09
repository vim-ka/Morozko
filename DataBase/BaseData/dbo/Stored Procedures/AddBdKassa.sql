CREATE procedure AddBdKassa @PlanNd datetime,@DepID int,@Oper int,@Remark varchar(60),@Plata money,@Period int
as
begin
  insert into BdKassa (PlanNd,DepID,Oper,Remark,Plata,Period)
         values       (@PlanNd,@DepID,@Oper,@Remark,@Plata,@Period)
  SELECT @@IDENTITY AS NewID       
end