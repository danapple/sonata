require "graphics"
require "bit"

-- positions
  local throttle_x = 80
  local throttle_y = 80
  local throttle_right_x_offset = 130

  local brakes_x = 340
  local brakes_y = 80

  local gear_x_offset = 120
  local gear_y = 80

  local flaps_x_offset = 320
  local flaps_y = 55

  local speedbrakes_x_offset = 300
  local speedbrakes_y = 60

dataref( "view_type", "sim/graphics/view/view_type" )
dataref("ap_state", "sim/cockpit/autopilot/autopilot_state", "readonly")

local throttlePositionDR = XPLMFindDataRef("sim/flightmodel2/engines/throttle_used_ratio")
local n1percentDR = XPLMFindDataRef("sim/cockpit2/engine/indicators/N1_percent")

local autobrakeDR = XPLMFindDataRef("sim/cockpit2/switches/auto_brake_level")
local parkbrakeDR = XPLMFindDataRef("sim/flightmodel/controls/parkbrake")
local leftbrakeDR = XPLMFindDataRef("sim/cockpit2/controls/left_brake_ratio")
local rightbrakeDR = XPLMFindDataRef("sim/cockpit2/controls/right_brake_ratio")

local n1_green_low_DR = XPLMFindDataRef("sim/aircraft/limits/green_lo_N1")
local n1_green_high_DR = XPLMFindDataRef("sim/aircraft/limits/green_hi_N1")
local n1_yellow_low_DR = XPLMFindDataRef("sim/aircraft/limits/yellow_lo_N1")
local n1_yellow_high_DR = XPLMFindDataRef("sim/aircraft/limits/yellow_hi_N1")
local n1_red_low_DR = XPLMFindDataRef("sim/aircraft/limits/red_lo_N1")
local n1_red_high_DR = XPLMFindDataRef("sim/aircraft/limits/red_hi_N1")

local n1_green_low = .20
local n1_green_high = .89
local n1_yellow_low = .00
local n1_yellow_high = .19
local n1_red_low = .90
local n1_red_high = .200

if 0 == 1 then
--  n1_green_low = XPLMGetDataf(n1_green_low_DR)
--  n1_green_high = PLMGetDataf(n1_green_high_DR)
--  n1_yellow_low = XPLMGetDataf(n1_yellow_low_DR)
--  n1_yellow_high = XPLMGetDataf(n1_yellow_high_DR)
--  n1_red_low = XPLMGetDataf(n1_red_low_DR)
--  n1_red_high = XPLMGetDataf(n1_red_high_DR)
end

local reverser_deployed_DR = XPLMFindDataRef("sim/flightmodel2/engines/thrust_reverser_deploy_ratio")

local gear_handle_DR = XPLMFindDataRef("sim/cockpit/switches/gear_handle_status")
local gear_deploy_DR = XPLMFindDataRef("sim/aircraft/parts/acf_gear_deploy")
local gear_unsafe_DR = XPLMFindDataRef("sim/cockpit/warnings/annunciators/gear_unsafe")

local arresting_gear_DR = XPLMFindDataRef("sim/cockpit/switches/arresting_gear")

local tailhook_ratio_DR = XPLMFindDataRef("sim/flightmodel/controls/tailhook_ratio")
local tailhook_angle_DR = XPLMFindDataRef("sim/flightmodel2/misc/tailhook_angle_degrees")
local tailhook_deploy_DR = XPLMFindDataRef("sim/cockpit2/switches/tailhook_deploy")

local flaps_handle_DR = XPLMFindDataRef("sim/cockpit2/controls/flap_ratio")
local flaps_deployed_DR = XPLMFindDataRef("sim/flightmodel2/controls/flap1_deploy_ratio")

local speedbrakes_handle_DR = XPLMFindDataRef("sim/cockpit2/controls/speedbrake_ratio")
local speedbrakes_deployed_DR = XPLMFindDataRef("sim/flightmodel2/controls/speedbrake_ratio")

function draw_sonata_hud()

-- are we in HUD view?
  if view_type ~= 1023 then
    return
  end

  ssWidth, ssHeight = XPLMGetScreenSize()

  XPLMSetGraphicsState(0,0,0,1,1,0,0)

  autothrottleEngaged = bit.band(ap_state, 1)

  draw_throttle(autothrottleEngaged)
  draw_landing_gear(ssWidth)
  draw_flaps(ssWidth)
  draw_speedbrakes(ssWidth)
  draw_brakes(ssWidth)

end

do_every_draw("draw_sonata_hud()")

