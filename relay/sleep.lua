-- put nodemcu to sleep when we're not doing anything

local function naptime()
  (rtctime and rtctime or node).dsleep(config.dsleep_seconds*1000*1000, nil)
end

if config.dsleep_seconds ~= 0 then
  local t = tmr.create()
  t:register(config.timer.interval, tmr.ALARM_AUTO, naptime)
  t:start()
end

return {
  t = t
}
