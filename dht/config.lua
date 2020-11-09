-- global config file, contains all settings
config = {
  mqtt = {
    clientid = "sensor-livingroom",
    timeout = 120,
    user = "thermostat",
    pass = "geheim",
    use_tls = false,
    host = "10.20.31.89",
    port = 1883,
    prefix = "/sensor/livingroom/"
  },
  dht11 = { -- temperature sensor
    pin = 1,
  },
  wifi = { -- wifi.sta config
    ssid = "Intranet of Thermostats",
    pwd = "lolsecret",
    save = false, -- XXX no need to wear out the flash if this config file is read every time
  },
  timer = {
    interval = 5000 -- publish temperature/humidity every 5s
  }
}
