CREATE procedure dbo.RecalcNCSumm
@datnom bigint
as 
declare @SP decimal(12,2), @OrigSP decimal(14,4)
declare @SC decimal(12,2), @OrigSC decimal(14,4)
declare @Koeff decimal(12,5)
declare @b_id int, @dn bigint, @dn1 bigint, @done bit
-- declare @Extra decimal(12,2)
BEGIN	 
--  set transaction isolation level read uncommitted
  select @OrigSP=SP, @OrigSC=SC, @Koeff=1.0+Extra/100, @b_id=b_id from nc where datnom=@datnom;
  
  select @SP=round(@Koeff*sum(nv.Kol*nv.price),2), @SC=round(sum(nv.Kol*nv.cost),2)
  from nv 
  where datnom=@datnom
  
  if @SP<>@OrigSP or @SC<>@OrigSC 
  	update NC set sc=@sc, sp=@sp where DatNom=@datnom;

  if dbo.InDatNom(0,getdate())<=@datnom
  begin  
  	set @dn= @datnom / 10000 * 10000
  	set @dn1= @datnom / 10000 * 10000 + 9999
    set @done=iif(((select sum(sp) from nc where datnom>=@dn and datnom<=@dn1 and b_id=@b_id and sp>=0)>=1500),1,0)
    
    if @done=1
    update nc set done=@done 
    where datnom>=@dn 
          and datnom<=@dn1
          and b_id=@b_id
          and sp>=0
	end

END