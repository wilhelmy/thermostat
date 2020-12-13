-- put nodemcu to sleep when we're not doing anything
local _M = {
  inhibit = false -- set to true to temporarily disable deep sleep
}

local function naptime()
  if _M.inhibit then return end

  (rtctime and rtctime or node).dsleep(config.dsleep_seconds*1000*1000, nil)
end

if config.dsleep_seconds ~= 0 then
  table.insert(hooks.main_timer, naptime)
end

return _M
