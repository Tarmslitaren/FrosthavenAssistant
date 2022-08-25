# Frosthaven Assistant

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
## Key features still missing:
- networking
- expire conditions

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
## Roadmap
- Release 5 plan (next):
  - frosthaven style icons and card layouts
  - expire conditions
  - show special rules toast on start/end of round if special rules for round nr
  - solo scenarios

-Release 5 plan:
  - show scenario special rules (at bottom?)
  - networking

Release 6 plan:
  - full Frosthaven support

## Copyright / License

Gloomhaven and all related properties, images and text are owned by [Cephalofair Games](https://cephalofair.com).

Assets/Data used:

- [Creator Pack by Isaac Childres](https://boardgamegeek.com/thread/1733586/files-creation) CC BY-NC-SA 4.0
- [Frosthaven rulebook sneak peak] (https://drive.google.com/file/d/1sz6nbQNM5wylz2sXJBBSWMLaiBFqqFLl/view)
- [Worldhaven](https://github.com/any2cards/worldhaven)
- some other assets used are public domain licensed.

Source code is licenced under [AGPL](/LICENSE)
