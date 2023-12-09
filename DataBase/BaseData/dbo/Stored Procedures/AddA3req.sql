CREATE PROCEDURE dbo.AddA3req
  @ND datetime, @OP int, @Ncod int, @sp money, @sc money,
  @Done tinyint, @Our_Id tinyint, @doc_nom varchar(10), @doc_date  datetime,
  @comp varchar(16), @Ncom int,@SkMan varchar(30), @GrMan varchar(30), @NumTN varchar(200),@a3id int OUT
as
BEGIN

insert into A3req (ND,OP,Ncod,sp,sc,Done,Our_Id,Ncom,doc_nom,doc_date,comp,SkMan,GrMan,NumTN)
values (@ND,@OP, @Ncod, @sp, @sc,@Done,@Our_Id,@Ncom,@doc_nom,@doc_date,@comp,@SkMan,@GrMan,@NumTN);

 set @a3id=@@IDENTITY
 select @a3id  
END