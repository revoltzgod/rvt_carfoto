Config = {
	-- "auto", "vrp" ou "standalone". No modo auto, vRP iniciado tem prioridade.
	Framework = "auto",

	Permission = { Group = "Admin", Level = 1, Ace = "rvt_carfoto.use" },

	Command = "fotocarro",

	-- Pasta dentro deste recurso onde as fotos são gravadas como <spawn>.png.
	-- O FXServer só deixa gravar dentro da pasta do recurso.
	Folder = "fotos",

	-- Largura máxima do PNG, em pixels.
	OutputWidth = 1600,

	-- Coordenadas e orientação do estúdio.
	Studio = vector4(-2600.0, -4600.0, 900.0, 0.0),

	-- Intensidade das luzes do estúdio (0 desliga a luz).
	Lighting = { key = 3.0, fill = 1.4, top = 2.0, rim = 1.8 },

	-- Ângulo da câmera: "frente", "traseira" ou "lado".
	DefaultAngle = "frente",

	-- Campo de visão da câmera; menor deixa o carro maior na tela (mais pixels no PNG).
	Fov = 28.0,
}
