fx_version 'adamant'

game 'gta5'

description 'ESX Advanced Banking'

Author 'Human Tree92 | Velociti Entertainment'

version '1.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

ui_page 'html/UI.html'

files {
    'html/UI.html',
    'html/style.css',
	'html/img/BG_White.png'
}

dependencies {
	'es_extended'
}
