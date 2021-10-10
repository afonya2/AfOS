local bar = {}

bar.offc = 0x646464
bar.onc = 0x3264c8
bar.com = require("component")
bar.gpu = bar.com.gpu

bar.draw = function(x,y,h,dat,max)
    for i=x,max,1 do
        for ii=y,h,1 do
            bar.gpu.setForeground(bar.offc)
            bar.gpu.set(i,ii,"█")
        end
    end
    for i=x,dat,1 do
        for ii=y,h,1 do
            bar.gpu.setForeground(bar.onc)
            bar.gpu.set(i,ii,"█")
        end
    end
    bar.gpu.setForeground(bar.onc)
    local szasz = dat/max*100
    bar.gpu.set(max+1,y,szasz.."%("..dat.."/"..max..")")
end

return bar