function draw_flaps(ssWidth)
  local flaps_handle = XPLMGetDataf(flaps_handle_DR)
  local flaps_deployed = XPLMGetDataf(flaps_deployed_DR)

  if flaps_deployed > 0 or flaps_handle > 0 then
     graphics.set_color(1,1,1,.4)
     graphics.draw_filled_arc(ssWidth - flaps_x_offset, flaps_y, 90, 90 + (35 * flaps_deployed), 60)
     graphics.draw_arc(ssWidth - flaps_x_offset, flaps_y, 90, 90 + (35 * flaps_handle), 62)
  end
end

function draw_speedbrakes(ssWidth)
  local speedbrakes_handle = XPLMGetDataf(speedbrakes_handle_DR)
  local speedbrakes_deployed = XPLMGetDataf(speedbrakes_deployed_DR)
  if speedbrakes_deployed > .01 or speedbrakes_handle > .01 or speedbrakes_handle < -0.01 then
     graphics.set_color(1,1,.7,.4)
     graphics.draw_filled_arc(ssWidth - speedbrakes_x_offset, speedbrakes_y, 90 - (25 * speedbrakes_deployed), 90, 30)
     graphics.draw_arc(ssWidth - speedbrakes_x_offset, speedbrakes_y, 90 - (25 * speedbrakes_handle), 90, 32)
     if speedbrakes_handle < -.01 then
       draw_string_Helvetica_12(ssWidth - speedbrakes_x_offset, speedbrakes_y + 10, "Armed")
     end
  end

end

function draw_brakes(ssWidth)
  autobrake = XPLMGetDatai(autobrakeDR)  -- 0 is RTO (Rejected Take-Off), 1 is off, 2->5 are increasing auto-brake levels.
  parkbrake = XPLMGetDataf(parkbrakeDR)
  left_toe_brake = XPLMGetDataf(leftbrakeDR)
  right_toe_brake = XPLMGetDataf(rightbrakeDR)
  text = ""
  draw = 0
  if autobrake == 0 then
    text = "RTO"
    draw = 1
  elseif autobrake == 5 then
    text = "MAX"
    draw = 1
  elseif autobrake > 1 then
    text = autobrake - 1
    draw = 1
  end
  if draw == 1 then
     graphics.set_color(1,1,1,.4)
     draw_string_Helvetica_12(brakes_x, brakes_y - 60, "Armed: " .. text)
  end

  local left_brake = math.min(1, parkbrake + left_toe_brake)
  local right_brake = math.min(1, parkbrake + right_toe_brake)

  if draw == 1 or left_brake ~= 0 then
    draw_brake(brakes_x, brakes_y - 20, left_brake)
  end
  if draw == 1 or right_brake ~= 0 then
    draw_brake(brakes_x + 70, brakes_y - 20, right_brake)
  end
 
-- Armed: RTO, 1, 2, 3, 4, 5
-- OFF
-- Applied

end

function draw_brake(x, y, ratio)
    graphics.set_color(.3,.3,.3,.8)
    graphics.draw_circle(x, y, 15, 20)
    graphics.set_color(1, 1, .3,.4)
    graphics.draw_arc_line(x, y, 90, 90 + (60 * ratio), 20, 6)
    graphics.draw_arc_line(x, y, 90 - (60 * ratio), 90, 20, 6)
    graphics.draw_arc_line(x, y, 270, 270 + (60 * ratio), 20, 6)
    graphics.draw_arc_line(x, y, 270 - (60 * ratio), 270, 20, 6)
    draw_string_Helvetica_12(x - 10, y + 25, string.format("%3i", ratio * 100))
end


function draw_landing_gear(ssWidth)

  local gear_x = ssWidth - gear_x_offset
  local gear_handle = XPLMGetDatai(gear_handle_DR)
  local gear_deploy = XPLMGetDatavf(gear_deploy_DR, 0, 3)
  local gear_unsafe = XPLMGetDatai(gear_unsafe_DR)

  local gear_mismatch = 0

  local nose_deploy = gear_deploy[0]
  local left_deploy = gear_deploy[1]
  local right_deploy = gear_deploy[2]

  if gear_handle ~= nose_deploy then
     gear_mismatch = 1
  end
  if gear_handle ~= left_deploy then
     gear_mismatch = 1
  end
  if gear_handle ~= right_deploy then
     gear_mismatch = 1
  end

  if gear_handle == 1 or gear_unsafe == 1 or gear_mismatch == 1 then
    graphics.set_color(1, 1, 1, .7)
    graphics.draw_circle(gear_x, gear_y, 15, 2)
    graphics.draw_circle(gear_x - 25, gear_y - 30, 14, 2)
    graphics.draw_circle(gear_x + 25, gear_y - 30, 14, 2)

    set_gear_color(gear_handle, nose_deploy)
    graphics.draw_filled_circle(gear_x, gear_y, 12)

    set_gear_color(gear_handle, left_deploy)
    graphics.draw_filled_circle(gear_x - 25, gear_y - 30, 12)

    set_gear_color(gear_handle, right_deploy)
    graphics.draw_filled_circle(gear_x + 25, gear_y - 30, 12)

  end

