tmr = require("tmr")

dofile("config.lua"); -- global configuration

do -- functions that are used everywhere
  fmt = string.format
  log = function(...)
    print("@"..gettime(), ...)
  end

  gettime = config.rtctime.enable and rtctime.get or tmr.time
end

-- some functions can only register a single callback, work around this by
-- adding hooks
hooks = {
  got_ip = {},
  wifi_connected = {},
  wifi_disconnected = {},
  main_timer = {},
}

dofile("interactive.lua"); -- helper functions for interactive use
main = dofile("main.lua");
--sleep = dofile("sleep.lua"); -- deep sleep
dht = dofile("dht.lua");

do -- wifi setup
  wifi.setmode(wifi.STATION)
  wifi.sta.config(config.wifi)
  wifi.sta.autoconnect(1);
end

do -- wifi logging and sntp and timer
  local sntp = config.rtctime.enable and require("sntp")

  local mon = wifi.eventmon
  mon.register(mon.STA_CONNECTED, function(T)
    log("wifi: connected!", fmt("%s (%s) (channel %d)", T.SSID, T.BSSID, T.channel))
    for _,hook in ipairs(hooks.wifi_connected) do
      hook(T)
    end
  end)

  mon.register(mon.STA_DISCONNECTED, function(T)
    log("wifi: disconnected!", fmt("%s (%s): %s", T.SSID, T.BSSID, T.reason))
    tmr.softwd()
    for _,hook in ipairs(hooks.wifi_disconnected) do
      hook(T)
    end
  end)

  local connect = 1
  local lastconnect = gettime()
  mon.register(mon.STA_GOT_IP, function(T)
    log("wifi: got ip!", fmt("%s/%s/%s connect=%d", T.IP, T.netmask, T.gateway, connect))

    local now = gettime()

    -- force attempt to sync sntp if the clock isn't set, or every 20 wifi reconnects or 5000 seconds
    if config.rtctime.enable and (gettime() < 100 or connect % 20 == 0 or now > lastconnect + 5000) then
      log("sntp: synchronizing time")
      sntp.sync(config.rtctime.sntp.servers, nil, nil, config.rtctime.sntp.autorepeat)
    end

    lastconnect = now
    connect = connect + 1

    for _,hook in ipairs(hooks.got_ip) do
      hook(T)
    end
  end)

  main_timer = tmr.create()
  main_timer:register(config.timer.interval, tmr.ALARM_AUTO, function()
    for _,hook in ipairs(hooks.main_timer) do
      hook()
    end
  end)
  main_timer:start()
end

log("init.lua finished!")
