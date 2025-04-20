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
3. (optional) Place the lbs_admin_react folder into [standalone]
    ```
    /c:/txData/QBCoreFramework_F454F1.base/resources/[standalone]
    ```


## Usage

Once installed, restart your QBCore server. The lbs_admin_react interface should be available according to your project's admin setup.

You can open the menu by using ```/adminmenu``` or hitting ```F3```

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
