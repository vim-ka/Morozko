CREATE procedure EditDef 
 @pin int, @tip tinyint, @gpName varchar(100),@gpIndex char(6),
 @gpAddr varchar(100),@gpRs varchar(20),@gpCs varchar(20),
 @gpBank varchar(60),@gpBik varchar(9),@gpInn varchar(12),
 @gpKpp varchar(9),@brName varchar(100),@brIndex char(6),
 @brAddr varchar(100),@brRs varchar(20),@brCs varchar(20),
 @brBank varchar(60),@brBik varchar(9),@brInn varchar(12),
 @brKpp varchar(9)
AS
begin
 /*if @gpName='' and @gpIndex='' and @gpAddr='' and @gpRs='' 
    and @gpCs=''  and @gpBank='' and @gpBik='' and @gpInn=''
    and @gpKpp=''
    and @brName='' and @brIndex='' and @brAddr='' and @brRs='' 
    and @brCs=''  and @brBank='' and @brBik='' and @brInn=''
    and @brKpp='' 
    delete from Def where Pin=@Pin and Tip=1;*/

   if EXISTS(select pin from Def where Pin=@Pin and tip=@tip) 
   update Def set 
   gpName=@gpName, gpIndex=@gpIndex,
   gpAddr=@gpAddr, gpRs=@gpRs, gpCs=@gpCs,
   gpBank=@gpBank, gpBik=@gpBik, gpInn=@gpInn, gpKpp=@gpKpp,
   brName=@brName, brIndex=@brIndex,
   brAddr=@brAddr, brRs=@brRs, brCs=@brCs,
   brBank=@brBank, brBik=@brBik, brInn=@brInn, brKpp=@brKpp
   where Pin=@Pin and tip=@tip;
   
 else insert into Def(pin,tip,brName,brIndex,brAddr,brRs,brCs,brBank,brBik,brInn,
    brKpp,gpName,gpIndex,gpAddr,gpRs,gpCs,gpBank,gpBik,gpInn,gpKpp)
    values(@pin,@tip,@brName,@brIndex,@brAddr,@brRs,@brCs,@brBank,@brBik,@brInn,
    @brKpp,@gpName,@gpIndex,@gpAddr,@gpRs,@gpCs,@gpBank,@gpBik,@gpInn,@gpKpp)

END