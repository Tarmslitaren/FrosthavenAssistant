## This fork introduces a web server component to X-haven Assistant, in order to support an integration with Tabletop Simulator.

# X-haven Assistant

[![codecov](https://codecov.io/gh/wonderplayer/FrosthavenAssistant/branch/main/graph/badge.svg?token=RMRI5NZCGG)](https://codecov.io/gh/wonderplayer/FrosthavenAssistant)

## Support
For problems and suggestions please file an issue here: https://github.com/Tarmslitaren/FrosthavenAssistant/issues
or contact me directly at royalhasse@gmail.com
Please check out 'known issues' and 'usage' below before submitting, thanks!

## What is it?
A helper app for the boardgames Gloomhaven, Frosthaven and any derivative.
The aim is to be a good replacement for the Gloomhaven Helper by Esoteric Software that is no longer available.
The focus is on good user experience, and to be like a boardgame component rather than a typical material style app.
That means most of the functionality will be in one single screen, which makes it seem slightly busy at first glance, but is really necessary to minimize need for user input which is a key factor to good UX for a boardgame component.

This is also an opportunity for me to learn the Flutter framework.

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


## Usage:
- Press hamburger icon to open main menu.
- Add characters you play with in the add character menu. Class names can be searched.
- Set the current scenario from the Set scenario menu. 
- Alternatively you may add monsters separately from the add monsters menu.
- To set initiative press under the initiative marker, to the right of the class Icon on your character.
- If you prefer a soft numpad input (useful on PC if your keyboard is not close at hand) that can be set from options menu.
- Options menu also has options for scaling the list (you can scale down to fit 2 columns in the list for example) and 
scaling the bottom/top bars (for better visibility on some screens for example).
- Fullscreen option: On android this will hide system navigation buttons. 
  - If you experience glitches (especially when the soft keyboard appears) you may want to turn this off.
- Dark Mode option: in case the bright blue background is too much.
- Press + signs on the Monster stats card to add monster standees.
- Press Draw/next turn button to flip the monster ability cards for the turn.
- Next to Draw button is a turn counter.
- Center on the bottom bar is the level widget, showing the current scenario name, and the current level stats in order:
  - Level, Trap Damage, Hazardous Terrain Damage, XP Gain and Coin Multiplier.
  - Tap/click the level widget to open set level menu.
- To set character level tap/click the character to open stat menu, then tap/click the crown to open set character level menu.
- Character name can be changed from the same menu
- To open stats menu for monster, tap/click the standee.
- On the stats menu you can add conditions and set current health values etc.
- To the right on bottom bar, or above in case screen to narrow is the monster modifier deck.
- In case a scenario has monsters be allied to you, there will appear also a second allies modifier deck above the enemies one.
- Tapping the amd discard pile opens amd menu. In the menu, tapping cards will give some options. you may also long press to reorder if needed.
- Top bar hosts element infusions. press to infuse, long press to set waning.
- Main list items can be reordered on a long press.
- Monster Ability Cards can be double tapped to open a bigger view of them.
- Monster Ability Cards and Modifier Deck can be tapped/clicked to open card menu with info on discard pile content and such.
- In the monster ability deck menu, tapping cards will give some options. you may also long press to reorder if needed.
- To add a summon, press the big plus on the right of the character widget.
  - On the add summon menu, fist choose the color and nr before pressing your desired summon from the list.
- From any menu: tapping/clicking anywhere outside the menu will close it.
- Sometimes you will want a monster type have different level than the current level, or have different max health value than usual. This can be set from the set level menu accessed from a monster standees stat menu.
- Objectives and Escorts are special characters, representing special rules from scenarios.
- If some special rules or monsters appear from an added section in the scenario/sections booklets, they can be added from the add sections menu.
- If you make a mistake, there is an undo button in the main menu. and if the mistake was to undo, there is also redo ;)
- If playing a Frosthaven Scenario,the loot decks have been predefined, and values are pre-calulated based on nr of characters.
- Make sure to select who's turn it is before drawing loot cards, to mark the cards owner.
- To Enhance loot deck tap the loot deck discard pile to enter loot deck menu.
- Networking:
  - To start a server, be sure to be on a wifi network and press 'start host server' from the settings menu
  - To connect to a server in a local network, type in the local ip of the server (usually 192.168.something) and press 'Connect as client'.

## Connection Usage:
# Starting:
- From the settings menu, have one device start a server. Be sure to be on wifi or ethernet (a local ip will be shown i.e. 192.168.X.XXX)
- A Port can also be defined if needed. be aware that ports under 1024 are typically blocked.
- Other devices on the same network may connect from the settings menu, by typing in the server's ip, and port.
# Info:
- Be aware, when connecting to a server, the server's game state will overwrite the local state.
- Mobile devices might cut connections when they are not in foreground. This is especially crucial for Server device: Best to put the server on a windows or mac if available.
- Clients will try to auto reconnect when coming back to foreground if connection was cut.
- If a client gets out of sync with the server (by disconnecting, or making an update before it gets the latest state from server), the client's state change will be ignored and overwritten by latest state from server to get you back on track. And a message index out of sync will be shown.
- There should be no issue having several users change things simultaneously: the menus will not close when getting an update.
- Local settings are not affected by the game state (Except for no standees option). It is up to the users to decide on options that affect the game.

## Known Issues:
- Does not handle character modifier decks.
- Severe flickering on lineage os 16, 17 and 18 on older phones using adreno 300 series graphic chip. 
- Some animations will not play, (and some may play when they shouldn't) when receiving updates over wifi.
- When trying to connect without a server on same network, may result in a lot of error messages shown when it tries connecting.
- A device sharing a wifi-hotspot can not connect itself.
- Initiative is secret while not originating from your own device in a network. It will stop being secret if you do modify it yourself.
- Some text alignment issues with small texts on small (mobile) screens.
- Condition Animations do not play when connected.
- When connected and device goes to background, the connection may be broken. Try to avoid having the server device's app go to background for this reason.
- All Data is added by hand. Please Report any error in a ticket on github.
## Roadmap
- Next:
  - Something special.
  - More minor improvements
- And then:
  - Maybe language support

## Developer Notes

#Calculations:
health and attack may be using a string formula instead of integer.
Calculations handle division (integer only) '/' rounds up, 'd' rounds down
multiplications (* or x means same thing)
addition (- or +)
and parenthesis.
variables: C (nr of characters), L (scenario level)

#Special Rules:
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

#special signs for text layout:
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
 

## Copyright / License

Gloomhaven and all related properties, images and text are owned by [Cephalofair Games](https://cephalofair.com).

Assets/Data used:

- [Creator Pack by Isaac Childres](https://boardgamegeek.com/thread/1733586/files-creation) CC BY-NC-SA 4.0
- [Frosthaven rulebook sneak peak] (https://drive.google.com/file/d/1sz6nbQNM5wylz2sXJBBSWMLaiBFqqFLl/view)
- [Frosthaven spoilers compiled by u/Juar99] (https://drive.google.com/drive/u/0/folders/1sMFWoFehBdkJmzstR0CKNXfzhP-YSphP?sort=13&direction=a)
- [Worldhaven](https://github.com/any2cards/worldhaven)
- some other assets used are public domain licensed.

Source code is licenced under [AGPL](/LICENSE)
