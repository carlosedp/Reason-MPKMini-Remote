# Akai MPK mini Remote Support

Version 1.0,   13 March 2015

David Antliff, Pitchblende Ltd., <david@pitchblende.co.nz>  
Carlos Eduardo, SP/Brazil, <carlosedp@gmail.com>  

The latest version supports:

Compatible with Reason 8 but may work with previous versions too.

**Kong pads** - turn off CC and PROG CHANGE, then Pad Bank 1 maps to Kong pads 1-8, Pad Bank 2 maps to pads 9-16.

**Switches** - turn on CC and each pad will act as a switch. Pad Bank 1 maps to switches 1-8, Pad Bank 2 maps to switches 9-16. Note that 'toggle' mode for the switches does not work correctly, and probably never will, so the pad lights will not stay lit.

**Prog Change** - turn on PROG CHANGE and each pad will generate push-button events. Currently these are set up to send Transport messages:

1 - Play  
2 - Stop  
3 - Record  
4 - Loop  
5 - Tap tempo  
6 - Add overdub  
7 - change to previous sequencer track  
8 - change to next sequencer track  


    |---------|     |---------|     |---------|     |---------|
    |  Pad 5  |     |  Pad 6  |     |  Pad 7  |     |  Pad 8  |
    |  CC#69  |     |  CC#70  |     |  CC#71  |     |  CC#72  |
    | TapTempo|     |  OvrDub |     |  TrkUp  |     |  TrkDn  |
    |_________|     |_________|     |_________|     |_________|

    |---------|     |---------|     |---------|     |---------|
    |  Pad 1  |     |  Pad 2  |     |  Pad 3  |     |  Pad 4  |
    |  CC#65  |     |  CC#66  |     |  CC#67  |     |  CC#68  |
    |  Play   |     |  Stop   |     |  Record |     |  Loop   |
    |_________|     |_________|     |_________|     |_________|


**Knobs** - eight knobs that are mapped to 'sensible' Reason controls. Note that Knob 1 is the top left knob. The knobs use soft pickup so they only act when the value on the knob matches the value of the control it is assigned. This way it is prevented that the control "jumps" when you modify a knob.

**Keyboard Sustain** (Damper Pedal) support - hold the "Sustain" button to activate.

# Installation

## Part 1 - Load the MPK mini Preset

The provided Preset ensures that your keyboard produces the correct MIDI messages are received by the Remote codec. To install the Preset:

 * Ensure neither Reason nor Record are running - they may interfere with this process.
 * Run the "Akai MPK MINI Editor" (on the CD provided with your controller, or downloadable from Akai's product support page)
 * Click "Load Preset" and load the "Reason.preset" file from the Presets directory that you earlier unzipped.
 * This will automatically switch the display to Preset Slot 1, but you can upload the new preset to any Slot you wish by clicking the "Preset #" drop-down and select the slot number you want to upload into.
 * Click the "Upload" button, and then click OK:

## Part 2 - Copy the Remote Files

The files in the Remote directory should be copied into your user's Remote directory:

    OSX: Macintosh HD/Library/Application Support/Propellerhead Software/Remote
       it is also possible to install into /Users/[username]/Library/Application Support/Propellerhead Software/Remote if you want to keep them separate from your main Reason installation.
    Windows XP: C:/Documents and Settings/Application Data/Propellerhead Software/Remote/
    Windows Vista: C:/Documents and Settings/Program Data/Propellerhead Software/Remote/
    Windows 7: C:/ProgramData/Propellerhead Software/Remote

Carefully copy all of these files, strictly maintaining this directory structure:

    Remote/Codecs/Lua Codecs/Akai/AkaiMPKmini.luacodec
    Remote/Codecs/Lua Codecs/Akai/AkaiMPKmini.lua
    Remote/Codecs/Lua Codecs/Akai/AkaiMPKmini.png
    Remote/Maps/Akai/AkaiMPKmini.remotemap

Now restart Reason so that it sees the new files. Go into Preferences and select your new MIDI controller - you can tell Reason to try and auto-detect the MPK mini, or you can add it manually.


# Customisation

Because the Lua Codec maps almost every control on the controller to a 'control item', you can customise the device mappings however you want. Simply edit the AkaiMPKmini.remotemap file to associate the MPK mini's controls with whatever Reason device controls you want. More information can be found here.

The available control items are:

*  Keyboard
*  Sustain
*  Knob 1-8
*  Pad Button 1-16
*  Prog Change 1-16

## For further details please visit:

https://github.com/carlosedp/Reason-MPKMini-Remote  
http://offwhitenoise.blogspot.com/2011/09/akai-mpk-mini-reason.html  

Note: I am not affiliated or associated in any way with Akai
or Propellerhead. I have created these files myself with the
files and programs legally available to me.

WARNING: You download and use these files entirely at your own risk!

I release this under a Creative Commons Attribution 3.0.
  http://creativecommons.org/licenses/by/3.0/
