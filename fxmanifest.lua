fx_version "cerulean"

description "Server/Player/Dev Admin Menu"
author "Lebubble Scripts"
version '0.2.0'

lua54 'yes'

game "gta5"

ui_page 'web/build/index.html'

shared_script  {
  'config.lua',
  '@ox_lib/init.lua',
  'shared/utils.lua'
}

dependencies {
  'ox_lib',
  'oxmysql'
}

client_scripts  {
  'client/client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  "server/**/*"
}

files {
	'web/build/index.html',
	'web/build/**/*',
}