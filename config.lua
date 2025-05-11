Config = {}

-- Set to True to enable debug mode
-- ONLY TURN ON IF YOU HAVE ISSUES
Config.EnableDebugMode = true

-- Link to your discord for Ban/Kick Messages
Config.DiscordLink = 'https://discord.gg/CUX8hVnswZ'

Config.Groups = {
    god = {
        permissions = { "spectate" }, 
        inherits = {'manager', 'admin', 'helper'} 
    },
    admin = {
        permissions = { "ban" }, 
        inherits = { "manager", "helper" } 
    },
    manager = {
        permissions = { "kick", "warn" }, 
        inherits = { "helper" } 
    },
    helper = {
        permissions = { "teleport", "heal", "revive", "reports" }, 
        inherits = {} 
    }
}

-- Set Framework Here  
-- qb = qb-core 
-- qbx = QBox
Config.Framework = 'qb'

-- Set Discord Webhook to the channel you want the admin actions to be logged to (recommended this is a private and restricted channel)
Config.DiscordWebhook = "https://discord.com/api/webhooks/1360063633295675392/s4yWn0IoQYSUIq45016fy85yvuShzvjPd-9FzRm4XQb-_uqLnC11iUNdyswsZUIW9jmh"

--Only set this if you use a supported ban system.
--      What does this mean?
-- Depending on how your server is setup. Bans are handled in different ways. 
-- WaveShield stores bans locally in a json file while QB handles them by using
-- database tables. This will ensure you can view the bans on your server 
-- with the choice of reversing the ban
--------------------------------
-- Note, this currently only affects how you view and delete bans. Working on running bans 
-- through the system chosen.
--------------------------------
-- ws = WaveShield 
-- qb = QBCore 
-- qbx = Qbox
Config.BanProvider = "ws"

