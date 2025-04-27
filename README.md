# lbs_admin_react

A basic guide to install the lbs_admin_react resource via Keymaster.

## Installation

1. Place the lbs_admin_react folder into your resources directory:
    ```
    /c:/txData/QBCoreFramework_F454F1.base/resources/
    ```
2. Ensure lbs_admin_react
    ```
    ensure lbs_admin_react
    ```


## Usage

`[Commands]`
    
    /adminmenu
    /reportmenu

`[Hotkeys]`

    F3 - Admin Menu
    F10 - Report Menu

## Report System

We are working on adding a comprehensive report system to the admin menu for quickly dealing with issues in your server. Use the /reportmenu command to preview! Keep your eye out for more updates!

## Configuration

Customize the resource by editing ```config.lua```.

```lua
-- Set to True to enable debug mode
Config.EnableDebugMode = false

-- Server group required to access admin menu 
Config.AdminGroup = 'admin'

-- Link to your discord for Ban/Kick Messages
Config.DiscordLink = 'https://discord.gg/CUX8hVnswZ'

-- Set Framework Here | qb = qb-core 
Config.Framework = 'qb'

-- Set Discord Webhook to the channel you want the admin actions to be logged to (recommended this is a private and restricted channel)
Config.DiscordWebhook = ""
```

After updating the configuration, restart lbs_admin_react apply the changes.

## Discord Support

For further assistance, join our Discord server. Chat with community members, ask questions, and get real-time support on any issues you encounter.

**Discord Invite:** [Join our Discord](https://discord.gg/CUX8hVnswZ)
