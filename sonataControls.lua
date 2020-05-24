-- DataRefs
define_shared_DataRef("sonata/speedStep", "Int")
define_shared_DataRef("sonata/headingStep", "Int")
define_shared_DataRef("sonata/altitudeStep", "Int")
define_shared_DataRef("sonata/vsStep", "Int")
speedStep = XPLMFindDataRef("sonata/speedStep")
headingStep = XPLMFindDataRef("sonata/headingStep")
altitudeStep = XPLMFindDataRef("sonata/altitudeStep")
vsStep = XPLMFindDataRef("sonata/vsStep")

-- MCP windows
headingWindow = XPLMFindDataRef("sim/cockpit/autopilot/heading_mag")
speedWindow = XPLMFindDataRef("sim/cockpit/autopilot/airspeed")
altWindow = XPLMFindDataRef("sim/cockpit/autopilot/altitude")
vsWindow = XPLMFindDataRef("sim/cockpit/autopilot/vertical_velocity")

-- isMach = XPLMFindDataRef("sim/cockpit/autopilot/airspeed_is_mach")

-- MCP buttons
flchButton = XPLMFindDataRef("anim/18/button")
altHoldButton = XPLMFindDataRef("anim/25/button")
atEnabled = XPLMFindDataRef("anim/15/button")
headingSel = XPLMFindDataRef("anim/173/button")
apButton = XPLMFindDataRef("anim/13/button")
apDiscButton = XPLMFindDataRef("anim/176/button")
vsFPAButton = XPLMFindDataRef("anim/24/button")

-- Indicators
ap1Light = XPLMFindDataRef("lamps/251")

-- Other controls
panelBrightness = XPLMFindDataRef("sim/cockpit2/switches/panel_brightness_ratio")
instrumentBrightness = XPLMFindDataRef("sim/cockpit/electrical/instrument_brightness")
instrumentBrightnessRatio = XPLMFindDataRef("sim/cockpit2/switches/instrument_brightness_ratio")
hudBrightness = XPLMFindDataRef("sim/cockpit/electrical/HUD_brightness")
hudBrightnessRatio = XPLMFindDataRef("sim/cockpit2/switches/HUD_brightness_ratio")

-- Values
simRunTime = XPLMFindDataRef("sim/time/total_running_time_sec")

-- Constants
go_up = 1
go_down = -1

-- Variables
apDisconnectFirst = 0
lastAltChange = -1

-- Commands

create_command( "sonata/AP/Autopilot1button", "Sonata Autopilot 1 toggle",
                "toggle_autopilot()",
		"", "");

create_command( "sonata/AP/Autothrottlebutton", "Sonata Autothrottle toggle",
                "toggle_button(atEnabled)",
		"", "");

create_command( "sonata/AP/VSFPAbutton", "Sonata VS/FPA button",
                "toggle_button(vsFPAButton)",
		"", "");

create_command( "sonata/AP/HeadingSelect", "Sonata Heading Select",
                "toggle_button(headingSel)",
		"", "");

create_command( "sonata/AP/FlightLevelChange", "Sonata Flight Level Change",
                "flch_change()",
		"", "");

create_command( "sonata/AP/HeadingUp", "Sonata Heading up 1 degree",
                "heading_change(go_up)",
                "", "");

create_command( "sonata/AP/HeadingDown", "Sonata Heading down 1 degree",
                "heading_change(go_down)",
                "", "");  

create_command( "sonata/AP/SpeedUp", "Sonata Speed up current step",
                "speed_change(go_up)",
                "", "");

create_command( "sonata/AP/SpeedDown", "Sonata Speed down current step",
                "speed_change(go_down)",
                "", "")

create_command( "sonata/AP/AltitudeUp", "Sonata Altitude up current step",
                "alt_change(go_up)",
                "", "");

create_command( "sonata/AP/AltitudeDown", "Sonata Altitude down current step",
                "alt_change(go_down)",
                "", "");

create_command( "sonata/AP/VerticalSpeedUp", "Sonata Vertical Speed up current step",
                "vs_change(go_up)",
                "", "");

create_command( "sonata/AP/VerticalSpeedDown", "Sonata Vertical Speed down current step",
                "vs_change(go_down)",
                "", "");

