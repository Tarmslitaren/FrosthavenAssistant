
# X-haven Assistant

<img width="776" alt="image" src="https://github.com/alexzhaohong/FrosthavenAssistant/assets/12620082/cfedba27-f69d-4c97-bda3-264973570067">

> Scenario 1 of Gloomhaven with starting classes of X-haven games

## Introduction
**X-Haven Assistant** is a helper app for **Gloomhaven** and its family of board games. The app currently supports **Gloomhaven**, **Frosthaven**, **Jaws of the Lion**, **Forgotten Circles**, **Crimson Scales**, **Trail of Ashes**, and the **Seeker of Xorn** scenarios. 

This is a feature-complete replacement for the defunct Gloomhaven Helper app. This single-screen app streamlines combat and minimizes the need for user input. It complements physical play by tracking monster turns, enforcing scenario-specific rules and spawns, facilitating loot deck construction and enhancement, and much more. Multi-device control is available via local area networking. Please note that campaign progress is not within scope of this combat helper app.

For problems and suggestions please file a [Github Issue](issues) or contact me directly at royalhasse@gmail.com. Please check out [Known Issues](#known-issues) and [Usage](#usage) below before submitting. Thanks!

Written with the Flutter framework. [![codecov](https://codecov.io/gh/tarmslitaren/FrosthavenAssistant/branch/main/graph/badge.svg?token=RMRI5NZCGG)](https://codecov.io/gh/tarmslitaren/FrosthavenAssistant)

## Support me

☕ [Buy me a coffee?](https://ko-fi.com/tarmslitaren)

## Set-up Guide

This will walk you through app installation through your first scenario. 

<img width="575" alt="image" src="https://github.com/alexzhaohong/FrosthavenAssistant/assets/12620082/13657352-1360-4663-b4b1-8e1b81c93110">

 - Installation
	 - Visit [Github Releases](https://github.com/Tarmslitaren/FrosthavenAssistant/releases/latest) and download the appropriate file for your system (Windows, Linux, Mac, Android). The app is also available via the [Google Play store](https://play.google.com/store/apps/details?id=com.tarmslitaren.frosthaven_assistant) and for IOS at the [Apple App Store](https://apps.apple.com/ua/app/x-haven-assistant/id1639494414)
	 - Open the application and set the device near the gaming board
	 - Set *Dark Mode* for a red Gloomhaven theme (Default is the Frosthaven theme)

<img width="575" alt="image" src="https://github.com/alexzhaohong/FrosthavenAssistant/assets/12620082/2089c28b-e51f-46d5-af10-1eeef9804925">

 - Add characters
	 - Click the top-left menu icon (≡), then click *Add Character*
	 -  Choose or type a class name
	 - Add the character's name if you wish
 - Start a scenario
	 - In the sidebar menu (≡) click *Set Scenario*
	 - In the top drop-down menu (⌄) choose the current campaign
	 - Choose the scenario number
	 - Select monster numbers. Monsters auto-populate by player count and difficulty
         - if you now want to change the difficulty, it can be done by tapping the bottom bar center or from the side menu
 - Round structure
	 - Choose two cards and input initiative 
		 - **For tablet/mouse users:** "*Soft numpad for input*" displays virtual numpad for accessibility
		 - If the "*Don't ask for initative*" setting is on, long press and drag and drop banners after drawing monster cards
	 - Reveal monster actions. Click *Draw* in the bottom-left corner
	 - Resolve combat
		 - Click on health to adjust health and status effects
		 - Click element in top-right to set as full. Long-press to set as waning
		 - Monster Ability Modifier Deck (AMD) is provided in the bottom-right
		 - Players track their AMD physically
		 - *Undo* and *Redo* are available in the sidebar menu (≡)
		 - See [Usage](#usage) for further tips and tricks
	 - End the active turn. Click the active banner's icon on the left
	 - End the round. Click *Next Round* in the bottom-left
	 -  Repeat as necessary
 - Complete the scenario
	 - Congratulations!
	 - Look at the bottom bar for successful Experience rewards and the Looted Gold multiplier
 

## Key features
- Full support for Frosthaven, Gloomhaven, Forgotten Circles, Jaws of the Lion and Crimson Scales!
- Characters
- Monster ability decks
- Monster Stat cards
- Calculated monster stats
- Monster standees
- tracks initiative, health, xp, and conditions
- Sort list by initiative
- Element tracking
- Level info
- Add monster per scenario, or separately
- Drag and drop items in list (long-press to start)
- 2 columns if screen is wide enough
- Summons with graphics when available
- Modifier Deck for monsters
- Scenario special rules - Objectives, Escorts, Level Adjustments and Named Monsters.
- Undo and Redo actions
- Settings: Full screen, Separate user scaling for main list and bars, Dark mode, Soft numpad input
- Double tap to see bigger ability cards
- Allies modifier deck
- Expire Conditions option
- Share state between devices over wifi
- Switch card styles between Gloomhaven and Frosthaven
- Loot Deck for Frosthaven


## Usage
- Tap the hamburger icon (≡) for settings
- Add characters with the *Add Character* menu. Class names can be searched
- Set the current scenario with the *Set Scenario* menu 
- You may add monsters from the *Add Monsters* menu
- To set initiative press under the initiative marker, to the right of the class icon
- If you prefer to input via virtual numpad, that can be set from the *Settings* menu
- *Settings* menu has options for scaling banners, header, and footer (eg scale down to fit 2 columns)
- Fullscreen option: On Android this will hide system navigation buttons
  - If you experience glitches (especially when the soft keyboard appears) you may want to turn this off.
- Tap the plus icon (+) on the Monster stats card to add normal or elite monsters
- Tap the Draw button to reveal the monster ability cards
- Next to the Draw button is the turn counter
- Center on the bottom bar shows the current scenario name and the scenario difficulty stats
  - in order: Level, Trap Damage, Hazardous Terrain Damage, XP Gain and Coin Multiplier
- To set character level, tap the character to open stat menu, then tap the crown to set character level. Character name can be changed from the same menu
- To open stats menu for monster, tap the standee image
- On the stats menu you can add conditions and set current health values
- On the bottom-right is the monster Attack Modifier Deck (AMD). (Above if the screen is narrow)
- If a scenario has allied monsters, there will be a second ally modifier deck above the monster AMD
- Tapping the AMD discard pile opens the AMD menu. In the menu, tap cards for more options. you may also long press to reorder if needed
- Top bar hosts element infusions. press to infuse, long press to set waning
- Main list items can be reordered on a long press
- Monster Ability Cards can be double tapped to zoom in
- Monster Ability Cards and Modifier Deck can be tapped to see info on their discard pile
- In the monster ability deck, tapping cards will give some options. Long press to reorder
- To add a summon, press the plus icon (+) on the right of the character widget
  - On the add summon menu, fist choose the color and nr before pressing your desired summon from the list
- From any menu: tapping/clicking anywhere outside the menu will close it
- For custom difficulty, you may want to change a monster's level or change their max health. This can be set by tapping their health and tapping their level crown
- Objectives and Escorts are special characters, representing special rules from scenarios
- If special rules or monsters appear from an added section in the scenario or sections booklets, they can be added from the *Add Section* menu
- If you make a mistake, you can *Undo* in the menu (≡). and if the undo were also a mistake, there is *Redo* ;)
- For Frosthaven, the loot deck values are calulated based on number of characters
- Select the active turn when drawing loot cards to mark the loot's owner. Click on a loot card to change owner
- To Enhance the loot deck, tap the loot discard pile and tap *Enhance*. This is saved for future scenarios
- Networking:
  - To start a server, be sure to be on a wifi network and press 'start host server' from the settings menu
  - To connect to a server in a local network, type in the local ip of the server (usually 192.168.something) and press 'Connect as client'.

## Connection Usage

### Starting
- From the settings menu, have one device start a server. Be sure to be on wifi or ethernet (a local IP will be shown i.e. 192.168.X.XXX)
- A Port can also be defined if needed. Be aware that ports under 1024 are typically blocked. If using a port, make sure to allow port forwarding in your router's settings. Search the internet for this
- Other devices on the same network may connect from the settings menu, by typing in the host server's IP and port. There are two IP numbers, local IP address and public IP address. Try the first one

### Info
- Be aware, when connecting to a server, the server's game state will overwrite the local state
- Mobile devices might cut connections when they are not in foreground. This is especially crucial for Server device: Best to put the server on a windows or mac if available
- Clients will try to auto reconnect when coming back to foreground if connection was cut
- If a client gets out of sync with the server (by disconnecting, or making an update before it gets the latest state from server), the client's state change will be ignored and overwritten by latest state from server to get you back on track. And a message index out of sync will be shown
- There should be no issue having several users change things simultaneously: the menus will not close when getting an update
- Local settings are not affected by the game state (Except for no standees option). It is up to the users to decide on options that affect the game

## Known Issues
- Does not handle character modifier decks
- Severe flickering on lineage os 16, 17 and 18 on older phones using adreno 300 series graphic chip.
- Some animations will not play, (and some may play when they shouldn't) when receiving updates over wifi
- When trying to connect without a server on same network, may result in a lot of error messages shown when it tries connecting
- A device sharing a wifi-hotspot can not connect itself
- Initiative is secret while not originating from your own device in a network. It will stop being secret if you do modify it yourself
- Some text alignment issues with small texts on small screens
- Condition Animations do not play when connected
- When connected and the server device goes to background, the connection may be broken. Try to avoid having the server device's app go to background
- All data is added by hand. Please report any error in a ticket on Github

## Roadmap
- Next:
  - More minor improvements

## Developer Notes for adding game data

#### Calculations
health and attack may be using a string formula instead of integer.
Calculations handle division (integer only) '/' rounds up, 'd' rounds down
multiplications (* or x means same thing)
addition (- or +)
and parenthesis.
variables: C (nr of characters), L (scenario level)

#### Special Rules
Allies: 
 - need a "list" of strings of monsters
Timer: 
 - "startOfRound": optional boolean,
 - "list": integers of the rounds in which to display note. -1 means all rounds
 - "note" - test to display
Objective/Escort:          
 - "name" - name of character
 - "health": - string with the calculation for health with C,L etc.
 - "init": - preset initiative
LevelAdjust:,
 - "name" - string, the monster id
 - "level" - integer, the disparity from regular level (i.e. -1 means one level lower)
Named or otherwise special enemies are not added as special rules, but as their own monster type
Since named monsters are like bosses, they should be added as if they were a boss (i.e only one type instead of normal+elite types)

#### special signs for text layout
 - *small style - only used for longer texts usually.
 - ^mid style - also denotes subline in case last line was main line sized. if you want a line to be a subline you NEED to use this or ^^.
 - ^^mid style squished. makes the line height smaller. can cause alignment issues if text contains icons. best to use this from the second row onwards in a text block.
 - ! to the right of (don't use this. is being used internally. prefer the "[r]"+"[/r]" way.)
 - £ yellow
 - | draw only condition, not the text (for FH style, ignore this. the text is removed automatically)
 - Å invisible text - used for force aligning text, since whitespace by itself gets disregarded. also empty lines, since height of empty string is variable :(
 - '>' disables stat calculation (useful for grant abilities)
 - "[r]"+"[/r]" row "[c]"+"[/c]" column - put items between in row or column.
 - "[s]"+"[/s]" for row in column in row. only used for element use case.
 - ¤ treat as image instead of WidgetSpan - using actual image size (use this for aoe graphics)
 - *......... create divider
 - **......... crete divider with smaller height.
 - [newLine] used to force break line for the sublines (gray boxes: it is ont correct style, but necessary to fit calculated values in some cases.
graphics can be placed at exact position like this:
[{
"gfx": "aoe-line-4-with-black",
"x": 0.73,
"y": 0.36,
"angle": -30.0 //don't use angle unless you have to since the pivot point is not in center.
}]
added before the lines.
FH special considerations:
 - write as if gloomhaven style, the algorithm will move the sublines up when applicable.
 - algorithm will find if is subline by looking for ^ after a mainline.
 - algorithm will find conditional block (dotted edge) by looking for keyword: '%use%'
 - algorithm will make first ^ line after a use-element to be main line when reasonable (e.g. conditions, and added attacks)
 - if you need a subline to be in 2 parts, one to the right and one below, add empty row like this to separate: "[r]","[/r]",
 - don't use ^^ on first line of subline of conditional block as the gray background will be squished as well and look bad.
 - subline text is somewhat larger than the physical counterpart due to the fact it was just too small to see easily on smaller screens.

## ios beta link
for those interested in occationally testing builds befor they show up on app store: https://testflight.apple.com/join/FXRPO9oJ

## Copyright and License

Gloomhaven and all related properties, images and text are owned by [Cephalofair Games](https://cephalofair.com).

Assets and Data used:

- [BoardGameGeek Creator Pack by Isaac Childres](https://boardgamegeek.com/thread/1733586/files-creation) CC BY-NC-SA 4.0
- [Frosthaven rulebook sneak peak, Google Drive](https://drive.google.com/file/d/1sz6nbQNM5wylz2sXJBBSWMLaiBFqqFLl/view)
- [Frosthaven spoilers compiled by u/Juar99, Google Drive](https://drive.google.com/drive/u/0/folders/1sMFWoFehBdkJmzstR0CKNXfzhP-YSphP?sort=13&direction=a)
- [Worldhaven Github](https://github.com/any2cards/worldhaven)
- other assets are licensed in the public domain

Source code is licenced under [AGPL](/LICENSE)
