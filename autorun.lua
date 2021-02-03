-----start-----
assert(tpt and graphics and event,'VOXELMAN requires The Powder Toy Lua API')

local TEXTH = 7
local type = type
local jmod = tpt.version.jacob1s_mod~=nil

local manager = {
  versionID = 9,
  versionString = '0.8a',
  dir = 'scripts/',
  sdir = 'lua/',
  button={
    x = 613,
    y = 120,
    size = 15,
    show = true,
  },
  menu = {
    open = false,
    tx = false,
    ty = false,
    x = false,
    y = false, 
    w = 300,
    h = 313,
    tab = 'local',
    toph = 12,
    padding = 5,
  },
  loaded = {},
  toRun = {},
  online = {
    server = 'https://0.0.0.0/api/v1/' --no, server is not ready yet
  },
  TPTMPSupport = true,
  loadVerifiedHashes = true,
  updateCheck = true,
}

local regenTabUI = true

local fileRegex = '[^/\\]+$'
local extRegex = '.[^.]+$'

local exeName,userOS
if platform then
  userOS = platform.platform()
  exeName = platform.exeName
  if type(exeName)=='function' then
    exeName = exeName()
  end
end

local function restart()
  if userOS=='WIN32' then
    while true do tpt.throw_error('Please restart game manually') end
  elseif not(platform) then
    os.exit()
  else
    platform.restart()
  end
end

manager.verifiedHashes = {}

local updateCheckUrl = 'https://raw.githubusercontent.com/griffi-gh/voxelman/main/LATEST'
local updateDownloadUrl = 'https://raw.githubusercontent.com/griffi-gh/voxelman/main/autorun.lua'
local verifiedHashesUrl = 'https://pastebin.com/raw/ucag570u'

local verifiedHashesReqm,updateChkReq
if http then
  if manager.loadVerifiedHashes then
    verifiedHashesReq = http.get(verifiedHashesUrl)
  end
  if manager.updateCheck then
    updateChkReq = http.get(updateCheckUrl)
  end
end

local hash
do
  local CRC32={0x00000000,0x77073096,0xee0e612c,0x990951ba,0x076dc419,0x706af48f,0xe963a535,0x9e6495a3,0x0edb8832,0x79dcb8a4,0xe0d5e91e,0x97d2d988,0x09b64c2b,0x7eb17cbd,0xe7b82d07,0x90bf1d91,0x1db71064,0x6ab020f2,0xf3b97148,0x84be41de,0x1adad47d,0x6ddde4eb,0xf4d4b551,0x83d385c7,0x136c9856,0x646ba8c0,0xfd62f97a,0x8a65c9ec,0x14015c4f,0x63066cd9,0xfa0f3d63,0x8d080df5,0x3b6e20c8,0x4c69105e,0xd56041e4,0xa2677172,0x3c03e4d1,0x4b04d447,0xd20d85fd,0xa50ab56b,0x35b5a8fa,0x42b2986c,0xdbbbc9d6,0xacbcf940,0x32d86ce3,0x45df5c75,0xdcd60dcf,0xabd13d59,0x26d930ac,0x51de003a,0xc8d75180,0xbfd06116,0x21b4f4b5,0x56b3c423,0xcfba9599,0xb8bda50f,0x2802b89e,0x5f058808,0xc60cd9b2,0xb10be924,0x2f6f7c87,0x58684c11,0xc1611dab,0xb6662d3d,0x76dc4190,0x01db7106,0x98d220bc,0xefd5102a,0x71b18589,0x06b6b51f,0x9fbfe4a5,0xe8b8d433,0x7807c9a2,0x0f00f934,0x9609a88e,0xe10e9818,0x7f6a0dbb,0x086d3d2d,0x91646c97,0xe6635c01,0x6b6b51f4,0x1c6c6162,0x856530d8,0xf262004e,0x6c0695ed,0x1b01a57b,0x8208f4c1,0xf50fc457,0x65b0d9c6,0x12b7e950,0x8bbeb8ea,0xfcb9887c,0x62dd1ddf,0x15da2d49,0x8cd37cf3,0xfbd44c65,0x4db26158,0x3ab551ce,0xa3bc0074,0xd4bb30e2,0x4adfa541,0x3dd895d7,0xa4d1c46d,0xd3d6f4fb,0x4369e96a,0x346ed9fc,0xad678846,0xda60b8d0,0x44042d73,0x33031de5,0xaa0a4c5f,0xdd0d7cc9,0x5005713c,0x270241aa,0xbe0b1010,0xc90c2086,0x5768b525,0x206f85b3,0xb966d409,0xce61e49f,0x5edef90e,0x29d9c998,0xb0d09822,0xc7d7a8b4,0x59b33d17,0x2eb40d81,0xb7bd5c3b,0xc0ba6cad,0xedb88320,0x9abfb3b6,0x03b6e20c,0x74b1d29a,0xead54739,0x9dd277af,0x04db2615,0x73dc1683,0xe3630b12,0x94643b84,0x0d6d6a3e,0x7a6a5aa8,0xe40ecf0b,0x9309ff9d,0x0a00ae27,0x7d079eb1,0xf00f9344,0x8708a3d2,0x1e01f268,0x6906c2fe,0xf762575d,0x806567cb,0x196c3671,0x6e6b06e7,0xfed41b76,0x89d32be0,0x10da7a5a,0x67dd4acc,0xf9b9df6f,0x8ebeeff9,0x17b7be43,0x60b08ed5,0xd6d6a3e8,0xa1d1937e,0x38d8c2c4,0x4fdff252,0xd1bb67f1,0xa6bc5767,0x3fb506dd,0x48b2364b,0xd80d2bda,0xaf0a1b4c,0x36034af6,0x41047a60,0xdf60efc3,0xa867df55,0x316e8eef,0x4669be79,0xcb61b38c,0xbc66831a,0x256fd2a0,0x5268e236,0xcc0c7795,0xbb0b4703,0x220216b9,0x5505262f,0xc5ba3bbe,0xb2bd0b28,0x2bb45a92,0x5cb36a04,0xc2d7ffa7,0xb5d0cf31,0x2cd99e8b,0x5bdeae1d,0x9b64c2b0,0xec63f226,0x756aa39c,0x026d930a,0x9c0906a9,0xeb0e363f,0x72076785,0x05005713,0x95bf4a82,0xe2b87a14,0x7bb12bae,0x0cb61b38,0x92d28e9b,0xe5d5be0d,0x7cdcefb7,0x0bdbdf21,0x86d3d2d4,0xf1d4e242,0x68ddb3f8,0x1fda836e,0x81be16cd,0xf6b9265b,0x6fb077e1,0x18b74777,0x88085ae6,0xff0f6a70,0x66063bca,0x11010b5c,0x8f659eff,0xf862ae69,0x616bffd3,0x166ccf45,0xa00ae278,0xd70dd2ee,0x4e048354,0x3903b3c2,0xa7672661,0xd06016f7,0x4969474d,0x3e6e77db,0xaed16a4a,0xd9d65adc,0x40df0b66,0x37d83bf0,0xa9bcae53,0xdebb9ec5,0x47b2cf7f,0x30b5ffe9,0xbdbdf21c,0xcabac28a,0x53b39330,0x24b4a3a6,0xbad03605,0xcdd70693,0x54de5729,0x23d967bf,0xb3667a2e,0xc4614ab8,0x5d681b02,0x2a6f2b94,0xb40bbe37,0xc30c8ea1,0x5a05df1b,0x2d02ef8d}

  function hash(str)
    local xor,lshift,rshift,band = bit.bxor,bit.lshift,bit.rshift,bit.band
    str = tostring(str)
    local count = string.len(str)
    local crc = 2 ^ 32 - 1 
    local i = 1
    while count > 0 do
        local byte = string.byte(str, i)
        crc = xor(rshift(crc, 8), CRC32[xor(band(crc, 0xFF), byte) + 1])
        i = i + 1
        count = count - 1
    end
    crc = xor(crc, 0xFFFFFFFF)
    if crc < 0 then crc = crc + 2 ^ 32 end 
    return crc
  end
