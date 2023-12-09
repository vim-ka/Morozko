CREATE PROCEDURE dbo.NewMarshNom @ND datetime,@Marsh int output, @mhid int=0 output
AS
BEGIN
  create table #Tmp (RecId int IDENTITY(1, 1) NOT NULL, id int);

if @Nd is not null
begin
  insert into #Tmp (id)
  select 
    case when ROW_NUMBER() OVER(ORDER BY marsh) in 
                               (select marsh from Marsh where nd=@ND) then 0
    else  ROW_NUMBER() OVER(ORDER BY marsh)
    end
  from Marsh
  where Nd=@Nd

  set @Marsh=(select IsNull(min(id),0) from #tmp where id>0)
  if @Marsh=0 --or @Marsh is null
    set @Marsh=(select IsNull(max(Marsh),0)+1 from Marsh where nd=@ND and Marsh<>99)
  if @Marsh=99 
   set @Marsh=@Marsh+1;
 
  if (IsNull(@Marsh,0)<>0)and (@Nd is not null)
    insert into Marsh (ND,Marsh) VALUES(@Nd,@Marsh)
   
  set @mhid=SCOPE_IDENTITY(); 

  declare @msh int;
  set @msh=0;
  set @msh=(select IsNull(Marsh,0) from Marsh where ND=@Nd and Marsh=99);
  if IsNull(@msh,0)<>99 
    insert into Marsh (ND,Marsh,Driver) VALUES(@Nd,99,'Самовывоз') 
end;
END