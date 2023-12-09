CREATE procedure EditDef5
 @pin int, @tip tinyint, @gpName varchar(100),@gpIndex char(6),
 @gpAddr varchar(100),@gpRs varchar(20),@gpCs varchar(20),
 @gpBank varchar(60),@gpBik varchar(9),@gpInn varchar(12),
 @gpKpp varchar(9),@brName varchar(100),@brIndex char(6),
 @brAddr varchar(100),@brRs varchar(20),@brCs varchar(20),
 @brBank varchar(60),@brBik varchar(9),@brInn varchar(12),
 @brKpp varchar(9), @BrPhone varchar(20), @gpPhone varchar(20),
 @PosX numeric(9,6), @PosY numeric(9,6), @Remark varchar(40), @FullDocs bit,
 @limit money, @OGRN varchar(15), @tmDin varchar(15), @tmWork varchar(15),
 @Obl_id numeric(3,0), @Rn_id numeric(4,0), @Disab bit 
AS
begin
 if EXISTS(select pin from Def where Pin=@Pin and tip=@tip) 
   update Def set 
   gpName=@gpName, gpIndex=@gpIndex,
   gpAddr=@gpAddr, gpRs=@gpRs, gpCs=@gpCs,
   gpBank=@gpBank, gpBik=@gpBik, gpInn=@gpInn, gpKpp=@gpKpp,
   brName=@brName, brIndex=@brIndex,
   brAddr=@brAddr, brRs=@brRs, brCs=@brCs,
   brBank=@brBank, brBik=@brBik, brInn=@brInn, brKpp=@brKpp,
   brPhone=@brPhone, gpPhone=@gpPhone, PosX=@PosX, PosY=@PosY, /*Remark=@Remark,*/
   FullDocs=@FullDocs, limit=@limit, OGRN=@OGRn, tmDin=@tmDin, tmWork=@tmWork,
   Obl_id=@Obl_id, Rn_id=@Rn_id, Disab=@Disab 
   where Pin=@Pin and tip=@tip;
   
 else insert into Def(pin,tip,brName,brIndex,brAddr,brRs,brCs,brBank,brBik,brInn,
    brKpp,gpName,gpIndex,gpAddr,gpRs,gpCs,gpBank,gpBik,gpInn,gpKpp, brPhone,gpPhone,PosX,PosY,Remark,
    FullDocs,limit,OGRN,tmDin,tmWork,Obl_id,Rn_id,Disab)
    values(@pin,@tip,@brName,@brIndex,@brAddr,@brRs,@brCs,@brBank,@brBik,@brInn,
    @brKpp,@gpName,@gpIndex,@gpAddr,@gpRs,@gpCs,@gpBank,@gpBik,@gpInn,@gpKpp, @brPhone,@gpPhone,@PosX,@PosY,
    @Remark,@FullDocs, @limit,@OGRN,@tmDin,@tmWork,@Obl_id,@Rn_id, @Disab)
END