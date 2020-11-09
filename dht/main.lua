-- Periodically read a dht11 thermometer/humidity sensor and publish the result
-- via mqtt

local tmr = require("tmr")
local mqtt = require("mqtt")

local cf = config.mqtt
local path = { -- topic paths
  online        = cf.prefix .. "online",
  temperature   = cf.prefix .. "temperature",
  humidity      = cf.prefix .. "humidity",
  uptime        = cf.prefix .. "uptime",
}

local m, t -- mqtt client, timer

local function timer_tick()
  local ht = dht11.read(config.dht11.pin)

  if ht.status ~= dht.OK then
    return -- TODO: publish error state/time?
  end

  m:publish(path.temperature, tostring(ht.temp),    0, 1)
  m:publish(path.humidity,    tostring(ht.humi),    0, 1)
  m:publish(path.uptime,      tostring(tmr.time()), 0, 0)
end

local function connect_handler(client)
  client:publish(path.online, "true", 0, 1)
  t:start()
  timer_tick()
end


m = mqtt.Client(cf.clientid, cf.timeout, cf.user, cf.pass)

--[[m:on("connect", function(client) print ("connected") end)
m:on("connfail", function(client, reason) print ("connection failed", reason) end)
m:on("offline", function(client) print ("offline") end)]]

m:lwt(path.online, "false", 0, 1) -- "last will and testament"

t = tmr.create()
m:connect(cf.host, cf.port, cf.use_tls, connect_handler)
t:register(config.timer.interval, tmr.ALARM_AUTO, timer_tick)

return { -- export some stuff for interactive use
  m = m,
  t = t,
  path = path,
}
