# sonata
Aerial Sonata enhancements for [X-Plane](https://www.x-plane.com/) utilizing [FlyWithLua](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/)

The included .lua scripts provided some fun enhancements for X-Plane.  Primarily, they enhance the HUD view to make it more possible to conduct all phases of flight without using a 2D or 3D cockpit.  They do this by providing display of the autopilot settings for altitude, heading, speed and vertical speed, as well as throttle position, engine N1 speed, wheel brakes application, speed brake deployment, flap deployment and landing gear position.  The autopilot and physical indicators are separated into two separate scripts.

All of these scripts were tested on X-Plane 11.41 and FlyWithLua 2.7.22.  FlyWithLua must be installed for these scripts to work.

Included scripts:
```
sonata-HUD.lua: Displays indicators for physical surfaces: throttle, engine N1, brakes, speed brakes, flaps, landing gear
sonata-AP-HUD.lua: Displays indicators for autopilot settings: speed, heading, altitude, vertical speed, color-coded to indicate modes
sonata-commands.lua: Commands for manipulating the autopilot with rotary encoders with push buttons
sonata-switches.lua: Examples of FlyWithLua code to help integrate external controls
```