end

function set_gear_color(gear_handle, deploy)
    if deploy == 1 then
      graphics.set_color(0, 1, 0, .7)
    elseif gear_handle == 0 and deploy > 0 then
      graphics.set_color(1, 1, 0, .7)
    elseif gear_handle == 1 then
      graphics.set_color(1, 0, 0, .7)
    else 
      graphics.set_color(1, 0, 0, 0)
    end
end


function draw_throttle(autothrottleEngaged)

-- throttle
  local throttlePosition = XPLMGetDatavf(throttlePositionDR, 0, 2)
  local n1percent = XPLMGetDatavf(n1percentDR, 0, 2)
  local reverser = XPLMGetDatavf(reverser_deployed_DR, 0, 2)

  local n1percentLeft = n1percent[0]/100
  local n1percentRight = n1percent[1]/100

  local throttleLeft = (.8 * throttlePosition[0]) + .2
  local throttleRight = (.8 * throttlePosition[1]) + .2

  local reverserLeft = reverser[0]
  local reverserRight = reverser[1]

-- actual N1
 -- Left engine

  set_throttle_arc_color(n1percentLeft)
  graphics.draw_filled_arc(throttle_x, throttle_y, 90, 90 + (270 * n1percentLeft), 50)

  set_throttle_text_color(n1percentLeft)
  draw_string_Helvetica_12(throttle_x + 20, throttle_y + 5, string.format("%3i", (n1percentLeft * 100) +.5))

 -- Right engine
  set_throttle_arc_color(n1percentRight)
  graphics.draw_filled_arc(throttle_x + throttle_right_x_offset, throttle_y, 90, 90 + (270 * n1percentRight), 50)

  set_throttle_text_color(n1percentRight)
  draw_string_Helvetica_12(throttle_x + throttle_right_x_offset + 10, throttle_y + 5, string.format("%3i", (n1percentRight * 100) +.5))

-- target N1
  set_throttle_arc_color(throttleLeft)
  graphics.draw_arc(throttle_x, throttle_y, 90, 90 + (270 * throttleLeft), 52, 2)
  if autothrottleEngaged == 1 then
     graphics.set_color(1,0,1,.3)
     graphics.draw_outer_tracer( throttle_x, throttle_y, 90 + (270 * throttleLeft), 52, 15)
  end

  set_throttle_arc_color(throttleRight)
  graphics.draw_arc(throttle_x + throttle_right_x_offset, throttle_y, 90, 90 + (270 * throttleRight), 52, 2)
  if autothrottleEngaged == 1 then
     graphics.set_color(1,0,1,.3)
     graphics.draw_outer_tracer( throttle_x + throttle_right_x_offset, throttle_y, 90 + (270 * throttleRight), 52, 15)
  end

  set_throttle_text_color(throttleLeft)
  draw_string_Helvetica_12(throttle_x + 20, throttle_y + 20, string.format("%3i", throttleLeft * 100))

  set_throttle_text_color(throttleRight)
  draw_string_Helvetica_12(throttle_x + throttle_right_x_offset + 10, throttle_y + 20, string.format("%3i", throttleRight * 100))

-- Reverser

  if reverserLeft > .01 then
    graphics.set_color(0, 0, 1, .7)
    graphics.draw_arc(throttle_x, throttle_y, 90 - (90 * reverserLeft), 90, 52)
  end

  if reverserRight > .01 then
    graphics.set_color(0, 0, 1, .7)
    graphics.draw_arc(throttle_x + 110, throttle_y, 90 - (90 * reverserRight), 90, 52)
  end

end

function set_throttle_arc_color(n1percent)
  if n1percent >= n1_red_low then
    graphics.set_color(1, 0, 0, .8)
  elseif n1percent >= n1_yellow_low and n1percent < n1_yellow_high then
    graphics.set_color(1, 1, 0, .6)
  else
    graphics.set_color(1, 1, 1, .2)
  end
end

function set_throttle_text_color(n1percent)
   if n1percent >= n1_red_low then
    graphics.set_color(1, 0, 0, 1)
  elseif n1percent >= n1_yellow_low and n1percent < n1_yellow_high then
    graphics.set_color(1, 1, 0, .6)
  else
    graphics.set_color(1, 1, 1, .3)
  end
end

