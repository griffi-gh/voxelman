local gif = require('gif')('image.gif')
local bit = require('bit')

local w,h = gif.get_width_height()
local pix = gif.read_matrix()
gif.close()

local data = string.char(w)..string.char(h)
print(w,h)

local function hexcolor(b)
  if b==-1 then
    return 0,0,0,0
  else
    return bit.rshift(bit.band(b,0xFF0000),4*4),bit.rshift(bit.band(b,0x00FF00),4*2),bit.band(b,0x0000FF),0xFF
  end
end

local col = 0
for j=1,h do
  for i=1,w do
    local col = pix[j][i]
    local r,g,b,a = hexcolor(col)
    print(r,g,b,a)
    data = data..string.char(r)..string.char(g)..string.char(b)..string.char(a)
  end
end

io.open('output.bin','wb'):write(data)