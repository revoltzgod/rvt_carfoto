local KEY_COLOR = { 255, 0, 255 }
local busy = false

local ANGLES = {
	frente = { -0.72, 0.78 },
	traseira = { 0.72, -0.78 },
	lado = { -1.0, 0.05 },
}

local function notify(color, text)
	if Config.Framework ~= "standalone" and GetResourceState("vrp") == "started" then
		TriggerEvent("Notify", "Foto de carro", text, color, 6000)
	else
		BeginTextCommandThefeedPost("STRING")
		AddTextComponentSubstringPlayerName("Foto de carro: " .. text)
		EndTextCommandThefeedPostTicker(false, false)
	end
end

RegisterNetEvent("rvt_carfoto:notify", notify)

local function loadModel(hash)
	if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then return false end
	RequestModel(hash)
	local timeout = GetGameTimer() + 10000
	while not HasModelLoaded(hash) do
		if GetGameTimer() > timeout then return false end
		Wait(10)
	end
	return true
end

local pending = nil

RegisterNUICallback("keyed", function(data, cb)
	cb("ok")
	if not pending or type(data) ~= "table" or data.spawn ~= pending.spawn then return end
	if data.png then
		TriggerLatentServerEvent("rvt_carfoto:save", 250000, data.spawn, data.png)
	else
		notify("vermelho", ("%s: %s"):format(data.spawn, data.error or "falha ao recortar."))
	end
	pending.done = true
end)

local function restore(cam, vehicle)
	RenderScriptCams(false, false, 0, true, true)
	if cam then DestroyCam(cam, false) end
	if vehicle and DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
	ClearFocus()
	NetworkClearClockTimeOverride()
	ClearOverrideWeather()
	ClearWeatherTypePersist()
end

local function capture(spawn, angleName)
	local hash = GetHashKey(spawn)
	if not loadModel(hash) then
		notify("vermelho", spawn .. ": modelo não encontrado no jogo.")
		return
	end

	local studio = Config.Studio
	local origin = vector3(studio.x, studio.y, studio.z)
	SetFocusPosAndVel(origin.x, origin.y, origin.z, 0.0, 0.0, 0.0)
	-- Céu limpo e sol do começo da tarde, só para quem tira a foto.
	NetworkOverrideClockTime(13, 0, 0)
	SetOverrideWeather("EXTRASUNNY")
	SetWeatherTypeNowPersist("EXTRASUNNY")
	SetRainLevel(0.0)

	local vehicle = CreateVehicle(hash, origin.x, origin.y, origin.z, studio.w, false, false)
	SetModelAsNoLongerNeeded(hash)
	SetEntityCollision(vehicle, false, false)
	FreezeEntityPosition(vehicle, true)
	SetEntityInvincible(vehicle, true)
	SetVehicleDirtLevel(vehicle, 0.0)
	WashDecalsFromVehicle(vehicle, 1.0)
	RemoveDecalsFromVehicle(vehicle)
	SetVehicleEngineOn(vehicle, false, true, true)
	SetVehicleLights(vehicle, 1)

	local min, max = GetModelDimensions(hash)
	local length, width, height = max.y - min.y, max.x - min.x, max.z - min.z
	local size = math.max(length, width * 1.6, height * 2.0)
	local angle = ANGLES[angleName] or ANGLES.frente

	local dist = size * 1.35 + 1.0
	local camPos = GetOffsetFromEntityInWorldCoords(vehicle, dist * angle[1], dist * angle[2], height * 0.55)
	local target = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 0.0, (min.z + max.z) * 0.5 - 0.05)
	local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos.x, camPos.y, camPos.z, 0.0, 0.0, 0.0, Config.Fov or 32.0, false, 2)
	PointCamAtCoord(cam, target.x, target.y, target.z)
	SetCamActive(cam, true)
	RenderScriptCams(true, false, 0, true, true)

	local dir = target - camPos
	local flat = vector3(dir.x, dir.y, 0.0)
	local flatLen = #flat
	flat = flatLen > 0 and flat / flatLen or vector3(0.0, 1.0, 0.0)
	local heading = math.deg(math.atan(flat.y, flat.x)) - 90.0
	local floorZ = origin.z + min.z - 0.02

	-- Luz de estúdio: principal perto da câmera, preenchimento do outro lado, luz de cima e contraluz atrás.
	local light = Config.Lighting or {}
	local reach = size * 1.6 + 4.0
	local side = angle[1] < 0 and 1 or -1
	local lights = {
		{ GetOffsetFromEntityInWorldCoords(vehicle, dist * angle[1] * 0.76, dist * angle[2] * 0.7, height + 1.2), light.key or 3.0 },
		{ GetOffsetFromEntityInWorldCoords(vehicle, dist * 0.7 * side, dist * angle[2] * 0.45, height * 0.8), light.fill or 1.4 },
		{ GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 0.0, height + size * 0.6), light.top or 2.0 },
		{ GetOffsetFromEntityInWorldCoords(vehicle, dist * 0.35 * side, -dist * angle[2], height + 0.6), light.rim or 1.8 },
	}

	local drawing = true
	CreateThread(function()
		while drawing do
			HideHudAndRadarThisFrame()
			for _, l in ipairs(lights) do
				if l[2] > 0 then DrawLightWithRange(l[1].x, l[1].y, l[1].z, 255, 250, 244, reach, l[2]) end
			end
			local wall = origin + flat * (size * 1.2 + 4.0)
			DrawMarker(43, wall.x, wall.y, floorZ - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, heading,
				size * 6.0 + 30.0, 0.5, size * 4.0 + 20.0, KEY_COLOR[1], KEY_COLOR[2], KEY_COLOR[3], 255, false, false, 2, false, nil, nil, false)
			DrawMarker(43, origin.x, origin.y, floorZ - 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, heading,
				size * 6.0 + 30.0, size * 6.0 + 30.0, 0.5, KEY_COLOR[1], KEY_COLOR[2], KEY_COLOR[3], 255, false, false, 2, false, nil, nil, false)
			Wait(0)
		end
	end)

	-- Espera as texturas carregarem e a imagem assentar.
	local streamUntil = GetGameTimer() + 4000
	while not HasCollisionLoadedAroundEntity(vehicle) and GetGameTimer() < streamUntil do Wait(50) end
	Wait(1200)

	pending = { spawn = spawn, done = false }
	local shot = false
	exports["screenshot-basic"]:requestScreenshot({ encoding = "png" }, function(data)
		shot = true
		SendNUIMessage({ action = "key", spawn = spawn, image = data, key = KEY_COLOR, width = Config.OutputWidth or 1600 })
	end)
	local timeout = GetGameTimer() + 15000
	while not shot and GetGameTimer() < timeout do Wait(50) end
	drawing = false
	restore(cam, vehicle)
	if not shot then
		pending = nil
		notify("vermelho", spawn .. ": o screenshot não respondeu.")
		return
	end
	timeout = GetGameTimer() + 15000
	while not pending.done and GetGameTimer() < timeout do Wait(50) end
	pending = nil
end

RegisterNetEvent("rvt_carfoto:capture", function(spawns, angleName)
	if busy or type(spawns) ~= "table" then return end
	busy = true
	CreateThread(function()
		for index, spawn in ipairs(spawns) do
			if #spawns > 1 then notify("azul", ("%d/%d: %s"):format(index, #spawns, spawn)) end
			local ok, err = pcall(capture, spawn, angleName)
			if not ok then
				restore()
				notify("vermelho", spawn .. ": falha ao gerar a foto.")
				print("[rvt_carfoto] " .. tostring(err))
			end
			Wait(300)
		end
		busy = false
	end)
end)