end
--
local function setchar(str,pos,r)
  return ("%s%s%s"):format(str:sub(1,pos-1),r,str:sub(pos+1))
end

local function wordSplit(t,cc)
  cc = cc or 25
  local n = 0
  for i=1,#t do
    local c = t:sub(i,i)
    if c==' ' then
      if n>=cc then
        t = setchar(t,i,'\n')
        n = 0
      end
    elseif c=='\n' then
      n = 0
    else
      n = n+1
    end
  end
  return t
end

local function textheight(str)
  local _,lc = str:gsub('\n','')
  return lc==0 and TEXTH or (TEXTH+lc*(TEXTH*1.7))+1 --bad ?
end

local function parts(i,s)
  return string.gmatch(i..s,'(.-)'..s)
end

local function varParse(d,sep)
  local t = {}
  local spec = {
    ['n'] = '\n',
    ['r'] = '\r',
    ['t'] = '\t',
    ['\\'] = '\\',
    ['"'] = '"',
  }
  d = d:gsub('\n',''):gsub('\r',''):gsub('\t','')
  for l in parts(d,sep or ';') do
    if not(l:sub(1,2)=='//') then
      local a = parts(l,':')()
      local b = l:sub(#a+2,#l)
      assert(not t[a],'err 1')
      local fv
      local typ
      do
        local tv
        local i = 1
        while true do
          local c = b:sub(i,i)
          if typ then
            if typ=='str' then
              if c=='"' then
                fv = tv
                break
              elseif c=="\\" then
                i = i+1
                local s = b:sub(i,i)
                tv = tv..(spec[s] or '\\'..s)
              else
                tv = tv..c
              end
            elseif typ=='tbl' then
              if c=="}" then
                fv = varParse(tv,',')
              else
                tv = tv..c
              end
            end
          elseif typ==nil then
            if c=='"' then
              typ = 'str'
              tv = ''
            elseif c=="{" then
              typ = 'tbl'
              tv = ''
            end
          end
          i = i+1
          if i>#b then break end
        end
        if typ==nil then 
          fv = tonumber(b) 
          if not fv then
            if b:find('true') then 
              fv = true 
            elseif b:find('false') then
              fv = false
            elseif b:find('none') or b:find('uknown') then
              fv = nil
            end
          end
        end
      end
      t[a] = fv
    end
  end
  return t
end

local function varEncode(t,sep,tab)
  sep = sep or ';'
  local f = ''
  local spec = {
    ['\n'] = '\\n',
    ['\r'] = '\\r',
    ['\t'] = '\\t',
    ['\\'] = '\\\\',
    ['"'] = '\\"',
  }
  for i,v in pairs(t) do
    local vt,vs = type(v),nil
    if vt=='string' then
      vs = tostring(v)
      for i,v in pairs(spec) do
        vs = vs:gsub(i,t)
      end
      vs = string.format('"%s"',vs)
    elseif vt=='number' then
      vs = tostring(v)
    elseif vt=='boolean' then
      vs = (v and 'true' or 'false')
    elseif vt=='table' then
      vs = string.format('{\n%s\n}',varEncode(v,',',(tab or 0)+1))
    else
      vs = 'uknown'
    end
    f = f..string.format('%s%s: %s%s\n',string.rep('\t',tab or 0),tostring(i),vs,sep)
  end
  f = f:sub(1,#f-2)
  return f
end

local function c64transfer()
  if fs.exists('scripts/autorunsettings.txt') then
    local c = tpt.confirm('Transfer your scripts from Cracker64\'s Manager?',[[
1) Your downloaded scripts will be converted (it is recommended to re-download them)
2) Your autorun settings will be lost
3) If you want to return to Cracker64's Manager, you will have to redownload the online scripts.]])
    if c then
      for i,v in ipairs(fs.list('scripts')) do
        if fs.isFile('scripts/'..v) and v:match(extRegex)=='.lua' then
          fs.move('scripts/'..v,'scripts/lua/'..v)
        end
      end
      if fs.exists('scripts/downloaded/scriptinfo') then
        local ar = io.open('scripts/downloaded/scriptinfo','rb'):read('*a')
        for p in parts(ar,'\n') do
          if #p>=2 then
            local oinf = varParse(p,',')
            if oinf.name~='autorun' or oinf.status=="HIDDEN" and oinf.path then
              local path = 'scripts/'..oinf.path:gsub('\\','/')
              local chk = io.open(path)
              if chk then
                chk:close()
                local ninf = {
                  description = oinf.description,
                  version = tonumber(oinf.version),
                  name = oinf.name..' (converted)',
                  creator = oinf.author,
                  id = 'converted-'..oinf.name..oinf.ID,
                  converted = true,
                  oid = oinf.ID,
                  run = 'main.lua'
                }
                local dir = 'scripts/'..ninf.id
                fs.makeDirectory(dir)
                fs.move(path,dir..'/main.lua')
                local f = io.open(dir..'/info.var','wb')
                assert(f,'Unable to open info.var file: f'..dir..'/info.var')
                f:write(varEncode(ninf))
                f:close()
              end
            end
          end
        end
      end
      fs.removeFile('scripts/autorunsettings.txt')
      fs.removeFile('scripts/downloaded/scriptinfo')
      fs.removeDirectory('scripts/downloaded')
    end
  end
end

local function binImgSize(d)
  return d:byte(1),d:byte(2)
end

local function binImgDraw(d,x,y,s)
  local w,h = binImgSize(d)
  for py=1,h do
    for px=1,w do
      local i = 3+(((px-1)+(py-1)*h)*4)
      local r,g,b,a = d:byte(i,i+3)
      local drx,dry = (px*s)+x,(py*s)+y
      if a>0 then
        graphics.fillRect(drx,dry,s,s,r,g,b,a)
      end
    end
  end
end

local scriptMt = {
  run = function(self,force,noErrNotify)
    if not(self.running) or force then
      self.running = true
      local ok,v,fn
      local f = self.path..(self.single and '' or self.info.run)
      fn,v = loadfile(f)
      if fn then
        ok,v = pcall(fn)
      end
      if not(ok) or not(fn) then
        manager.pushNotification{
          text=string.format("Error: %s",v),
          backgroundColor = {240,40,40,200},
          borderColor = {100,0,0},
          life = 400,
          fadeStart = 15,
          fade = true,
          buttons = {
            {
              text = 'Copy',
              action = function()
                if platform then
                  platform.clipboardCopy(v)
                  manager.pushNotification{
                    text = 'Copied',
                    fade = true,
                    fadeStart = 30,
                    life = 60,
                  }
                else
                  tpt.input('Copy text','',v)
                end
              end
            },
            {
              text = 'Dismiss',
              action = function(v)
                v.life = 10
                v.fadeStart = 10
              end
            }
          }
        }
      end
    end
  end
}

local function epth(p) --add "/"
  return p..(not(p:sub(#p,#p)=='/') and '/' or '')
end
local function xpth(p) --remove "/"
  return p:sub(#p,#p)=='/' and p:sub(1,#p-1) or p
end

local function loadScriptTmp(p)
  if fs.isDirectory(p) then
    p = epth(p) --add "/" if missing
    local fh = assert(io.open(p..'info.var'),'Missing info.var')
    local f = fh:read('*a')
    local ok,info = pcall(varParse,f)
    fh:close()
    assert(ok and info,'Invalid info.var')
    assert(info.run,'Missing variable in info.var')
    local t = {}
    info.run = info.run:gsub('/',''):gsub('\\','')
    if info.icon then
      info.icon = info.icon:gsub('/',''):gsub('\\','')
      local file = io.open(p..info.icon,'rb')
      t.icon = file:read('*a')
      file:close()
    end
    t.info = info
    t.path = p
    local runf = io.open(p..info.run,'rb')
    t.hash = hash(runf:read('*a')..string.format("!%s!%s!",info.creator,info.id))
    setmetatable(t,{__index=scriptMt})
    runf:close()
    return t
  else
    p = xpth(p)
    local runf = io.open(p,'rb')
    local rdat = runf:read('*a')
    runf:close()
    return setmetatable(
      {
        info = {
          name = string.match(p,fileRegex),
          run = string.match(p,fileRegex),
          id = 'luafile-'..p
        },
        single = true,
        hash = hash(rdat),
        path = p,
      },
      {
        __index=scriptMt
      }
    )
  end
end

local function loadScript(...)
  local s = loadScriptTmp(...)
  if s then
    table.insert(manager.loaded,s)
    return s
  end
end

local function loadDirectory(f,allowSingle,allowDir)
  if allowDir==nil then allowDir=true end
  if allowSingle==nil then allowSingle=true end
  f = epth(f or dir)
  local l = fs.list(f)
  for i,v in ipairs(l) do
    local lp = f..v
    local isValid = (
      (allowSingle and fs.isFile(lp) and (v:match(extRegex)=='.lua')) or 
      (allowDir and fs.isDirectory(lp..'/') and fs.exists(lp..'/info.var'))
    )
    --manager.pushNotification{text=lp..' '..(isValid and 'yes' or 'no')}
    if isValid then 
      loadScript(lp)
    end
  end
end

local function runAll()
  for i,v in ipairs(manager.loaded) do
    if manager.toRun[v.info.id] and not(v.running) then
      v:run()
    end
  end
end

local mouseX,mouseY=0,0
local mouseDown = false
local iconHover = false

local menuButtons = {}

local function UIbutton(x,y,w,h,text,onClick,class)
  return {type='button',x=x,y=y,w=w,h=h,text=text or 'Button',class=class or 'none',onClick=onClick}
end

local function UIcheckbox(x,y,s,checked,onClick,class)
  return {type='checkbox',x=x,y=y,w=s or 12,h=s or 12,on=checked,class=class or 'none',onClick=onClick}
end

local function UIhitbox(x,y,w,h,upd,onClick,class)
  return {type='nil',x=x,y=y,w=w,h=h,class=class or 'none',tick = upd,onClick=onClick}
end

local function UIfind(e)
  for i,v in ipairs(menuButtons) do
    if v==e then
      return i
    end
  end
  return false
end

local function UIadd(e)
  if not(UIfind(e)) then
    table.insert(menuButtons,e)
    return true
  else
    return false
  end
end

local function UIrem(e)
  local i = UIfind(e)
  if i then
    table.remove(menuButtons,i)
    return true
  end
  return false
end

local function UIgetClass(className)
  local l = {
    type = 'UIclassType',
    class = className,
    items = {}
  }
  for i,v in ipairs(menuButtons) do
    if v.class==className then
      table.insert(l.items,v)
    end
  end
  return l
end

local function UImoveClass(class,bx,by)
  if class.type=='UIclassType' then
    bx = bx or 0
    by = by or 0
    if bx==0 and by==0 then return end
    for i,v in ipairs(class.items) do
      v.x = v.x+bx
      v.y = v.y+by
    end
  end
end

local function UIupdateClass(class)
  if class.type=='UIclassType' then
    class.items = UIgetClass(class.class).items
    return class
  end
end

local function UIsetClassProp(class,prop,val)
  if class.type=='UIclassType' then
    for i,v in ipairs(class.items) do
      v.prop = val
    end
  end
end

local function UIdeleteClass(class)
  if class.type=='UIclassType' then
    for i,v in ipairs(class.items) do
      UIrem(v)
    end
  end
end

manager.notifications = {}

local function clickNotifications(b,u)
  if b==1 then
    for i=#manager.notifications,1,-1 do
      local v = manager.notifications[i]
      if v.buttons then
        for i2=#v.buttons,1,-1 do
          local v2 = v.buttons[i2]
          if u==true then 
            v2.down = false 
          end
          if v2.hit then
            if u then
              if v2.action then
                v2.action(v,v2)
              end
            else
              v2.down = true
            end
            return true
          end
        end
      end
    end
  end
end

local function copyt4(a)
  if a then
    return {a[1],a[2],a[3],a[4]}
  else
    return nil
  end
end

local function tickNotifications()
  local x,y = 10,10
  local mw,mh = 10,5
  local bmw,bms,bh,bhm = 5,10,17,4 --button margin w; button h spacing; button height;button v padding
  local notspc = 5
  for i=#manager.notifications,1,-1 do
    local v = manager.notifications[i]
    if fade and not(v.fadeStart) then 
      v.fadeStart=v.life
    end
    local fade = math.min(1,(v.fade and v.life/v.fadeStart or 1))
    local hasbuttons = (v.buttons and #v.buttons>0)
    
    local bgc = copyt4(v.backgroundColor) or {20,20,180,200}--{20,20,20,200}
    local brc = copyt4(v.borderColor) or {20,20,185,255}--{255,255,255,255}
    local txc = copyt4(v.textColor) or {255,255,255,255}
    local bbgc,bbrc,bbhc,bbcc 
    if hasbuttons then
      bbgc = copyt4(v.buttonBackgroundColor) or {bgc[1],bgc[2],bgc[3],128}
      bbrc = copyt4(v.buttonBorderColor) or brc
      bbhc = copyt4(v.buttonHoverColor) or {
        math.min(255,bbgc[1]*2),
        math.min(255,bbgc[2]*2),
        math.min(255,bbgc[3]*2),
        255
      }
      bbcc = copyt4(v.buttonHoldColor) or {
        math.min(255,bbgc[1]*4),
        math.min(255,bbgc[2]*4),
        math.min(255,bbgc[3]*4),
        255
      }
      bbgc[4] = (bbgc[4] or 255)*fade
      bbrc[4] = (bbrc[4] or 255)*fade
      bbhc[4] = (bbhc[4] or 255)*fade
      bbcc[4] = (bbcc[4] or 255)*fade
    end
    bgc[4] = (bgc[4] or 255)*fade
    brc[4] = (brc[4] or 255)*fade
    txc[4] = (txc[4] or 255)*fade
      
    local buth = (hasbuttons and bh+bhm*2 or 0)
    local butwt = 0
    if hasbuttons then
      for i2,v2 in ipairs(v.buttons) do
        butwt = butwt+tpt.textwidth(v2.text)+bmw*2
      end
      butwt = butwt+(#v.buttons*(bms/2))+mw
    end
    local w = math.max(butwt,tpt.textwidth(v.text)+mw*2)
    local h = TEXTH+mh*2+buth
    graphics.fillRect(x,y,w,h,unpack(bgc))
    graphics.drawRect(x,y,w,h,unpack(brc))
    graphics.drawText(x+mw,y+mh,v.text,unpack(txc))
    
    if hasbuttons then  
      local bx = bms+x
      local by = y+mh+TEXTH+bhm*2
      for i2,v2 in ipairs(v.buttons) do
        local t2 = v2.text
        local bw = tpt.textwidth(t2)+bmw*2 -- bh is static
        v2.hit = (
          not(
            manager.menu.open and 
            (
              mouseX>=manager.menu.x and 
              mouseY>=manager.menu.y and 
              mouseX<=manager.menu.x+manager.menu.w and 
              mouseY<=manager.menu.y+manager.menu.h
            )
          ) and
          (mouseX>=bx and mouseY>=by and mouseX<bx+bw and mouseY<by+bh)
        )
        local bc1 = v2.hit and (v2.down and bbcc or bbhc) or bbgc
        graphics.fillRect(bx,by,bw,bh,unpack(bc1))
        graphics.drawRect(bx,by,bw,bh,unpack(bbrc))
        graphics.drawText(bx+bmw,by+(bh-TEXTH)/2,t2,unpack(txc))
        bx = bx+bw+bhm
      end
    end
    
    if v.life then
      v.life = v.life-1
      if v.life==0 then
        table.remove(manager.notifications,i)
        return
      end
    end
    y = y+h+notspc
  end
end

function manager.pushNotification(c) --TODO!!!!
  if type(c.text)=='string' then
    table.insert(manager.notifications,c)
  end
end

local function saveRun()
  local p = epth(manager.dir)..'run.var'
  local f = io.open(p,'wb')
  f:write(varEncode(manager.toRun))
  f:close()
end

local mup = 0

local function buttonCollision(x,y)
  --print(x,y)
  for i,v in ipairs(menuButtons) do
    v.hit = (
              v.x>=0 and v.y>=0 and v.x<=manager.menu.w and v.y<=manager.menu.h and
              x>=manager.menu.x+v.x and y>=manager.menu.y+v.y and 
              x<=manager.menu.x+v.x+v.w and y<=manager.menu.y+v.y+v.h
            )
    if not(v.hit) then 
      v.down = false 
    end
  end
end

--[[local function postTick()
  event.unregister(event.tick,postTick)
  event.register(event.tick,postTick)
end]]
local function getTab(tab)
  for i,v in ipairs(manager.menu.tabs) do
    if v.id==tab then
      return v
    end
  end
end

local function assurl(url,query)
  local vs = ''
  if query then
    vs = vs..'?'
    for i,v in ipairs(query) do
      vs = vs..i..'='..v..'&'
    end
    vs = vs:sub(1,#vs-1)
  end
  return url..vs
end

local dtasks = {}
local function checkAsyncTasks()
  for i=#dtasks,1,-1 do
    local v = dtasks[i]
    local s = v.req:status()
    local d = false
    if s=='done' then
      v.cb(req:finish())
      d = true
    elseif s~='running' then
      v.cb(false,s)
      d = true
    elseif os.time()>math.ceil(v.start+v.timeout) then
      v.cb(false,timeout)
      d = true
    end
    if d then
      table.remove(dtasks,i)
    end
  end
end
local function downloadAsync(url,query,timeout,callback)
  local furl = assurl(url,query)
  local req = http.get(furl)
  table.insert(dtasks,{req=req,c=callback,timeout=timeout or 10,start=os.time()})
end

local function downloadSync(url,query,timeout)
  timeout = timeout or 10
  local furl = assurl(url,query)
  local req = http.get(furl)
  --
  local time,sleep = 0,.05
  while req:status()=='running' do
    socket.sleep(sleep)
    time = time+sleep
    if time>timeout then
      return false,'timeout'
    end
  end
  --
  local s = req:status()
  if s=='done' then
    return req:finish()
  end
  return false,s
end

function manager.online.conntest(s)
  s = s or manager.online.server
  local res,code = downloadSync(s..'conntest')
  return (res=='ok' and code==200),code
end

do
  local function ass(id,s)
    s = s or manager.online.server
    return s..'scriptInfo',{id=id}
  end
  local function proc(res,code)
    if res and code==200 then
      local rp = varParse(res)
      if rp.type=='scriptInfo' then
        return rp,res
      end
    end
    return false
  end
  function manager.online.scriptInfo(id,s)
    return proc(downloadSync(ass(id,s)))
  end
  function manager.online.scriptInfoAsync(id,s,cb)
    local u,q = ass(st,en,s)
    downloadAsync(u,q,nil,function(...) cb(proc(...)) end)
  end
end

do
  local function ass(st,en,s)
    s = s or manager.online.server
    return s..'scriptList',{['start'] = st,['end'] = en}
  end
  local function proc(res,code)
    if res and code==200 then
      local t = {}
      for p in parts(res,';') do
        table.insert(t,p)
      end
      return t
    end
    return false,c
  end
  function manager.online.scriptList(st,en,s)
    return proc(downloadSync(ass(st,en,s)))
  end
  function manager.online.scriptListAsync(st,en,s,cb)
    local u,q = ass(st,en,s)
    downloadAsync(u,q,nil,function(...) cb(proc(...)) end)
  end
end

function manager.online.processScriptList(l,s)
  if l and #l>0 then
    local nl = {}
    for i,v in ipairs(l) do
      nl[i] = manager.online.scriptInfo(v,s)
    end
    return nl
  end
  return false
end 

function manager.online.downloadScriptFile(id,file,version,s)
  version = version or 'latest'
  local res,code = downloadSync(s..'download',{id=id,file=file,version=version})
  if res and code==200 then
    return res
  end
end

local function errorScreen(cnx,cny,cnw,cnh,errtxt)
  graphics.fillRect(cnx,cny,cnw,cnh,0,0,0,100) --darken bg
  local iconsize = 32
  local centerx = cnx+cnw/2
  local centery = cny+cnh/2
  --math.floor(iconsize*(math.abs(math.sin(os.clock()*2))/2+.5)) fancy
  --[[for i=1,iconsize do
    local a = math.floor((1-i/iconsize)*60)
    graphics.fillCircle(
      math.floor(centerx),
      math.floor(centery-iconsize/2)+1,
      i,i,255,100,100,a
    )
  end]]
  for i=1,iconsize do
    local a,b = math.floor(centerx-i/2),math.floor(centerx+i/2)
    local h = math.floor(centery-iconsize+i)
    graphics.drawLine(a,h,b,h,255,20,20,220)
  end
  local linew = 3
  for i=1,linew do
    local xh = math.floor(centerx-linew/2+i)
    graphics.drawLine(
      xh,math.floor(centery-7-linew),
      xh,math.floor(centery-iconsize+12)
    )
    graphics.drawLine(
      xh,math.floor(centery-5),
      xh,math.floor(centery-4-linew)
    )
  end
  graphics.drawLine(
    math.floor(centerx-iconsize/2),
    math.floor(centery),
    math.floor(centerx),
    math.floor(centery-iconsize)
  )
  graphics.drawLine(
    math.floor(centerx),
    math.floor(centery-iconsize),
    math.floor(centerx+iconsize/2),
    math.floor(centery)
  )
  graphics.drawLine(
    math.floor(centerx+iconsize/2),
    math.floor(centery),
    math.floor(centerx-iconsize/2),
    math.floor(centery)
  )
  graphics.drawText(
    math.floor(centerx-tpt.textwidth(errtxt)/2),
    math.floor(centery+TEXTH/2+2),
    errtxt
  )
end

local function tick()
  if manager.updateCheck and updateChkReq then
    local stat = updateChkReq:status()
    if stat=='done' then
      local d,c = updateChkReq:finish()
      if c==200 then
        local v = tonumber(d)
        if v>manager.versionID then
          manager.pushNotification{
            text = 'Voxelman update available!',
            backgroundColor = {250,170,0,200},
            borderColor = {250,150,0,200},
            buttonHoverColor = {255,180,10,250},
            buttonHoldColor = {255,240,80,255},
            buttons = {
              {
                text = 'Open GitHub page',
                action = function()
                  platform.openLink("https://github.com/griffi-gh/voxelman/")
                end
              },
              {
                text = 'Download update',
                action = function()
                  local ok
                  local req = http.get(updateDownloadUrl)
                  repeat socket.sleep(.1) until(req:status()~='running')
                  if req:status()=='done' then
                    local d,c = req:finish()
                    if c==200 then
                      fs.copy('autorun.lua','autorun.lua.bak')
                      local a = io.open('autorun.lua','wb')
                      a:write(d)
                      a:close()
                      ok = true
                    end
                  end
                  if ok==true then
                    manager.pushNotification{
                      text = 'Update installed successfully; Please restart The Powder Toy'
                    }
                  else
                    manager.pushNotification{
                      text = 'Update failed'
                    }
                  end
                end
              },
              {
                text = 'Dismiss',
                action = function(self)
                  self.fade = true
                  self.fadeStart = 15
                  self.life = 15
                end
              }
            }
          }
        end
      end
      updateChkReq = nil
    elseif stat=='dead' then
      updateChkReq = nil
    end
  end
  if manager.loadVerifiedHashes and verifiedHashesReq then
    local stat = verifiedHashesReq:status()
    if stat=='done' then
      local d = verifiedHashesReq:finish()
      if type(d)=='string' and #d>1 then
        local l = varParse(d)
        for i,v in pairs(l) do
          manager.verifiedHashes[tonumber(v)] = true
        end
        manager.pushNotification{
          text = 'Verification data received',
          life = 60,
          fade = true,
          fadeStart = 30
        }
      else
        manager.pushNotification{
          text = 'Verification error 0 (Check Internet connection)',
          backgroundColor = {240,40,40,200},
          borderColor = {100,0,0},
          life = 200,
          fade = true,
          fadeStart = 30
        }
      end
      verifiedHashesReq = nil
    elseif stat=='dead' then
      verifiedHashesReq = nil
      manager.pushNotification{
        text = 'Verification error 1 (Check Internet connection)',
        backgroundColor = {240,40,40,200},
        borderColor = {100,0,0},
        life = 200,
        fade = true,
        fadeStart = 30
      }
    end
  end
  
  if manager.TPTMPSupport then
    for i=1,2 do
      if TPTMP and TPTMP.chatHidden then
        if mup<16 then 
          mup = mup+1
          manager.button.y = manager.button.y-1
        end
      elseif mup>0 then
        mup = mup-1
        manager.button.y = manager.button.y+1
      end
    end
  end
  
  if manager.button.show then
    local bx,by = manager.button.x,manager.button.y
    local bs = manager.button.size
    local c1,c2,c3
    --if hovered
    iconHover = mouseX>bx and mouseY>by and mouseX<bx+bs and mouseY<by+bs
    if iconDown or manager.menu.open then
      c1,c2,c3 = 255,255,20
    elseif iconHover and not(jmod) then
      c1,c2,c3 = 20,255,235
    else
      c1,c2,c3 = 0,(jmod and 255 or 200),235
    end
    graphics.fillRect(bx,by,bs,bs,c1,c1,c1) --Button background
    graphics.drawRect(bx,by,bs,bs,c2,c2,c2) --Button border
    do --Lua Icon
      local x1,y1,r1 = math.floor(bx+bs/2.5),
                       math.floor(by+bs-(bs/2.5)-1),
                       math.floor(bs/4)
      graphics.fillCircle(
        x1,y1,r1,r1,
        c3,c3,c3
      )
      graphics.fillCircle(
        x1+r1/4,y1-r1/4,r1/4,r1/4,
        c1,c1,c1
      )
      graphics.fillCircle(
        x1+r1+1,y1-r1-1,r1/4,r1/4,
        c3,c3,c3
      )
    end
  end
  
  if manager.menu.open then
    graphics.fillRect(0,0,graphics.WIDTH,graphics.HEIGHT,0,0,0,85) --Fade bg
  end
  
  if #manager.notifications>0 then
    tickNotifications()
  end
  
  if manager.menu.open then
    local menu = manager.menu
    local mx,my,mw,mh = menu.x,menu.y,menu.w,menu.h
    local toph = menu.toph
    
    local tabpad = 4
    local tabh,stabh = 14,16
    local tabBarH = stabh+tabpad-1
    
    graphics.fillRect(mx,my,mw,mh,0,0,0) --Bg
    graphics.drawRect(mx,my,mw,toph,255,255,255) --title bar
    graphics.drawRect(mx,my,mw,mh,255,255,255) --Border
    local nmx,nmy,nms = mx+4,math.floor(my+TEXTH/2),"VOXELMAN"
    graphics.drawText(nmx,nmy,nms) --Title text
    graphics.drawText(nmx+tpt.textwidth(nms)+5,nmy,manager.versionString,128,128,128,250) --version
    graphics.drawLine(mx,my+toph+tabBarH,mx+mw-1,my+toph+tabBarH) -- tab sep
    
    local tab = manager.menu.tab
    local tabt = getTab(tab)
    
    do
      local tabsp = 6
      local x = mx+tabpad
      local y = my+toph+tabBarH
      if regenTabUI then
        UIdeleteClass(UIgetClass'tab')
      end
      for i,v in ipairs(manager.menu.tabs) do
        local s = tab==v.id
        local w = tpt.textwidth(v.text)+tabsp*2
        local h = (s and stabh or tabh)
        local ay = y-h+1
        local hov = mouseX>=x and mouseY>=ay and mouseX<x+w and mouseY<ay+h
        local c = s and 64 or (hov and 30 or 0)
        graphics.fillRect(x,ay,w,h,c,c,c)
        graphics.drawRect(x,ay,w,h)
        graphics.drawText(x+tabsp,math.floor(ay+(h-TEXTH)/2)-1,v.text)
        if regenTabUI then
          UIadd(
            UIhitbox(
              x-mx,ay-my,w,h,nil,
              function() 
                if tabt.onSwitchFrom then tabt:onSwitchFrom() end
                if v.onSwitchTo then v:onSwitchTo() end
                manager.menu.tab = v.id 
                regenTabUI = true
              end,
              'tab'
            )
          )
        end
        x = x+w-1
      end
      regenTabUI = false
    end
    
    local cnx,cny = mx+menu.padding, my+menu.padding+toph+tabBarH
    local cnw,cnh = mw-menu.padding-(cnx-mx),mh-menu.padding-(cny-my)
    
    do
      local cx,cy = math.floor(mx+mw/2),math.floor(cny+cnh/2)
      local r1,r2 = 30,10
      local x1,y1 = cx,cy
      local x2 = math.floor(cx+math.cos(os.clock())*(r1+r2*1.5))
      local y2 = math.floor(cy+math.sin(os.clock())*(r1+r2*1.5))
      local c = 20
      graphics.fillCircle(x1,y1,r1,r1,c,c,c)
      graphics.fillCircle(x1+r1*.4,y1-r1*.4,r1/3,r1/3,0,0,0)
      graphics.drawCircle(x1,y1,r1+(r2*1.5),r1+(r2*1.5),c,c,c)
      graphics.fillCircle(x2,y2,r2,r2,c,c,c)
    end
    
    if tab=='local' then
      tabt.var.pageCount = math.max(1,math.ceil((#manager.loaded)/tabt.var.onPage))
      if tabt.var.regenCardsUI then
        UIdeleteClass(UIgetClass'local_cards')
      end
      if tabt.var.regenNavUI then
        UIdeleteClass(UIgetClass'local_navigation')
        local l = UIbutton(
            5,mh-19,45,15,'<< Prev',
            function() 
              tabt.var.page = tabt.var.page-1
              tabt.var.regenCardsUI = true 
              tabt.var.regenNavUI = true
            end,
            'local_navigation'
          )
        local r = UIbutton(
            mw-50,mh-19,45,15,'Next >>',
            function() 
              tabt.var.page = tabt.var.page+1 
              tabt.var.regenCardsUI = true 
              tabt.var.regenNavUI = true
            end,
            'local_navigation'
          )
        if tabt.var.page>=tabt.var.pageCount then 
          r.disabled = true
        end
        if tabt.var.page<=1 then
          l.disabled = true
        end
        UIadd(l)
        UIadd(r)
      end
      
      local cardh = 32
      local page,onPage = tabt.var.page,tabt.var.onPage
      local pagestr = string.format("Page: %s/%s",page,tabt.var.pageCount)
      --graphics.drawText(mx+mw-toph-tpt.textwidth(pagestr)-4,my+TEXTH/2,pagestr,150,150,150)
      graphics.drawText(mx+(mw-tpt.textwidth(pagestr))/2,my+mh-14,pagestr,255,255,255)
        
      local ofs = (page-1)*onPage
      for i=1,math.min(onPage,#manager.loaded) do
        local ai = i+ofs
        local v = manager.loaded[ai]
        local av = manager.loaded[i]
        if v==nil then break end
        local cx = cnx
        local cy = cny+(menu.padding+cardh)*(i-1)
        local cw,ch = cnw, cardh
        
        if mouseX>=cx and mouseY>=cy and mouseX<cx+cw and mouseY<cy+ch then
          graphics.fillRect(cx,cy,cw,ch,255,255,255,20)
        end
        graphics.drawRect(cx,cy,cw,ch,255,255,255)
        
        local trx,try = 3,0
        if v.icon then
          local iconScale = 2
          local iw,ih = binImgSize(v.icon)
          iw = (iw+1)*iconScale
          ih = (ih+1)*iconScale
          binImgDraw(v.icon,trx+cx,math.floor(cy+ch/2-ih/2),iconScale)
          trx = trx+iw+5
        end
        try = math.floor((ch/2)-((TEXTH*2+3)/2))
        
        local ta = v.info.name or v.path
        local tb = 'by '..(v.info.creator or 'Uknown creator')
        local tc = '(running)'
        
        graphics.drawText(cx+trx,cy+try,ta)
        graphics.drawText(cx+trx,cy+try+TEXTH+3,tb,20,20,255)
        if v.running then
          graphics.drawText(
            math.floor(cx+trx+tpt.textwidth(ta)+5),
            math.floor(cy+try),
            tc,20,200,20
          )
        end
        
        if mouseX>cx+trx and mouseY>cy+try and mouseX<cx+trx+tpt.textwidth(ta) and mouseY<cy+try+TEXTH*1.1 then
          local desc = v.info.description or 'No description'
          desc = wordSplit(desc,30)
          if v.info.version or v.info.versionString then
            desc = string.format(
              'Version: %s(%s)\n%s',
              v.info.versionString or v.info.version or '?',
              v.info.version or '?',
              desc
            )
          end
          --local _,lc = desc:gsub('\n','')
          local texth = textheight(desc)--TEXTH+(lc+1)*(TEXTH*1.9)
          local textw = 0
          for p in parts(desc,'\n') do
            textw = math.max(textw,tpt.textwidth(p))
          end
          local boxw,boxh = textw+8,texth+8
          local boxx,boxy = mouseX-boxw/2,mouseY-boxh-TEXTH
          graphics.fillRect(boxx,boxy,boxw,boxh,0,0,0)
          graphics.drawRect(boxx,boxy,boxw,boxh,255,255,255)
          graphics.drawText(boxx+4,boxy+4,desc)
        end
        
        --Verified icon
        local isVerified = manager.verifiedHashes[v.hash]
        if isVerified then
          local cx,cy = math.floor(cx+trx+tpt.textwidth(tb)+TEXTH),math.floor(cy+try+(TEXTH*1.5)+3)
          local ro = math.floor(TEXTH/1.5)
          graphics.fillCircle(cx,cy,ro,ro,20,30,230)
          graphics.fillCircle(cx,cy,math.floor(TEXTH/2.5),math.floor(TEXTH/2.5),20,330,30)
          if mouseX>cx-ro and mouseY>cy-ro and mouseX<cx+ro and mouseY<cy+ro then
            local vt = 'Verified (hash: 0x'..bit.tohex(v.hash)..')'
            local boxw,boxh = tpt.textwidth(vt)+6,TEXTH+8
            local boxx,boxy = mouseX,mouseY-boxh
            graphics.fillRect(boxx,boxy,boxw,boxh,0,0,0)
            graphics.drawRect(boxx,boxy,boxw,boxh,255,255,255)
            graphics.drawText(boxx+3,boxy+3,vt,200,200,255)
          end
        end
        
        if tabt.var.regenCardsUI then
          UIadd(UIcheckbox((cw+cx)-mx-12*2,cy-my+(ch-12)/2,12,manager.toRun[v.info.id],
              function(self)
                tabt.var.regenCardsUI = true
                if self.on then
                  local notifOn = false
                  for i,v in ipairs(manager.notifications) do
                    if v.idnt=='restartUnload' then
                      notifOn = true
                      break
                    end
                  end
                  if not notifOn then
                    local notif = {
                      text='Restart The Powder Toy to unload script(s).',
                      backgroundColor = {240,40,40,200},
                      borderColor = {100,0,0},
                      buttons={},
                      idnt = 'restartUnload',
                      life = nil,
                    }
                    notif.buttons[1] = {
                      text='Dismiss',
                      action = function(v,v2)
                        v.life = 15
                        v.fadeStart = 15
                        v.fade = true
                        v2.action=function() --[[v2.text = 'ok boomer']] end --no
                      end
                    }
                    if userOS~='WIN32' then --disable restart on windows
                      notif.buttons[2] = {
                        text='Restart game',
                        action = restart
                      }
                    end
                    
                    manager.pushNotification(notif)
                  end
                  manager.toRun[v.info.id] = false
                else
                  manager.toRun[v.info.id] = true
                  v:run()
                end
                saveRun()
              end,'local_cards'
            )
          )
          --UIadd(UItext(
        end
      end
      if tabt.var.regenCardsUI or tabt.var.regenNavUI then
        tabt.var.regenCardsUI = false
        tabt.var.regenNavUI = false
        buttonCollision(mouseX,mouseY)
      end
    elseif tab=='online' then
      if tabt.var.status then
        errorScreen(cnx,cny,cnw,cnh,'Script count:'..#tabt.var.onlineList)
      else
        errorScreen(cnx,cny,cnw,cnh,'Unable to communicate with the server')
      end
    end
    
    for i,v in ipairs(menuButtons) do
      local bx,by,bw,bh = mx+v.x,my+v.y,v.w,v.h
      if v.type=='button' then
        local bc1 = (v.hit and (v.down and 255 or 20) or 0) --button bg
        local bc2 = (v.hit and 255 or 200) --button border
        local bc3 = (v.disabled and 150 or (v.down and 0 or 255)) --text color
        graphics.fillRect(bx,by,bw,bh,bc1,bc1,bc1)
        graphics.drawRect(bx,by,bw,bh,bc2,bc2,bc2)
        graphics.drawText(
          math.floor(bx+(bw-tpt.textwidth(v.text))/2),
          math.floor(by+(bh-TEXTH)/2),
          v.text,bc3,bc3,bc3
        )
      elseif v.type=='checkbox' then
        local bc1 = (v.hit and 255 or 200) --button border
        local bc2 = (v.on and 255 or (v.hit and 169 or 0)) --button center
        local bb = 3 --button margin
        graphics.fillRect(bx,by,bh,bh,0,0,0)
        graphics.fillRect(bx+bb,by+bb,bh-bb*2,bh-bb*2,bc2,bc2,bc2)
        graphics.drawRect(bx,by,bh,bh,bc1,bc1,bc1)
      elseif v.type=='text' then
        graphics.drawText(
          math.floor(bx+(bw-tpt.textwidth(v.text))/2),
          math.floor(by+(bh-TEXTH)/2),
          v.text
        )
      elseif v.type=='nil' or v.type=='hitbox' then
        if v.tick then
          v:tick()
        end
      end
    end
  end
  checkAsyncTasks()
end

manager.menu.tabs = {
  {
    text = 'Local scripts',
    id = 'local',
    onSwitchTo = function(self) 
      self.var.regenCardsUI = true
      self.var.regenNavUI = true
    end,
    onSwitchFrom = function(self)
      UIdeleteClass(UIgetClass'local_cards')
      UIdeleteClass(UIgetClass'local_navigation')
    end,
    var = {
      regenCardsUI = false,
      regenNavUI = false,
      onPage = 7,
      page = 1,
    }
  },
  {
    text = 'Online scripts',
    id = 'online',
    onSwitchTo = function(self) 
      self.var.refresh(self)
    end,
    var = {
      page = 1,
      onPage = 9,
      refresh = function(self)
        local conn,err = manager.online.conntest()
        if conn then
          local start = 1+(self.var.page-1)*self.var.onPage
          self.var.onlineList = manager.online.processScriptList(
            manager.online.scriptList(start,start+self.var.onPage)
          )
          self.var.status = (self.var.onlineList and true or false)
        end
        if not(conn) or not(self.var.status) then
          self.var.status = false
          manager.pushNotification{
            text = string.format('Error %s. Check internet connection.',err or '???'),
            life = 240,
            fade = true,
            fadeStart = 15,
            backgroundColor = {240,40,40,200},
            borderColor = {100,0,0},
          }
        end
      end
    }
  }
}

local menuDrag
local function mousemove(x,y,dx,dy)
  mouseX = x
  mouseY = y
  local onScr = x>0 and y>0 and x<graphics.WIDTH and y<graphics.HEIGHT
  if manager.menu.open then 
    local toph = (x>manager.menu.x and 
    y>manager.menu.y and 
    x<manager.menu.x+manager.menu.w-manager.menu.toph and
    y<manager.menu.y+manager.menu.toph) 
    if (toph or menuDrag) and onScr and mouseDown then
      menuDrag = true
      manager.menu.x = math.min(
        math.max(0,math.floor(manager.menu.x+dx)),
        graphics.WIDTH-manager.menu.w
      )
      manager.menu.y = math.min(
        math.max(0,math.floor(manager.menu.y+dy)),
        graphics.HEIGHT-manager.menu.h
      )
    end
    buttonCollision(x,y)
    return false 
  end
end

local function mousedown(x,y,b)
  if b==1 then
    if iconHover then 
      iconDown = true 
    end
    mouseDown = true
    if manager.menu.open then
      buttonCollision(x,y)
      for i,v in ipairs(menuButtons) do
        if v.hit then
          v.down = true
        end
      end
    end
  end
  if clickNotifications(b,false) or manager.menu.open then return false end
end

local function mouseup(x,y,b)
  if b==1 then  
    mouseDown = false
    iconDown = false
    menuDrag = false
    if iconHover then
      if not(TPTMP) or TPTMP.chatHidden then
        if manager.menu.open then
          manager.menu.open = false
        else
          if manager.menu.x==false or manager.menu.y==false then
            local mw,mh = manager.menu.w,manager.menu.h
            local mx,my = math.floor((graphics.WIDTH-mw)/2),math.floor((graphics.HEIGHT-mh)/2)
            manager.menu.x,manager.menu.y = mx,my
          end
          manager.menu.open = true
        end
      else
        manager.pushNotification{
          text = 'minimize TPTMP before opening the manager',
          life = 60,
          fade = true,
          fadeStart = 10
        }
      end
    end
    if manager.menu.open then
      buttonCollision(x,y)
      for i,v in ipairs(menuButtons) do
        if not(v.disabled) and v.hit and v.down then
          if v.onClick then
            v:onClick(x,y)
          end
          if v.type=='checkbox' then
            v.on = not(v.on)
          end
        end
        v.down = false
      end
    end
  end
  if clickNotifications(b,true) or manager.menu.open then return false end
end

c64transfer()

event.register(event.tick,tick)
event.register(event.mousemove,mousemove)
event.register(event.mousedown,mousedown)
event.register(event.mouseup,mouseup)

fs.makeDirectory(manager.dir)
fs.makeDirectory(manager.dir..manager.sdir)
loadDirectory(manager.dir,false,true)
loadDirectory(manager.dir..manager.sdir,true,false)

local run = io.open(epth(manager.dir)..'run.var','rb')
if run then
  local p = varParse(run:read('*a'))
  manager.toRun = {}
  for i,v in ipairs(manager.loaded) do --remove/add missing scripts
    local r = p[v.info.id] 
    if r==nil then r = false end
    manager.toRun[v.info.id] = r
  end
else
  run = io.open(epth(manager.dir)..'run.var','wb')
  run:write('')
end
pcall(io.close,run)

manager.pushNotification{
  text = string.format('Loaded %s script(s)',#manager.loaded),
  life = 60,
  fadeStart = 15,
  fade = true,
}

local function str(v)
  local t = type(v)
  if t=='string' or t=='number' then 
    return tostring(v)
  elseif tt=='bool' then
    return (t and 'true' or 'false')
  end
end

_G.voxelman = {
  expose = function(t)
    graphics.fillRect(0,0,graphics.WIDTH,graphics.HEIGHT,255,0,0,200)
    local con = tpt.confirm('VOXELMAN','Allow access to internal table?\nThis will give the script (almost) full control over the manager. ')
    if con then
      return manager
    else
      return false
    end
  end,
  pushNotification = function(t)
    local tt = type(t)
    if tt~='table' then
      t = {text = str(t)}
    end
    if tt=='table' then
      manager.pushNotification(t)
    end
    return {
      setText = function(t)
        local s = str(t)
        if type(s)=='string' then
          t.text = s
        end
      end,
      close = function()
        t.life = 0
        t.fade = false
        t.fadeStart = 0
      end
    }
  end,
  
  isMenuOpen = function()
    return manager.menu.open
  end,
  openMenu = function()
    manager.menu.open = true
  end,
  closeMenu = function()
    manager.menu.open = false
  end,
  moveMenu = function(x,y)
    if type(x)=='number' then
      manager.menu.x = x
    end
    if type(y)=='number' then
      manager.menu.y = y
    end
  end,
  resizeMenu = function(w,h)
    if type(w)=='number' then
      manager.menu.w = w
    end
    if type(h)=='number' then
      manager.menu.h = h
    end
  end,
  
  getScriptsDirectory = function()
    return manager.dir
  end,
  getUserScriptsDirectory = function()
    return manager.dir..manager.sdir
  end,
  
  isButtonShown = function()
    return manager.button.show
  end,
  showButton = function()
    manager.button.show = true
  end,
  hideButton = function()
    manager.button.show = false
  end,
  moveButton = function(x,y)
    if type(x)=='number' then
      manager.button.x = x
    end
    if type(y)=='number' then
      manager.button.y = y
    end
  end,
  
  getScriptHash = function(id)
    for i,v in pairs(manager.loaded) do
      if v.info.id == id then
        return v.hash
      end
    end
  end 
}

UIadd(
  UIbutton(
    manager.menu.w-manager.menu.toph,0,
    manager.menu.toph,manager.menu.toph,
    'X',function() manager.menu.open=false end,'exitbtn'
  )
)
manager.menu.tabs[1]:onSwitchTo()

if jmod then
  manager.button.y = manager.button.y+16
end

runAll()

collectgarbage("collect")
----- end -----
