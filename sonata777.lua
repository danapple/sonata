-- MCP windows
headingWindow = XPLMFindDataRef("T7Avionics/ap/hdg_act")
speedWindow = XPLMFindDataRef("T7Avionics/ap/spd_act")
altWindow = XPLMFindDataRef("T7Avionics/ap/alt_act")
vsWindow = XPLMFindDataRef("T7Avionics/ap/vs_act")

-- MCP controls
flchButton = XPLMFindDataRef("anim/18/button")
altHoldButton = XPLMFindDataRef("anim/25/button")
atEnabled = XPLMFindDataRef("anim/15/button")
atArm = XPLMFindDataRef("anim/33/switch")
headingSel = XPLMFindDataRef("anim/173/button")
apButton = XPLMFindDataRef("anim/13/button")

-- Other controls
panelBrightness = XPLMFindDataRef("sim/cockpit2/switches/panel_brightness_ratio")
instrumentBrightness = XPLMFindDataRef("sim/cockpit/electrical/instrument_brightness")
instrumentBrightnessRatio = XPLMFindDataRef("sim/cockpit2/switches/instrument_brightness_ratio")
hudBrightness = XPLMFindDataRef("sim/cockpit/electrical/HUD_brightness")
hudBrightnessRatio = XPLMFindDataRef("sim/cockpit2/switches/HUD_brightness_ratio")

-- Constants
go_up = 1
go_down = -1

-- Variables
altChange = 100
hdgChange = 1
spdChange = 1

-- Commands

create_command( "sonata777/AP/Autopilot1button", "Sonata Autopilot 1 toggle",
                "",
		"",
                "XPLMSetDatai(apButton, toggle_int(XPLMGetDatai(apButton)))");

create_command( "sonata777/AP/Autothrottlebutton", "Sonata Autothrottle toggle",
                "",
		"",
                "XPLMSetDatai(atEnabled, toggle_int(XPLMGetDatai(atEnabled)))");

create_command( "sonata777/AP/HeadingSelect", "Sonata Heading Select",
                "",
		"",
                "XPLMSetDatai(headingSel, 0)");

create_command( "sonata777/AP/AutothrottleArm", "Sonata Autothrottle Arm",
                "",
		"",
                "XPLMSetDatai(atArm, 1)");

create_command( "sonata777/AP/AutothrottleDisarm", "Sonata Autothrottle Disarm",
                "",
		"",
                "XPLMSetDatai(atArm, 0)");

create_command( "sonata777/AP/FlightLevelChange", "Sonata Flight Level Change",
                "",
		"",
                "flch_change()");

create_command( "sonata777/AP/HeadingUp", "Sonata Heading up 1 degree",
                "",
                "XPLMSetDataf(headingWindow, trunc_heading(XPLMGetDataf(headingWindow) + hdgChange))", "");

create_command( "sonata777/AP/HeadingDown", "Sonata Heading down 1 degree",
                "",
                "XPLMSetDataf(headingWindow, trunc_heading(XPLMGetDataf(headingWindow) - hdgChange))", "");  

create_command( "sonata777/AP/SpeedUp", "Sonata Speed up 1 unit",
                "",
                "XPLMSetDataf(speedWindow, speed_change(XPLMGetDataf(speedWindow), go_up))", "");

create_command( "sonata777/AP/SpeedDown", "Sonata Speed down 1 unit",
                "",
                "XPLMSetDataf(speedWindow, speed_change(XPLMGetDataf(speedWindow), go_down))", "")

create_command( "sonata777/AP/AltitudeDiff100", "Sonata Altitude differential to 100 feet",
                "",
                "small_change()", "");

create_command( "sonata777/AP/AltitudeDiff1000", "Sonata Altitude differential to 1000 feet",
                "",
                "big_change()", "");

create_command( "sonata777/AP/AltitudeUp", "Sonata Altitude up 1 unit",
                "",
                "XPLMSetDataf(altWindow, alt_change(XPLMGetDataf(altWindow), go_up))", "");

create_command( "sonata777/AP/AltitudeDown", "Sonata Altitude down 1 unit",
                "",
                "XPLMSetDataf(altWindow, alt_change(XPLMGetDataf(altWindow), go_down))", "");

create_command( "sonata777/AP/VerticalSpeedUp", "Sonata Vertical Speed up 100 ft/min",
                "",
                "XPLMSetDataf(vsWindow, XPLMGetDataf(vsWindow) + 100)", "");

create_command( "sonata777/AP/VerticalSpeedDown", "Sonata Vertical Speed down 100 ft/min",
                "",
                "XPLMSetDataf(vsWindow, XPLMGetDataf(vsWindow) - 100)", "");

create_command( "sonata777/Cockpit/PanelBrightnessUp", "Sonata Panel Brightness Up",
                "", "",
                "brightness_change(go_up)");

create_command( "sonata777/Cockpit/PanelBrightnessDown", "Sonata Panel Brightness Down",
                "", "",
                "brightness_change(go_down)");


-- Utilities

function small_change()
	 altChange = 100
	 hdgChange = 1
	 spdChange = 1
end

function big_change()
	 altChange = 1000
	 hdgChange = 10
	 spdChange = 10
end	 

function flch_change()
	 newVal = 1
	 curVal = XPLMGetDatai(flchButton)
	 if curVal == 1 then
	    newVal = 0
	 end
 	 XPLMSetDatai(flchButton, newVal)
end

function brightness_change(direction)
 	change = direction * .4
	change_it(instrumentBrightness, change)
	change_it(hudBrightness, change)
	change_it(instrumentBrightnessRatio, change)
	change_it(hudBrightnessRatio, change)
end

function change_it(dataRef, delta)
	XPLMSetDataf(dataRef, trunc_ratio(XPLMGetDataf(dataRef) + delta))
end

function speed_change(x, direction)
	 y = x
	 change = spdChange
	 if y < 1 then
	    y = y * 100
	    y = math.floor(y+.5)
	    y = y / 100
	    change = .01
	 end
	 change = change * direction
	 y = y + change
	 if y < 0 then
            y = 0
         end
	 return y
end

function alt_change(x, direction)
	 increment = altChange
	 y = x
	 y = y / increment
	 y = math.floor(y)
	 y = y * increment
	 change = increment
	 change = change * direction
	 y = y + change
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

