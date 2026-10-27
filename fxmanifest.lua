fx_version "cerulean"
game "gta5"
lua54 "yes"

author "RVT Scripts | Revoltz"
contact "Discord: Revoltz"
website "https://rvtscripts.com"
description "Fotografia de veículos com recorte de fundo e exportação em PNG para FiveM."
version "1.0.0"

dependencies { "vrp", "screenshot-basic" }

ui_page "ui/index.html"

shared_script "config.lua"
client_script "client.lua"
server_scripts { "@vrp/lib/Utils.lua", "server.lua" }

files { "ui/index.html" }
