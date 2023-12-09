CREATE function MD5(@x varchar(8000)) returns varchar(32) as
begin

if @x is null
	return null

-- MD5 checksum calculation algorithm
-- Ported Transact SQL by Andrew Usachov (usa@rota.lv)
-- Original code at http://en.wikipedia.org/wiki/Md5

declare @i integer
declare @j integer

-- //Note: All variables are unsigned 32 bits and wrap modulo 2^32 when calculating
-- var int[64] r, k
declare @r char(192)
declare @k char(640)

-- //r specifies the per-round shift amounts
-- r[ 0..15] := {7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22} 
-- r[16..31] := {5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20}
-- r[32..47] := {4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23}
-- r[48..63] := {6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21}
select @r = 
'7  12 17 22 7  12 17 22 7  12 17 22 7  12 17 22 ' +
'5  9  14 20 5  9  14 20 5  9  14 20 5  9  14 20 ' +
'4  11 16 23 4  11 16 23 4  11 16 23 4  11 16 23 ' +
'6  10 15 21 6  10 15 21 6  10 15 21 6  10 15 21 '

-- //Use binary integer part of the sines of integers as constants:
-- for i from 0 to 63
--    k[i] := floor(abs(sin(i + 1)) ? (2 pow 32))
select @k = 
'36140903603905402710606105819 32504419664118548399120008042628217359554249261313' +
'17700354162336552879429492523323045631341804603682425462619527929650061236535329' +
'41291707863225465664643717713 3921069994359340860538016083  36344889613889429448' +
'568446438 3275163606410760333511635315012850285829424356351217353284732368359562' +
'42945887382272392833183903056242596577402763975236127289335341394696643200236656' +
'681279174 3936430074357244531776029189  36546028093873151461530742520 3299628645' +
'40963364521126891415287861239142375332411700485571239998069042939157732240044497' +
'187331335942643555522734768916130915164941494442263174756917718787259 3951481745'

-- //Initialize variables:
-- var int h0 := 0x67452301
-- var int h1 := 0xEFCDAB89
-- var int h2 := 0x98BADCFE
-- var int h3 := 0x10325476
declare @h0 bigint
declare @h1 bigint
declare @h2 bigint
declare @h3 bigint

select
	@h0 = 0x67452301,
	@h1 = 0xEFCDAB89,
	@h2 = 0x98BADCFE,
	@h3 = 0x10325476

-- //Pre-processing:
-- append "1" bit to message
-- append "0" bits until message length in bits ? 448 (mod 512)
-- append bit (bit, not byte) length of unpadded message as 64-bit little-endian integer to message

declare @bitlength bigint
select @bitlength = len(@x) * 8

select @x = @x
	+ char(0x80)
	+ replicate(char(0), 63 - (len(@x) + 8) % 64)
	+ char(@bitlength % 0x100)
	+ char(@bitlength / 0x100 % 0x100)
	+ char(@bitlength / 0x10000 % 0x100)
	+ char(@bitlength / 0x1000000 % 0x100)
	+ char(@bitlength / 0x100000000 % 0x100)
	+ char(@bitlength / 0x10000000000 % 0x100)
	+ char(@bitlength / 0x1000000000000 % 0x100)
	+ char(@bitlength / 0x100000000000000 % 0x100)

-- //Process the message in successive 512-bit chunks:
-- for each 512-bit chunk of message
declare @p int
select @p = 0

while @p < len(@x)
begin
	-- break chunk into sixteen 32-bit little-endian words w[i], 0 ? i ? 15

	-- //Initialize hash value for this chunk:
	-- var int a := h0
	-- var int b := h1
	-- var int c := h2
	-- var int d := h3
	declare @a bigint
	declare @b bigint
	declare @c bigint
	declare @d bigint

	select @a = @h0
	select @b = @h1
	select @c = @h2
	select @d = @h3

	-- //Main loop:
	-- for i from 0 to 63
	select @i = 0
	while @i < 64
	begin
		declare @f bigint
		declare @g int

	        -- if 0 ? i ? 15 then
		if @i between 0 and 15
	        	-- f := (b and c) or ((not b) and d)
			select	@f = (@b & @c) | ((~@b) & @d),
			-- g := i
			@g = @i
	        -- else if 16 ? i ? 31
		else if @i between 16 and 31
	        	-- f := (d and b) or ((not d) and c)
			select @f = (@d & @b) | ((~@d) & @c),
		        -- g := (5?i + 1) mod 16
			@g = (5 * @i + 1) % 16
	        -- else if 32 ? i ? 47
		else if @i between 32 and 47
		        -- f := b xor c xor d
			select @f = @b ^ @c ^ @d,
		        -- g := (3?i + 5) mod 16
			@g = (3 * @i + 5) % 16
	        -- else if 48 ? i ? 63
		else if @i between 48 and 63
		        -- f := c xor (b or (not d))
			select @f = @c ^ (@b | (~@d)),
		        -- g := (7?i) mod 16
			@g = (7 * @i) % 16

		select @f = @f & 0xFFFFFFFF
		declare @temp bigint

	        -- temp := d
	        -- d := c
	        -- c := b
	        -- b := b + leftrotate((a + f + k[i] + w[g]) , r[i])
	        -- a := temp

		select @temp = @d
		select @d = @c
		select @c = @b

		declare @arg1 bigint
		select @arg1 = (
			@a + @f + convert(bigint, substring(@k, @i * 10 + 1, 10)) +
			(((convert(bigint, ascii(substring(@x, @p + 4 * @g + 4, 1))) * 256) + ascii(substring(@x, @p + 4 * @g + 3, 1))) * 256 + ascii(substring(@x, @p + 4 * @g + 2, 1))) * 256 + ascii(substring(@x, @p + 4 * @g + 1, 1))
		) & 0xFFFFFFFF

		declare @arg2 int
		select @arg2 = convert(int, substring(@r, @i * 3 + 1, 3))
		
		select @b = (
			@b + ((@arg1 * power(2, @arg2)) | (@arg1 / power(2, 32 - @arg2)))
		) & 0xFFFFFFFF

		select @a = @temp

		select @i = @i + 1
	end
	
	-- //Add this chunk`s hash to result so far:
	-- h0 := h0 + a
	-- h1 := h1 + b
	-- h2 := h2 + c
	-- h3 := h3 + d
	select @h0 = (@h0 + @a) % 0x100000000
	select @h1 = (@h1 + @b) % 0x100000000
	select @h2 = (@h2 + @c) % 0x100000000
	select @h3 = (@h3 + @d) % 0x100000000

	select @p = @p + 64
end

-- var int digest := h0 append h1 append h2 append h3 //(expressed as little-endian)
return
	SubString('0123456789abcdef', @h0 / 0x10 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h0 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h0 / 0x1000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h0 / 0x100 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h0 / 0x100000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h0 / 0x10000 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h0 / 0x10000000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h0 / 0x1000000 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h1 / 0x10 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h1 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h1 / 0x1000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h1 / 0x100 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h1 / 0x100000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h1 / 0x10000 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h1 / 0x10000000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h1 / 0x1000000 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h2 / 0x10 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h2 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h2 / 0x1000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h2 / 0x100 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h2 / 0x100000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h2 / 0x10000 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h2 / 0x10000000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h2 / 0x1000000 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h3 / 0x10 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h3 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h3 / 0x1000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h3 / 0x100 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h3 / 0x100000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h3 / 0x10000 % 0x10 + 1, 1) +
	SubString('0123456789abcdef', @h3 / 0x10000000 % 0x10 + 1, 1) + SubString('0123456789abcdef', @h3 / 0x1000000 % 0x10 + 1, 1)
end