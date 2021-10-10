-- called from /init.lua
local raw_loadfile = ...

_G._OSVERSION = "AfOS 1.0.5-BETA"

-- luacheck: globals component computer unicode _OSVERSION
local component = component
local computer = computer
local unicode = unicode

-- Runlevel information.
_G.runlevel = "S"
local shutdown = computer.shutdown
computer.runlevel = function() return _G.runlevel end
computer.shutdown = function(reboot)
  _G.runlevel = reboot and 6 or 0
  if os.sleep then
    computer.pushSignal("shutdown")
    os.sleep(0.1) -- Allow shutdown processing.
  end
  shutdown(reboot)
end

local w, h
local screen = component.list("screen", true)()
local gpu = screen and component.list("gpu", true)()
local bar = {}
if gpu then
  gpu = component.proxy(gpu)
  if not gpu.getScreen() then
    gpu.bind(screen)
  end
  _G.boot_screen = gpu.getScreen()
  w, h = gpu.maxResolution()
  gpu.setResolution(w, h)
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")

bar.offc = 0x646464
bar.onc = 0x3264c8
bar.gpu = gpu

bar.draw = function(x,y,w,h,dat,max)
    for i=x,w,1 do
        for ii=y,h,1 do
            bar.gpu.setForeground(bar.offc)
            bar.gpu.set(i,ii,"█")
        end
    end
    for i=x,w/max*dat,1 do
        for ii=y,h,1 do
            bar.gpu.setForeground(bar.onc)
            bar.gpu.set(i,ii,"█")
        end
    end
    bar.gpu.setForeground(bar.onc)
    local szasz = dat/max*100
    bar.gpu.fill(w+1,y,100,1," ")
    bar.gpu.set(w+1,y,szasz.."%("..dat.."/"..max..")")
end
end

-- Report boot progress if possible.
local y = 2
local uptime = computer.uptime
-- we actually want to ref the original pullSignal here because /lib/event intercepts it later
-- because of that, we must re-pushSignal when we use this, else things break badly
local pull = computer.pullSignal
local last_sleep = uptime()
--[[local function status(msg)
  if gpu then
    gpu.set(1, y, msg)
    if y == h then
      gpu.copy(1, 2, w, h - 1, 0, -1)
      gpu.fill(1, h, w, 1, " ")
    else
      y = y + 1
    end
  end
  -- boot can be slow in some environments, protect from timeouts
  if uptime() - last_sleep > 1 then
    local signal = table.pack(pull(0))
    -- there might not be any signal
    if signal.n > 0 then
      -- push the signal back in queue for the system to use it
      computer.pushSignal(table.unpack(signal, 1, signal.n))
    end
    last_sleep = uptime()
  end
end]]

local dada = 1

local function status(msg)
  if gpu then
    local dara = {"\\","|","/","-"}
    gpu.fill(1,2,100,2," ")
    gpu.set(1,2,"Booting ".._OSVERSION)
    gpu.set(1,3,msg)
    gpu.set(1,4,dara[dada])
    dada = dada+1
    if dada == 5 then
      dada = 1
    end
  end
end

bar.draw(1,1,60,1,0,6)

--status("Booting " .. _OSVERSION .. "...")

bar.draw(1,1,60,1,1,6)

-- Custom low-level dofile implementation reading from our ROM.
local function dofile(file)
  status("> " .. file)
  local program, reason = raw_loadfile(file)
  if program then
    local result = table.pack(pcall(program))
    if result[1] then
      return table.unpack(result, 2, result.n)
    else
      error(result[2])
    end
  else
    error(reason)
  end
end

status("Initializing package management...")

bar.draw(1,1,60,1,2,6)

-- Load file system related libraries we need to load other stuff moree
-- comfortably. This is basically wrapper stuff for the file streams
-- provided by the filesystem components.
local package = dofile("/lib/package.lua")

do
  -- Unclutter global namespace now that we have the package module and a filesystem
  _G.component = nil
  _G.computer = nil
  _G.process = nil
  _G.unicode = nil
  -- Inject the package modules into the global namespace, as in Lua.
  _G.package = package

  -- Initialize the package module with some of our own APIs.
  package.loaded.component = component
  package.loaded.computer = computer
  package.loaded.unicode = unicode
  package.loaded.buffer = dofile("/lib/buffer.lua")
  package.loaded.filesystem = dofile("/lib/filesystem.lua")

  -- Inject the io modules
  _G.io = dofile("/lib/io.lua")
end

status("Initializing file system...")

bar.draw(1,1,60,1,3,6)

-- Mount the ROM and temporary file systems to allow working on the file
-- system module from this point on.
require("filesystem").mount(computer.getBootAddress(), "/")

status("Running boot scripts...")

bar.draw(1,1,60,1,4,6)

-- Run library startup scripts. These mostly initialize event handlers.
local function rom_invoke(method, ...)
  return component.invoke(computer.getBootAddress(), method, ...)
end

local scripts = {}
for _, file in ipairs(rom_invoke("list", "boot")) do
  local path = "boot/" .. file
  if not rom_invoke("isDirectory", path) then
    table.insert(scripts, path)
  end
end
table.sort(scripts)
for i = 1, #scripts do
  dofile(scripts[i])
end

status("Initializing components...")

bar.draw(1,1,60,1,5,6)

for c, t in component.list() do
  computer.pushSignal("component_added", c, t)
end

status("Initializing system...")

bar.draw(1,1,60,1,6,6)

computer.pushSignal("init") -- so libs know components are initialized.
require("event").pull(1, "init") -- Allow init processing.
_G.runlevel = 1
