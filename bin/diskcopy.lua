local shell = require("shell")

function exec(data)
    shell.execute(data)
end

io.write("enter target disk first 3 letter of id or none to cancel copy! ")
local szar = io.read()
if szar ~= "none" then
    exec("cp /autorun.lua /mnt/"..szar.."/")
    exec("cp /bin /mnt/"..szar.."/")
    exec("cp /boot /mnt/"..szar.."/")
    exec("cp /etc /mnt/"..szar.."/")
    exec("cp /home /mnt/"..szar.."/")
    exec("cp /lib /mnt/"..szar.."/")
else
    print("Back to shell")
end