fx_version 'cerulean'
game 'gta5'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

client_scripts {
	'client/*.lua'
}

server_scripts {
    '@ox_core/imports/server.lua',
    '@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}