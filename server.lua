local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

local RESOURCE = GetCurrentResourceName()
local PNG_SIGNATURE = "\137PNG\r\n\26\n"
local MAX_BYTES = 8 * 1024 * 1024
local ANGLES = { frente = true, traseira = true, lado = true }
local allowed = {}

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local decodeMap = {}
for i = 1, #B64 do decodeMap[B64:byte(i)] = i - 1 end

local function base64Decode(input)
	input = input:gsub("[^%w%+/=]", "")
	local out, n = {}, 0
	for i = 1, #input, 4 do
		local a, b, c, d = input:byte(i, i + 3)
		local va, vb = decodeMap[a], decodeMap[b]
		if not va or not vb then break end
		local vc, vd = decodeMap[c], decodeMap[d]
		local triple = (va << 18) | (vb << 12) | ((vc or 0) << 6) | (vd or 0)
		n = n + 1
		if vc and vd then
			out[n] = string.char((triple >> 16) & 255, (triple >> 8) & 255, triple & 255)
		elseif vc then
			out[n] = string.char((triple >> 16) & 255, (triple >> 8) & 255)
		else
			out[n] = string.char((triple >> 16) & 255)
		end
	end
	return table.concat(out)
end

local function permitted(source)
	local passport = vRP.Passport(source)
	local p = Config.Permission or {}
	return passport and vRP.HasGroup(passport, p.Group or "Admin", p.Level) and true or false
end

local function notify(source, color, text)
	TriggerClientEvent("Notify", source, "Foto de carro", text, color, 8000)
end

RegisterCommand(Config.Command or "fotocarro", function(source, args)
	if source <= 0 then print("[rvt_carfoto] use no jogo: /" .. (Config.Command or "fotocarro") .. " <spawn>") return end
	if not permitted(source) then return notify(source, "vermelho", "Sem permissão.") end
	local angle = Config.DefaultAngle or "frente"
	local spawns = {}
	for _, arg in ipairs(args) do
		local value = tostring(arg):lower()
		if ANGLES[value] then
			angle = value
		elseif value:match("^[%w_%-]+$") and #value <= 64 and #spawns < 30 then
			spawns[#spawns + 1] = value
		end
	end
	if #spawns == 0 then
		return notify(source, "amarelo", "Uso: /" .. (Config.Command or "fotocarro") .. " spawn [spawn2 ...] [frente|traseira|lado]")
	end
	allowed[source] = allowed[source] or {}
	for _, spawn in ipairs(spawns) do allowed[source][spawn] = true end
	notify(source, "azul", ("Tirando %d foto(s). Fique parado até terminar."):format(#spawns))
	TriggerClientEvent("rvt_carfoto:capture", source, spawns, angle)
end, false)

RegisterNetEvent("rvt_carfoto:save", function(spawn, pngBase64)
	local source = source
	if type(spawn) ~= "string" or not allowed[source] or not allowed[source][spawn] or not permitted(source) then return end
	allowed[source][spawn] = nil
	if type(pngBase64) ~= "string" then return notify(source, "vermelho", spawn .. ": imagem inválida.") end
	local bytes = base64Decode((pngBase64:gsub("^data:image/png;base64,", "")))
	if #bytes == 0 or #bytes > MAX_BYTES or bytes:sub(1, 8) ~= PNG_SIGNATURE then
		return notify(source, "vermelho", spawn .. ": imagem inválida.")
	end
	local folder = (Config.Folder or "fotos"):gsub("[/\\]+$", "")
	local file = folder .. "/" .. spawn .. ".png"
	if not SaveResourceFile(RESOURCE, file, bytes, #bytes) then
		print(("[rvt_carfoto] não foi possível gravar %s"):format(file))
		return notify(source, "vermelho", spawn .. ": não foi possível gravar o arquivo.")
	end
	print(("[rvt_carfoto] foto salva: %s/%s (%d KB) pelo passaporte %s"):format(GetResourcePath(RESOURCE), file, math.floor(#bytes / 1024), tostring(vRP.Passport(source))))
	notify(source, "verde", ("%s salvo em %s/%s"):format(spawn, RESOURCE, file))
end)

AddEventHandler("playerDropped", function() allowed[source] = nil end)
