CREATE function dbo.RemoveMask(@Mask varchar(500),@Input varchar(1000))
    returns varchar(1000)
begin
    declare @pos INT
    set @Pos = patindex(@Mask,@Input)
    while @Pos > 0
    begin
        set @Input = stuff(@Input,@pos,1,'')
        set @Pos = patindex(@Mask,@Input)
    end
    return @Input
end