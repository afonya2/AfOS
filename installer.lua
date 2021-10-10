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
    io.write("enter disk first 3 letter of id or none to cancel install! ")
    local szar = io.read()
    if szar ~= "none" then
        print("Installing updates...")
        print("Getting all files...")
        local da = ""
        for chunk in internet.request(url.."/FILES.txt") do
            da = da..chunk
        end
        local dirs = ser.unserialize(da).folders
        local files = ser.unserialize(da).files
        print("Getting all folders...")
        for k,v in ipairs(dirs) do
            exec("mkdir /mnt/"..szar..v)
        end
        print("Getting all files...")
        for k,v in ipairs(files) do
            exec("rm /mnt/"..szar..v)
            exec("wget "url..v.." /mnt/"..szar..v)
        end
        print("OK! Rebooting...")
        exec("reboot")
    else
        print("Back to shell")
    end
end
