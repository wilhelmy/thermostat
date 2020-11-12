log = function(...)
  print("@"..tmr.time(), ...)
end

dofile("interactive.lua"); -- helper functions for interactive use
dofile("config.lua"); -- global configuration
main = dofile("main.lua");
sleep = dofile("sleep.lua"); -- deep sleep

-- wifi setup
wifi.setmode(wifi.STATION)
wifi.sta.config(config.wifi)
wifi.sta.autoconnect(1);

log("init.lua finished!")
