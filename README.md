# Userspace driver for the Logitech™ G13 Advanced Gameboard 
(https://www.logitechg.com/en-us/product/g13-advanced-gameboard)

## To Do
* Enable key down and key up actions for use in creating multi-character macros - in prior code, it pressed all keys in the list and then released all keys.  Macros with identical keys only triggered the first.  (e.g. G22 becomes G2).
* Debounce the joystick key mode so that single triggering works well for things like Next Song, and repeat triggering works for volume or scrolling type events.
* Add events for triggering scripts/apps.
* Add events for keypad layer switching (like the logitech software allows for the M1/M2/M3 keys)
* Add events for keypad color change (like the logitech software allows for the M1/M2/M3 keys)
* Support keycodes directly
* Layout design/programming tool
* On-board settings storage/retrieval 

## Installation

Make sure you have boost and libusb-1.0 installed.

 **For Ubuntu (15.10)**
* ***sudo apt-get install libusb-1.0-0-dev***
* ***sudo apt-get install libboost-all-dev***


### Build
Compile by running

    make

If you want to run the daemon as user, put the file 91-g13.rules into /etc/udev/rules.d/ (or whatever directory your distribution uses).

## Running


Connect your device, then run ./g13d, it should automatically find your device.

If you see output like the following things are good.  If you see any kind of [error] (especially "/dev/uinput doesn't grant write permissions") you may need to run with sudo. This output also shows you which name the keys on the G13 have, and what keys you can bind them to.

    Known keys on G13:
    BD DOWN G1 G10 G11 G12 G13 G14 G15 G16 G17 G18 G19 G2 G20 G21 G22 G3 G4 G5 G6 G7
     G8 G9 L1 L2 L3 L4 LEFT LIGHT LIGHT2 LIGHT_STATE M1 M2 M3 MISC_TOGGLE MR TOP UND
    EF1 UNDEF3 
    Known keys to map to:
    0 1 2 3 4 5 6 7 8 9 A APOSTROPHE B BACKSLASH BACKSPACE C CAPSLOCK COMMA D DELETE
     DOT DOWN E END ENTER EQUAL ESC F F1 F10 F11 F12 F2 F3 F4 F5 F6 F7 F8 F9 G GRAVE
      H HOME I INSERT J K KP0 KP1 KP2 KP3 KP4 KP5 KP6 KP7 KP8 KP9 KPASTERISK KPDOT K
      PMINUS KPPLUS L LEFT LEFTALT LEFTBRACE LEFTCTRL LEFTSHIFT M MINUS N NUMLOCK O 
      P PAGEDOWN PAGEUP Q R RIGHT RIGHTALT RIGHTBRACE RIGHTCTRL RIGHTSHIFT S SCROLLL
    OCK SEMICOLON SLASH SPACE T TAB U UP V W X Y Z 
    Found 1 G13s
    
    Active Stick zones 
               STICK_UP   { 0 x 0.1 / 1 x 0.3 }   SEND KEYS: UP
             STICK_DOWN   { 0 x 0.7 / 1 x 0.9 }   SEND KEYS: DOWN
             STICK_LEFT   { 0 x 0 / 0.2 x 1 }   SEND KEYS: LEFT
            STICK_RIGHT   { 0.8 x 0 / 1 x 1 }   SEND KEYS: RIGHT
           STICK_PAGEUP   { 0 x 0 / 1 x 0.1 }   SEND KEYS: PAGEUP
         STICK_PAGEDOWN   { 0 x 0.9 / 1 x 1 }   SEND KEYS: PAGEDOWN





### Command line options

The following options can be used when starting g13d

Option 				|  Description
--------------------|-------------------------------------------------
 --help             | show help
 --logo *arg*       | set logo from file
 --config *arg*     | load config commands from file
 --pipe_in *arg*    | specify name for input pipe
 --pipe_out *arg*   | specify name for output pipe

## Configuring / Remote Control

Configuration is accomplished using the commands described in the [Commands] section.

On start, commands from a configuration file may be loaded from the following possible locations in order of preference:
* the --config option on the command line.
* users home directory: ~/.g13/default.bind
* the local folder: ./default.bind
* configs sub folder: ./configs/default.bind 

Commands can be also be sent to the command input pipe, which is at ***/tmp/g13-0*** by 
default. Example:

    echo rgb 0 255 0 > /tmp/g13-0

### Actions

Various parts of configuring the G13 depend on assigning actions to occur based on something happening to the G13. 
* key, possible values shown upon startup  (e.g. ***KEY_LEFTSHIFT***).
* multiple keys,  like ***KEY_LEFTSHIFT+KEY_F1***
* pipe output, by using ">" followed by text, as in ***>Hello*** - causing **Hello** (plus newline) to be written to the output pipe ( **/tmp/g13-0_out** by default )
* command, by using "!" followed by text, as in ***!stick_mode KEYS*** 

## Commands

### rgb *r* *g* *b*

Sets the backlight color

### mod *n*

Sets the background light of the mod-keys. *n* is the sum of 1 (M1), 2 (M2), 4 (M3) and 8 (MR) (i.e. 13 
would set M1, M3 and MR, and unset M2).

### bind *keyname* *action*

This binds a key or a stick zone. 
* The possible values of *keyname* for keys are shown upon startup (e.g. G1).
* The possible values of *action* are described in [Actions].

### stickmode *mode*

The stick can be used as an absolute input device or can send key events. You can change modes to one of the following:

Mode       | Description
-----------|---------------------------
KEYS       | translates stick movements into key / action bindings
ABSOLUTE   | stick becomes mouse with absolute positioning
RELATIVE   | not quite working yet...
CALCENTER  | calibrate stick center position
CALBOUNDS  | calibrate stick boundaries
CALNORTH   | calibrate stick north
  
### stickzone *operation* *zonename* *args*

defines zones to be used when the stick is in KEYS mode

Where *operation* can be

operation | what it does
----------|----------------
add       | add a new zone named *zonename*
del       | remove zone named *zonename*
action    | set action for zone, see [Actions]  
bounds    | set boundaries for zone, *args* are X1, Y1, X2, Y2, where X1/Y1 are top left corner, X2/Y2 are bottom right corner 

Default created zones are LEFT, RIGHT, UP and DOWN.

Zone boundary coordinates are based on a floating point value from 0.0 (top/left) to 1.0 (bottom/right).  When the 
stick enters the boundary area, the zone's action ***down*** activity will be fired.  On exiting the boundary, the
action ***up*** activity will be fired.  

Example:

    stickzone add TheBottomLeft
    stickzone bounds TheBottomLeft 0.0 0.9 0.1 1.0
    stickzone action KEY_END

### pos *row* *col*

Sets the current text position to *row* *col*.  
* *row* is specified in characters (0-4), as all fonts are 8 pixels high and rows start on pixel row 0, 8, 16, 24, or 32
* *col* is specified in pixels (0-159)

### out *text*

Writes *text* to the LCD at the current text position, and advances the current position based on the font size

### clear

Clears the LCD

### textmode *mode*

Sets the text mode to *mode*, current options are 0 (normal) or 1 (inverted)

### refresh

Resends the LCD buffer

### profile *profile_name*
    
Selects *profile_name* to be the current profile, it if it doesn't exist creating it as a copy of the current profile.

All key binding changes (from the bind command) are made on the current profile.
  
### font *font_name*   

Switch font, current options are ***8x8*** and ***5x8***    

### dump *all|current|summary*

Dumps G13 configuration info to g13d console

### log_level *trace|debug|info|warning|error|fatal*

Changes the level of detail written to the g13d console 

### LCD display

Use pbm2lpbm to convert a pbm image to the correct format, then just cat that into the pipe (cat starcraft2.lpbm > /tmp/g13-0).
The pbm file must be 160x43 pixels.


## Installing as a systemd service
The make script is capable (with sudo) of installing the service as a systemd service (tested with Ubuntu 18 so far):

    make install

and uninstalling

    make uninstall


### configure

To change the key bindings that are loaded by default, edit ``/etc/g13d.d/default.bind``

### starting and stopping the service

start service
 
    sudo systemctl start g13d
    
stop service
  
    sudo systemctl stop g13d
     
### interacting with the service

The systemd service is configured to interact through pipes created in /tmp/g13d:

    /tmp/g13d/pipe.in
    /tmp/g13d/pipe.out

Logging goes to:
    /tmp/g13d/g13d.log

## License

All files without a copyright notice are placed in the public domain. Do with it whatever you want.

Some source code files include MIT style license - see files for specifics.
