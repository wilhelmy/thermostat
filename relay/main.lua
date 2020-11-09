-- NodeMCU code which switches the thermostat on and off via a relay board on
-- pin 0. I use it to remote-control the heating from the coldest room in my
-- flat (or possibly any other room in the future).

gpio = require("gpio")

screws = {
  relay_gpio_pin = 1,
  relay_pin_state = false, -- pin is LOW by default, which means the relay is off
  tcp_server_port = 23,
  tcp_timeout = 30, -- seconds
  button_gpio_pin = 3,
}

local log = print

function toggle()
  return do_gpio(not screws.relay_pin_state)
end

function receiver(sck, data)
  local rv = nil

  if string.find(data, "on") == 1 then
    do_gpio(true)
  elseif string.find(data, "off") == 1 then
    do_gpio(false)
  elseif string.find(data, "state") == 1 then
    -- nothing
  elseif string.find(data, "toggle") == 1 then
    toggle()
  else
    rv = "invalid command"
  end

  if not rv then
    rv = screws.relay_pin_state and "on" or "off"
  end

  sck:send(rv)
  sck:close()
end

function do_gpio(val) -- val=false: relay off, true: on
  gpio.write(screws.relay_gpio_pin, val and gpio.HIGH or gpio.LOW)
  screws.relay_pin_state = val and true or false
end


do -- startup
  gpio.mode(screws.relay_gpio_pin, gpio.OUTPUT)
  do_gpio(false)

  sv = net.createServer(net.TCP, screws.tcp_timeout)
  if not sv then
    log("Error creating server... is NodeMCU built with network support?")
    return
  end

  local last
  local function handler(level, when, eventcount)
    last = last or when
    if when > last + 200000 then
      toggle()
    end
  end

  gpio.mode(screws.button_gpio_pin, gpio.INT)
  gpio.trig(screws.button_gpio_pin, "up", handler)

  sv:listen(screws.tcp_server_port, function(conn) conn:on("receive", receiver) end)
end
