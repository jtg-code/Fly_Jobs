fx_version 'bodacious'
game 'gta5'

author 'Fly'
description 'Easy creater to make jobs ingame V2'
version '2.1'

lua54 'on'

shared_script '@es_extended/imports.lua'

client_scripts {
    '@es_extended/locale.lua',
	'config.lua',
    'Notify.lua',
    'locales/*.lua',
	'client/*.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    '@oxmysql/lib/MySQL.lua',
	'config.lua',
    'locales/*.lua',
	'server/*.lua'
}


ui_page "html/index.html"
files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/*.png'
}


escrow_ignore {
    "config.lua",
    "Notify.lua",
    'locales/*.lua',
    "html/*.*"
}