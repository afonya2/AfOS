local internet = require("internet")
local fs = require("filesystem")
local ser = require("serialization")
local shell = require("shell")
local url = "https://raw.githubusercontent.com/afonya2/AfOS/main"

function exec(data)
    shell.execute(data)
end

exec("clear")

print("Checking updates...")

local data = ""
for chunk in internet.request(url.."/VERSION.txt") do
    data = data..chunk
end
local ver = ser.unserialize(data).VERSION
if ver ~= _OSVERSION then
    io.write("Update Found! Do you want to install it? [y/n] ")
    local szar = io.read()
    if szar == "y" then
        print("Installing updates...")
        print("Getting all files...")
        local da = ""
        for chunk in internet.request(url.."/VERSION.txt") do
            da = data..chunk
        end
        local files = ser.unserialize(da)
        print("Getting all files...")
        for k,v in ipairs(files) do
            exec("wget "..url..v)
        end
        print("OK! Rebooting...")
        exec("reboot")
    else
        print("ok!")
    end
end
