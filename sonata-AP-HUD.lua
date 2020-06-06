require "graphics"
require "bit"

dataref( "view_type", "sim/graphics/view/view_type" )
--dataref("ALT_ARMED", "sim/cockpit2/autopilot/altitude_hold_armed")
dataref("ap_state", "sim/cockpit/autopilot/autopilot_state", "readonly")

local headingWindow = XPLMFindDataRef("sim/cockpit/autopilot/heading_mag")
local speedWindow = XPLMFindDataRef("sim/cockpit/autopilot/airspeed")
local altWindow = XPLMFindDataRef("sim/cockpit/autopilot/altitude")
local vsWindow = XPLMFindDataRef("sim/cockpit/autopilot/vertical_velocity")

isMach = XPLMFindDataRef("sim/cockpit/autopilot/airspeed_is_mach")

function render(spd, isFraction)
  if isFraction == 1 then
    return string.format("%1.3f", spd)
  else
    return string.format("%03i", spd)
  end
end

function draw_sonata_ap_hud()
  local isMachNow = XPLMGetDatai(isMach)

-- are we in HUD view?
  if view_type ~= 1023 then
    return
  end

  ssWidth, ssHeight = XPLMGetScreenSize()

  XPLMSetGraphicsState(0,0,0,1,1,0,0)

  autothrottleEngaged = bit.band(ap_state, 1)
  headingHoldEngaged = bit.band(ap_state, 2)
  vviEngaged = bit.band(ap_state, 16)
  flChgEngaged = bit.band(ap_state, 64)
  altHoldEngaged = bit.band(ap_state, 16384)

  -- draw some text
  local x_pos = ssWidth * 2.85 / 10
  local y_pos = ssHeight * 6.35 / 10
  if isMachNow == 1 then
     y_pos = ssHeight * 3.3 / 10
  end   
  if autothrottleEngaged > 0 then
    graphics.set_color(1,0,1,1)
  else
    graphics.set_color(0,1,0,1)
  end  
  local speed = XPLMGetDataf(speedWindow)
  draw_string_Helvetica_12(x_pos, y_pos, render(speed, isMachNow))

  if altHoldEngaged > 0 then
    graphics.set_color(0,0,1,1)
  elseif flChgEngaged > 0 then
    graphics.set_color(1,0,1,1)
  elseif vviEngaged > 0 then
    graphics.set_color(1,0,0,1)
  else
    graphics.set_color(0,1,0,1)
  end
  alt = XPLMGetDataf(altWindow)
  draw_string_Helvetica_12(ssWidth * 6.85 / 10, ssHeight * 6.35 / 10, string.format("%5i", alt))

  vvi = XPLMGetDataf(vsWindow)
  if vviEngaged > 0 or vvi < -.5 or vvi > .5 then
    if vviEngaged > 0 then
      graphics.set_color(0,0,1,1)
    elseif vvi < -.5 or vvi > .5 then
      graphics.set_color(1,0,1,1)
    else
      graphics.set_color(0,1,0,1)
    end
    draw_string_Helvetica_12(ssWidth * 7.6 / 10, ssHeight * 4.9 / 10, string.format("%5i", vvi))
  end
  
  hdg = XPLMGetDataf(headingWindow)
  if headingHoldEngaged > 0 then
    graphics.set_color(1,0,1,1)
  else  
    graphics.set_color(0,1,0,1)
  end
  draw_string_Helvetica_12(ssWidth * 5 / 10, ssHeight * 1 / 10, string.format("%03d", hdg))

--  graphics.set_color(1,1,1,1)
--  draw_string_Helvetica_18(12, 145, string.format("%3.2f", COM1/100))


end

do_every_draw("draw_sonata_ap_hud()")

