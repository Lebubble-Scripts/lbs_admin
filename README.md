# lbs_admin_react

A basic guide to install the lbs_admin_react resource via Keymaster.

## Installation

1. Place the lbs_admin_react folder into your resources directory:
    ```
    /c:/txData/QBCoreFramework_F454F1.base/resources/
    ```
2. Run `database.sql` in your sql environment
    ```sql
    CREATE TABLE IF NOT EXISTS reports (
     	`reporter_id` INT(11) PRIMARY KEY,
     	`reason` VARCHAR(8000),
     	`timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
     	`status` VARCHAR(50)
     )
    ```
3. Configure the script in config.lua
    ```
    Double check all settings to confirm they align with your server's setup
    ```
4. Update Server Image
    ```
    Upload your server image to the build/assets/images folder.
    
    Ensure the filename is `BackgroundImage.png` otherwise it will not work. 
    ```
5. Ensure lbs_admin_react
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

All players have access to use the `F10` report menu. This menu allows the player to describe the issue they are having. 

Admin will be able to see the reports in their `F3` admin menu. From there, admins can teleport to the player to investigate, or close the ticket. 

All tickets are stored in the database to ensure they survive server restarts. 

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
