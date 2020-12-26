# voxelman
Powder toy LUA script manager

## Installation
1) Press "~" key
2) Copy:
```lua
local a=http.get("https://raw.githubusercontent.com/griffi-gh/voxelman/main/autorun.lua")repeat socket.sleep(.1)until a:status()~='running'local b;if a:status()=='done'then local c,d=a:finish()if d==200 then b=true;local e=io.open('autorun.lua','wb')e:write(c)e:close()tpt.message_box('VOXELMAN Downloaded successfully','Please restart TPT')end end;if not b then tpt.throw_error('Download failed')end
```
3) Type:
```lua
pcall(load(tpt.get_clipboard()))
```
3) Press "Enter"("Return") key
