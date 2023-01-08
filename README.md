# FSG FS22 Dedi Companion

FS22 Multiplayer Dedicated Server Companion saves all chat data to the current savegame and gives more control over dedicated servers.

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

Auto Admin will automatically save 

## Chat Commands
- Change settings with chat commands.

## Expand Link XML
- Expand data output in server's Link XML API.