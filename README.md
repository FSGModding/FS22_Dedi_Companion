# FSG FS22 Dedi Companion

FS22 Multiplayer Dedicated Server Companion saves all chat data to the current savegame and gives more control over dedicated servers.

__Features__
- [Chat Logger](#chat-logger) - Logs player chats and saves them to active savegame as ChatLogger.xml
- [Auto Admin](#auto-admin) - Admins can set to have them set as admin every time they join server in future.
- [Chat Commands](#chat-commands) - Change settings with chat commands.
- [Expand Link XML](#expand-link-xml)) - Expand data output in server's Link XML API.

## Chat Logger
- Logs player chats and saves them to active savegame and in modSettings folder as ChatLogger.xml

```lua
<chatLogger>
    <chat sender="Greg" msg="Hi Everyone!" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 13:27:53"/>
    <chat sender="Bill" msg="Hey Greg!" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 12:55:24"/>
    <chat sender="Jeff" msg="Howdy goes it?" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 12:55:24"/>
</chatLogger>
```

## Auto Admin
- Admins can set to have them set as admin every time they join server in future.

## Chat Commands
- Change settings with chat commands.

## Expand Link XML__
- Expand data output in server's Link XML API.