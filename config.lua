Config = {}

-- Set to True to enable debug mode
Config.EnableDebugMode = true

-- Server group required to access admin menu 
Config.AdminGroup = 'admin'

-- Link to your discord for Ban/Kick Messages
Config.DiscordLink = 'https://discord.gg/CUX8hVnswZ'

-- Set Framework Here  
-- qb = qb-core 
-- qbx = QBox
Config.Framework = ''

-- Set Discord Webhook to the channel you want the admin actions to be logged to (recommended this is a private and restricted channel)
Config.DiscordWebhook = ""

--Only set this if you use a supported ban system.
--      What does this mean?
-- Depending on how your server is setup. Bans are handled in different ways. 
-- WaveShield stores bans locally in a json file while QB handles them by using
-- database tables. This will ensure you can view the bans on your server 
-- with the choice of reversing the ban
--------------------------------
-- ws = WaveShield 
-- qb = QBCore 
-- qbx = Qbox
Config.BanProvider = ""

