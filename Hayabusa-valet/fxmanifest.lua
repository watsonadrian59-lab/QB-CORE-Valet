-- ################## SCRIPTS BY HAYABUSA ##################
-- ################## SCRIPTS BY HAYABUSA ##################
-- ################## SCRIPTS BY HAYABUSA ##################


fx_version 'cerulean'

game 'gta5'

name 'Hayabusa-valet'

author 'Hayabusa'

description 'Valet system for QBCore'

version '2.1.5'

shared_script {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-menu',
    'qb-input',
    'ox_lib'
}


-- ################## SCRIPTS BY HAYABUSA ##################
-- ################## SCRIPTS BY HAYABUSA ##################
-- ################## SCRIPTS BY HAYABUSA ##################