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
    ssid = "Intranet of Thermostats",
    --pwd = "secret",
    save = false, -- XXX no need to wear out the flash if this config file is read every time
  },
  timer = {
    interval = 5000 -- publish temperature/humidity every 5s
  },
  relay = {
    pin = 8,
  },
  dht = {
    enable = false,
    pins = {5, 6}, -- pins on which dht sensors are attached
  },
  rtctime = {
    enable = true, -- set to false to use time.now() instead, which is useless if deep sleep is enabled
    sntp = {
      servers = nil, -- nil (use nodemcu ntp pool) or table with servers
      autorepeat = true, -- not strictly required but probably won't hurt
    }
  },
  dsleep_seconds = 30, -- set to 0 to disable deep sleep
  watchdog_seconds = 60, -- if network problems persist for this many seconds, reboot as a last resort
}
