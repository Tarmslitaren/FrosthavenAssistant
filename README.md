# X-haven Assistant

## What is it?
A helper app for the boardgames Gloomhaven, Frosthaven and any derivative.
The aim is to be a good replacement for the Gloomhaven Helper by Esoteric Software that is no longer available.
The focus is on good user experience, and to be like a boardgame component rather than a typical material style app.
That means most of the functionality will be in one single screen, which makes it seem slightly busy at first glance, but is really necessary to minimize need for user input which is a key factor to good UX for a boardgame component.

This is also an opportunity for me to learn the Flutter framework.

## Key features
- Full support for Gloomhaven, Forgotten Circles, Jaws of the Lion and Crimson Scales!
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
- Top bar hosts element infusions. press to infuse, double tap/click to set waning.
- Main list items can be reordered on a long press.
- Monster Ability Cards can be double tapped to open a bigger view of them.
- Monster Ability Cards and Modifier Deck can be tapped/clicked to open card menu with info on discard pile content and such.
- To add a summon, press the big plus on the right of the character widget.
  - On the add summon menu, fist choose the color and nr before pressing your desired summon from the list.
- From any menu: tapping/clicking anywhere outside the menu will close it.
- Sometimes you will want a monster type have different level than the current level, or have different max health value than usual. This can be set from the set level menu accessed from a monster standees stat menu.
- Objectives and Escorts are special characters, representing special rules from scenarios.
- If some special rules or monsters appear from an added section in the scenario/sections booklets, they can be added from the add sections menu.
- If you make a mistake, there is an undo button in the main menu. and if the mistake was to undo, there is also redo ;)
- Networking:
  - To start a server, be sure to be on a wifi network and press 'start host server' from the settings menu
  - To connect to a server in a local network, type in the local ip of the server (usually 192.168.something) and press 'Connect as client'.

##Connection Usage:
#Starting:
- From the settings menu, have one device start a server. Be sure to be on wifi. (a local ip will be shown i.e. 192.168.X.XXX)
- A Port can also be defined if needed. be aware that ports under 1024 are typically blocked.
- Other devices on the same network may connect from the settings menu, by typing in the server's ip, and port.
#Info:
- Be aware, when connecting to a server, the server's game state will overwrite the local state.
- If a client gets out of sync with the server (by disconnecting, or making an update before it gets the latest state from server), the client's state change will be ignored and overwritten by latest state from server to get you back on track. And a message index out of sync will be shown.
- There should be no issue having several users change things simultaneously: the menus will not close when getting an update.
- Local settings are not affected by the game state. It is up to the users to decide on options that affect the game.

## Known Issues:
- Fullscreen switching button only work every other time you press it on macos build
- Some animations will not play, (and some may play when they shouldn't) when receiving updates over wifi.
- TCP connection only works over wifi as far as I can tell, and has not been tested in any other environment.
- when trying to connect without a server on same network, may result in a lot of error messages shown when it tries connecting.
- A device sharing a wifi-hotspot can not connect itself.
- Undo and Redo is currently not supported when connected. sorry. Maybe next release.
- Initiative is secret while not originating from your own device in a network. It will stop being secret if you do modify it yourself.
- Some text alignment issues with small texts on small (mobile) screens.
- Frosthaven Style option is not a 100% accurate. Partly because we don't know yet exactly how the cards should look.
- Condition Animations do not play when connected.
- You can connect devices with different versions, but there will be issues. PLease update all your devices!
- Objectives and Escorts do not update their 'level'/health when monster level is changed. Please set the correct monster level before setting a scenario.


## Roadmap
- Next:
  - full Frosthaven support

## Copyright / License

Gloomhaven and all related properties, images and text are owned by [Cephalofair Games](https://cephalofair.com).

Assets/Data used:

- [Creator Pack by Isaac Childres](https://boardgamegeek.com/thread/1733586/files-creation) CC BY-NC-SA 4.0
- [Frosthaven rulebook sneak peak] (https://drive.google.com/file/d/1sz6nbQNM5wylz2sXJBBSWMLaiBFqqFLl/view)
- [Worldhaven](https://github.com/any2cards/worldhaven)
- some other assets used are public domain licensed.

Source code is licenced under [AGPL](/LICENSE)
