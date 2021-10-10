local shell = require("shell")

function exec(data)
    shell.execute(data)
end

io.write("enter target disk first 3 letter of id or none to cancel copy! ")
local szar = io.read()
if szar ~= "none" then
    exec("cp /autorun.lua /mnt/"..szar.."/ -r")
    exec("cp /bin /mnt/"..szar.."/ -r")
    exec("cp /boot /mnt/"..szar.."/ -r")
    exec("cp /etc /mnt/"..szar.."/ -r")
    exec("cp /home /mnt/"..szar.."/ -r")
    exec("cp /lib /mnt/"..szar.."/ -r")
else
    print("Back to shell")
end
