# FSG FS22 Dedi Companion

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) ![GitHub release (latest by date)](https://img.shields.io/github/v/release/FSGModding/FS22_Dedi_Companion) ![GitHub Release Date](https://img.shields.io/github/release-date/FSGModding/FS22_Dedi_Companion) ![GitHub all releases](https://img.shields.io/github/downloads/FSGModding/FS22_Dedi_Companion/total)


FS22 Multiplayer Dedicated Server Companion saves all chat data to the current savegame and gives more control over dedicated servers.

This is a mod file for [Farming-Simulator 22](https://www.farming-simulator.com/) dedicated servers and clients to expand features for dedicated servers.  

Note: This is still a work in progress mod.  Not all features listed below are currently active and working as they should.

__Features__
- [Chat Logger](#chat-logger) - Logs player chats and saves them to active savegame as ChatLogger.xml
- [Chat Notifications](#chat-notifications) - Server will respond and post updates in in-game chat window.
- [Auto Admin](#auto-admin) - Admins can set to have them set as admin every time they join server in future.
- [Chat Commands](#chat-commands) - Change settings with chat commands.
- [Expand Link XML](#expand-link-xml) - Expand data output in server's Link XML API.

## Chat Logger
- Logs player chats and saves them to active savegame and in modSettings folder as ChatLogger.xml

Chat Logger listens for player chats and collects that data to save in an xml format that can easily be extracted.  

```xml
<chatLogger>
    <chat sender="Greg" msg="Hi Everyone!" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 13:27:53"/>
    <chat sender="Bill" msg="Hey Greg!" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 12:55:24"/>
    <chat sender="Jeff" msg="Howdy goes it?" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 12:55:24"/>
</chatLogger>
```

## Chat Notifications
- Server will respond and post updates in in-game chat window.

Server listens for the following chat text as set in the lang files: 

```xml
<text name="chat_greetingTrigger01"     text="hi" />
<text name="chat_greetingTrigger02"     text="hello" />
<text name="chat_greetingTrigger03"     text="hey" />
<text name="chat_greetingTrigger04"     text="howdy" />
<text name="chat_greetingTrigger05"     text="sup" />
```

Server will respond with the following:

```xml
<text name="chat_greeting01"            text="Hey %s!" />
<text name="chat_greeting02"            text="Hi there %s!" />
<text name="chat_greeting03"            text="Hello %s!" />
<text name="chat_greeting04"            text="Good day %s!" />
<text name="chat_greeting05"            text="Howdy %s!" />
```

Server will notify of the following actions:

Player Becomes Server Admin

> *PlayerName* is now Admin!

Server save game is triggered

> Game Saved Successfully!

## Auto Admin
- Admins can set to have them set as admin every time they join server in future.

Auto Admin will automatically save player data to Admins.xml within the modSettings folder on the server when a player becomes admin.  When player returns to the server, the server will check to see if that player is in the Admins.xml file, and if true, log them in as admin automatically.  

The admin can set the system to forget them with the *#forgetMe* text command, and it will no longer automatically make them admin.  The admin can reenable by typing *#rememberMe* in the text chat.  

## Chat Commands
- Change settings with chat commands.

  - #meAdmin - If user has logged in as admin before, they can use this to make them admin again upon return to server.
  - #meNoAdmin - Removes admin from yourself on current session.
  - #getUsers - Displays all available users on server with ID.
  - #moo - This command prints a text cow because why not.
  - #makeAdmin - Admin can use this command to make another online user an admin.  User ID provided from #getUsers command.
  - #rememberMe - Sets user to auto admin when they log on the server.
  - #forgetMe - Sets user to no longer auto admin when they log on the server.
  - #getFarms - Displays all available farms on server with ID.
  - #makeFM - Add user to farm with user id and farm id.  User ID provided from #getUsers command.  Farm ID provided from #getFarms command.
  - #saveVehicles - Saves locations of all vehicles on the server to a file to be called later with #resetVehicles.

## Expand Link XML
- Expand data output in server's Link XML API.

Currently only admin data from Admins.xml is added to the Link XML.  We do have plans to keep expanding this feature for use with the Farm Sim Game Bot.

## Screenshots
![alt text](http://url/to/img.png)
![alt text](http://url/to/img.png)
![alt text](http://url/to/img.png)
![alt text](http://url/to/img.png)
![alt text](http://url/to/img.png)
![alt text](http://url/to/img.png)
![alt text](http://url/to/img.png)
![alt text](http://url/to/img.png)

## Wanted Features
- MOTH - Message of the day setting to welcome players when they join the server, or on a timer.
- Vehicles locations save and reset ability.  The ability to save where vehicles are parked, then use a command to reset all vehicles to those remembered locations.  Troll cleanup, or put vehicles away when done.
- Vehicle refill - a feature that will auto fill everything on a farm.  Seed, fert, fuel, electric, etc?

## Known Issues
- #meNoAdmin - Remove admin perms.  Does not currently work.  Unable to remove without reconnecting to the server.
- #makeFM - Not complete.  Does not currently work.
- #saveVehicles - Not complete. Does not currently work.