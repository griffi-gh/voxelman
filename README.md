# voxelman
Powder toy LUA script manager

## Installation
1) Press "~" key
2) Copy&paste:
```lua
local a=http.get("https://raw.githubusercontent.com/griffi-gh/voxelman/main/autorun.lua")repeat socket.sleep(.1)until req:status()~='running'local b;if req:status()=='done'then local c,d=req:finish()if d==200 then b=true;local e=io.open('autorun.lua','wb')e:write(c)e:close()tpt.message_box('VOXELMAN Downloaded successfully','Please restart TPT')end end;if not b then tpt.throw_error('Download failed')end
```
3) Press "Enter"("Return") key
