-------------------------------------------------------------------
-- This module is designed to receive a checksum of GNSS messages,
-- Such as crc8 and crc16 checksum.
-------------------------------------------------------------------
-- Copyright 2021-2022 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

checksum = {}

local function decimalToHex(num)
    if num == 0 then
        return '0'
    end
    local neg = false
    if num < 0 then
        neg = true
        num = num * -1
    end
    local hexstr = "0123456789ABCDEF"
    local result = ""
    while num > 0 do
        local n = math.mod(num, 16)
        result = string.sub(hexstr, n + 1, n + 1) .. result
        num = math.floor(num / 16)
    end
    if neg then
        result = '-' .. result
    end
    return result
end

local function BitXOR(a, b)
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra ~= rb then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end

    if a < b then a = b end
    while a > 0 do
        local ra = a % 2
        if ra > 0 then c = c + p end
        a, p = (a - ra) / 2, p * 2
    end
    return c
end

local function BitAND(a, b)
    local p, c = 1,0
    while a > 0 and b > 0 do
        local ra, rb = a%2, b%2
        if ra + rb > 1 then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p*2
    end
    return c
end

local function rshift(x, by)
  return math.floor(x / 2 ^ by)
end


-- Checksum for NMEA data (CRC8)
function checksum.crc8(data)
	local crc8 = string.sub(data,  #data - 1)
	data = string.sub(data, 2, #data - 3)

	local b_sum = string.byte(data, 1)
	for i = 2, #data do
		b_sum = BitXOR(b_sum, string.byte(data, i))
	end

	return decimalToHex(b_sum) == crc8 and true or false
end

-- Checksum for Wialone IPS (CRC16)
function checksum.crc16(s)
   assert(type(s) == 'string')
   local crc16 = 0x0000
   for i = 1, #s do
       local c = s:byte(i)
       crc16 = BitXOR(crc16, c)
       for j = 1, 8 do
           local k = BitAND(crc16, 1)
           crc16 = rshift(crc16, 1)
           if k ~= 0 then
               crc16 = BitXOR(crc16, 0xA001)
           end
       end
   end
   return decimalToHex(crc16)
end

return checksum
