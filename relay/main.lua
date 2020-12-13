-- NodeMCU code which switches the thermostat on and off via a relay board on
-- pin 0. I use it to remote-control the heating from the coldest room in my
-- flat (or possibly any other room in the future).

local gpio = require("gpio")
local tmr  = require("tmr")
local mqtt = require("mqtt")
local wifi = require("wifi")

local cf = config.mqtt
local m = mqtt.Client(cf.clientid, cf.timeout, cf.user, cf.pass)

local path = { -- topic paths
  online        = cf.prefix .. "online",
  uptime        = cf.prefix .. "uptime",
  request       = cf.prefix .. "request",
  state         = cf.prefix .. "state",
  lastmodified  = cf.prefix .. "lastmodified",
}

m:lwt(path.online, "false", 0, 1) -- "last will and testament"

local pin_state = false

local function pin_do_gpio(val) -- val=false: relay off, true: on
  gpio.write(config.relay.pin, val and gpio.HIGH or gpio.LOW)
  pin_state = val and true or false
end

local function mqtt_message_handler(client, topic, data)
  log("mqtt: got message: " .. fmt("%s: %s", topic, data or "<nil>"))
  if topic ~= path.request then
    log("mqtt: unknown topic ignored!")
    return
  end

  if data == nil then return end

  if data ~= "on" and data ~= "off" and data ~= "toggle" then
    log("mqtt: unknown request. must be {on,off,toggle}")
  end

  local new_state = data == "toggle" and not pin_state or data == "on"
  if pin_state ~= new_state then
    pin_do_gpio(new_state)
    client:publish(path.state, new_state and "on" or "off", 0, 1)
    client:publish(path.lastmodified, tostring(gettime()), 0, 1)
  end
  client:publish(path.request, "", 0, 1)
end

do -- setup
  gpio.mode(config.relay.pin, gpio.OUTPUT)
  pin_do_gpio(false)
  m:on("message", mqtt_message_handler)
end

local function timer_tick_hook()
  m:publish(path.uptime, tostring(tmr.time()), 0, 0)
end

local function mqtt_connect_handler(client)
  log("mqtt: connected to broker!")
  client:publish(path.online, "true", 0, 1)
  client:subscribe(path.request, 0, nil)
  client:publish(path.state, pin_state and "on" or "off", 0, 1)
  table.insert(hooks.main_timer, timer_tick_hook)
  timer_tick_hook()
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

table.insert(hooks.got_ip, mqtt_do_connect)

return { -- export some stuff for interactive use
  m = m,
  path = path,
}
