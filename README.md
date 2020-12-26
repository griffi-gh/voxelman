# voxelman
Powder toy LUA script manager

## Installation
Download autorun.lua file or

1) Copy to clipboard:
```lua
if not N then N=true pcall(load(tpt.get_clipboard()))end                                                                         local a=http.get("https://raw.githubusercontent.com/griffi-gh/voxelman/main/autorun.lua")repeat socket.sleep(.1)until a:status()~='running'local b;if a:status()=='done'then local c,d=a:finish()if d==200 then b=true;local e=io.open('autorun.lua','wb')e:write(c)e:close()tpt.message_box('VOXELMAN Downloaded successfully','Please restart TPT')end end;if not b then tpt.throw_error('Download failed')end
```
2) Open TPT
3) Open console
4) Paste and run