create_command( "sonata/Cockpit/PanelBrightnessUp", "Sonata Panel Brightness Up",
                "brightness_change(go_up)",
		"", "");

create_command( "sonata/Cockpit/PanelBrightnessDown", "Sonata Panel Brightness Down",
                "brightness_change(go_down)",
		"", "");


-- Actions

function toggle_button(ref)
    XPLMSetDatai(ref, toggle_int(XPLMGetDatai(ref)))
end

function toggle_autopilot()
	 apEnabled = XPLMGetDataf(ap1Light)
	 if apEnabled > .5 then
	    XPLMSetDatai(apDiscButton, toggle_int(XPLMGetDatai(apDiscButton)))
	    apDisconnectFirst = 1
	 elseif apDisconnectFirst == 1 then
	    XPLMSetDatai(apDiscButton, toggle_int(XPLMGetDatai(apDiscButton)))
	    apDisconnectFirst = 0
	 else
	    XPLMSetDatai(apButton, toggle_int(XPLMGetDatai(apButton)))
	 end
end

function flch_change()
 	 XPLMSetDatai(toggle_int(XPLMGetDatai(flchButton)))
end

function brightness_change(direction)
 	change = direction * .4
	change_it(instrumentBrightness, change)
	change_it(hudBrightness, change)
	change_it(instrumentBrightnessRatio, change)
	change_it(hudBrightnessRatio, change)
end

-- Autopilot / autothrottle settings Windows

function speed_change(direction)
         new_speed = XPLMGetDataf(speedWindow)
	 increment = XPLMGetDatai(speedStep)
	 if new_speed < 1 then
	    new_speed = new_speed * 100
	    new_speed = math.floor(new_speed + .5)
	    new_speed = new_speed / 100
	    increment = increment * .01
	 end
	 increment = increment * direction
	 new_speed = new_speed + increment
	 new_speed = floorToStep(new_speed, increment)
	 if new_speed < 0 then
            new_speed = 0
         end
	 XPLMSetDataf(speedWindow, new_speed)
end

function heading_change(direction)
         new_heading =XPLMGetDataf(headingWindow)
	 increment = XPLMGetDatai(headingStep)
	 increment = increment * direction
	 new_heading = new_heading + increment
	 new_heading = floorToStep(new_heading, increment)
	 new_heading = trunc_heading(new_heading)
	 XPLMSetDataf(headingWindow, new_heading)
end

function alt_change(direction)
         cur_alt = XPLMGetDataf(altWindow)
	 increment = XPLMGetDatai(altitudeStep)
	 change = increment
	 change = change * direction
	 new_alt = cur_alt + change
	 new_alt = floorToStep(new_alt, increment)
	 XPLMSetDataf(altWindow, new_alt)
end

function vs_change(direction)
	 new_vs = XPLMGetDataf(vsWindow)
	 increment = XPLMGetDatai(vsStep)
	 change = increment
	 change = change * direction
	 new_vs = new_vs + change
	 new_vs = floorToStep(new_vs, increment)
	 XPLMSetDataf(vsWindow, new_vs)
end

-- Utilities

function change_it(dataRef, delta)
	XPLMSetDataf(dataRef, trunc_ratio(XPLMGetDataf(dataRef) + delta))
end

function stepSize(small, big)
	 sonataStepNow = XPLMGetDatai(sonataStep)
	 if sonataStepNow == 1 then
	     return big
	 else
	     return small
	 end
end

function floorToStep(val, increment)
	 y = val
	 y = y / increment
	 y = y + .5
	 y = math.floor(y)
	 y = y * increment
	 return y
end	 


function trunc_heading(x)
	 y = x % 360
	 if y < 0 then
	    y = 360 - y
	 end
	 if y == 0 then
	    y = 360
	 end
	 return y
end

function trunc_ratio(x)
	 y = x
	 if y < 0 then
	    y = 0
	 end
	 if y >= 1 then
	    y = 1
	 end
	 return y
end

function toggle_int(x)
	 y = x
	 if y > 0 then
	    y = 0
	 else
	    y = 1
	 end
	 return y
end

