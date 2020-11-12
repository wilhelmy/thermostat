-- global config file, contains all settings
config = {
  mqtt = {
    clientid = "thermostat-relay",
    timeout = 120,
    user = "thermostat",
    pass = "geheim",
    use_tls = false,
    host = "10.20.30.74",
    port = 1883,
    prefix = "/thermostat/relay/"
  },
  wifi = { -- wifi.sta config
    --ssid = "Intranet of Thermostats",
    ssid = ([[Slavoj und der W\xC3\xBCrschtelk\xC3\xB6nig]]):gsub("\\x(%x%x)",function (x) return string.char(tonumber(x,16)) end),
    --bssid = "14:CC:20:E5:88:A2",
    --pwd = "temperatureisnotajoke",
    pwd = "iwouldprefernotto",
    save = false, -- XXX no need to wear out the flash if this config file is read every time
  },
  timer = {
    interval = 5000 -- publish temperature/humidity every 5s
  },
  relay = {
    pin = 8,
  },
  dht = {
    pins = {5, 6}, -- pins on which dht sensors are attached
  },
  dsleep_seconds = 30, -- set to 0 to disable deep sleep
}
