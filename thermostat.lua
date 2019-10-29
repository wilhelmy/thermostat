-- NodeMCU code which switches the thermostat on and off via a relay board on
-- pin 0. I use it to remote-control the heating from the coldest room in my
-- flat (or possibly any other room in the future).

gpio = require("gpio")

screws = {
  relay_gpio_pin = 0,
  relay_pin_state = true, -- pin is LOW by default, which means the relay switches
  tcp_server_port = 23,
  tcp_timeout = 30 -- seconds
}

local log = print

function receiver(sck, data)
  local rv = nil

  if string.find(data, "on") == 1 then
    do_gpio(true)
  elseif string.find(data, "off") == 1 then
    do_gpio(false)
  elseif string.find(data, "state") == 1 then
    -- nothing
  elseif string.find(data, "toggle") == 1 then
    do_gpio(not screws.relay_pin_state)
  else
    rv = "invalid command"
  end

  if not rv then
    rv = screws.relay_pin_state and "on" or "off"
  end

  sck:send(rv)
  sck:close()
end

function do_gpio(val) -- val=false: pin off, true: on
  gpio.write(screws.relay_gpio_pin, val and gpio.LOW or gpio.HIGH)
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

  sv:listen(screws.tcp_server_port, function(conn) conn:on("receive", receiver) end)
end
