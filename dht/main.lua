-- Periodically read a dht11 thermometer/humidity sensor and publish the result
-- via mqtt

local tmr = require("tmr")
local mqtt = require("mqtt")
local wifi = require("wifi")
local dht = require("dht")

local log = function(...)
  print("@"..tmr.time(), ...)
end
local fmt = string.format

local cf = config.mqtt
local m = mqtt.Client(cf.clientid, cf.timeout, cf.user, cf.pass)
local t = tmr.create()

local path = { -- topic paths
  online        = cf.prefix .. "online",
  temperature   = cf.prefix .. "temperature",
  humidity      = cf.prefix .. "humidity",
  uptime        = cf.prefix .. "uptime",
}

m:lwt(path.online, "false", 0, 1) -- "last will and testament"

local function timer_tick()
  local status, temp, humi = dht.read11(config.dht11.pin)

  if status ~= dht.OK then
    log("tmr: error reading dht11 sensor:"..
        status == dht.ERROR_TIMEOUT and "timeout" or "checksum")
    return -- TODO: publish error state/time?
  end

  log("tmr: event! temperature: "
      ..tostring(temp).. " humidity: ".. tostring(humi))

  m:publish(path.temperature, tostring(temp),    0, 1)
  m:publish(path.humidity,    tostring(humi),    0, 1)
  m:publish(path.uptime,      tostring(tmr.time()), 0, 0)
end

local function mqtt_connect_handler(client)
  client:publish(path.online, "true", 0, 1)
  log("mqtt: connected to broker!")
  t:start()
  timer_tick()
end

local mqtt_error_handler
local function mqtt_do_connect()
  log("mqtt: attempting connection")
  m:connect(cf.host, cf.port, cf.use_tls, mqtt_connect_handler, mqtt_error_handler)
end

local function mqtt_error_handler(client, reason)
  log("mqtt: connection failed. retrying in 10 seconds.", reason)
  tmr.create():alarm(10*1000, tmr.ALARM_SINGLE, mqtt_do_connect)
end

local mon = wifi.eventmon
mon.register(mon.STA_CONNECTED, function(T)
  log("wifi: connected!", fmt("%s (%s) (channel %d)", T.SSID, T.BSSID, T.channel))
end)

mon.register(mon.STA_DISCONNECTED, function(T)
  log("wifi: disconnected!", fmt("%s (%s): %s", T.SSID, T.BSSID, T.reason))
end)

mon.register(mon.STA_GOT_IP, function(T)
  log("wifi: got ip!", fmt("%s/%s/%s", T.IP, T.netmask, T.gateway))
  mqtt_do_connect()
  t:register(config.timer.interval, tmr.ALARM_AUTO, timer_tick)
end)

wifi.setmode(wifi.STATION)
wifi.sta.config(config.wifi)
log("main.lua loaded!")

return { -- export some stuff for interactive use
  m = m,
  t = t,
  path = path,
}
