resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page "html/index.html"

client_scripts {
    'client/animation.lua',
    'client/main.lua',
    'phoneConfig/garages.lua',
    'phoneConfig/apps.lua',
}

server_scripts {
    'server/main.lua',
    'phoneConfig/garages.lua',
    'phoneConfig/apps.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/script.js',
    'html/tooltip.css',
    'html/apps/*.css',

    -- images 
    'html/img/*.png',
    'html/img/*.jpg',
    'html/img/phone-frames/*.png',
}