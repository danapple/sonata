-- Copyright 2020 Daniel I. Applebaum

--[[
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

define_shared_DataRef("sonata/speedStep", "Int")
define_shared_DataRef("sonata/headingStep", "Int")
define_shared_DataRef("sonata/altitudeStep", "Int")
define_shared_DataRef("sonata/vsStep", "Int")

-- Switches
create_switch( (2*160) + 19, "sonata/speedStep", 0, 1, 10)
create_switch( (2*160) + 20, "sonata/headingStep", 0, 1, 10)
create_switch( (2*160) + 21, "sonata/altitudeStep", 0, 100, 1000)
create_switch( (2*160) + 27, "sonata/vsStep", 0, 10, 100)

create_switch( (2*160) + 24, "sim/cockpit/switches/gear_handle_status", 0, 1, 0) -- landing gear

create_switch( (2*160) + 18, "sim/cockpit2/switches/landing_lights_on", 0, 0, 1) -- landing lights
--create_switch( (2*160) + 25, "sim/cockpit/autopilot/autopilot_mode", 0, 0, 2)   -- autothrottle arm
create_positive_edge_flip( (2*160) + 25, "sim/cockpit/autopilot/autopilot_mode", 0, 2)
create_positive_edge_flip( (2*160) + 25, "sim/cockpit/autopilot/autopilot_mode", 2, 0)

