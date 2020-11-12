dofile("interactive.lua"); -- helper functions for interactive use
dofile("config.lua"); -- global configuration
main = dofile("main.lua");

-- wifi setup
wifi.setmode(wifi.STATION)
wifi.sta.config(config.wifi)
log("main.lua loaded!")
