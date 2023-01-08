# FSG FS22 Dedi Companion

FS22 Multiplayer Dedicated Server Companion saves all chat data to the current savegame and gives more control over dedicated servers.

__Features__
- [Chat Logger][Chat Logger] - Logs player chats and saves them to active savegame as ChatLogger.xml
- [Auto Admin][Auto Admin] - Admins can set to have them set as admin every time they join server in future.
- [Chat Commands][Chat Commands] - Change settings with chat commands.
- [Expand Link XML][Expand Link XML] - Expand data output in server's Link XML API.

__Chat Logger__
- Logs player chats and saves them to active savegame and in modSettings folder as ChatLogger.xml

```lua
<chatLogger>
    <chat sender="Greg" msg="Hi Everyone!" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 13:27:53"/>
    <chat sender="Bill" msg="Hey Greg!" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 12:55:24"/>
    <chat sender="Jeff" msg="Howdy goes it?" farmId="1" fromUserId="1tMDuQRobBhJvt2UQfsKUvCKQVHvvMJJ3svvjdfasdS4=" timestamp="2023-01-08 12:55:24"/>
</chatLogger>
```

__Auto Admin__
- Admins can set to have them set as admin every time they join server in future.

__Chat Commands__
- Change settings with chat commands.

__Expand Link XML__
- Expand data output in server's Link XML API.