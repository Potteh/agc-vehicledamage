fx_version 'cerulean'
game 'gta5'

author 'AGC Development'
description 'AGC Realistic Vehicle Damage - Phase 5.5'
version '5.5.0'

lua54 'yes'

shared_script 'config.lua'

client_scripts {
    'client/damage.lua',
    'client/main.lua'
}

server_script 'server/main.lua'
