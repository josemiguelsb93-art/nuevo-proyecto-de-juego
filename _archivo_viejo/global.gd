extends Node

# ════════════════════════════════════════
#   GLOBAL - res://global.gd
# ════════════════════════════════════════

var spawn_destino := "spawn"

# Sistema de retratos de NPCs
var retratos: Dictionary = {}

# Sistema de dinero
var monedas_bronce := 0
var monedas_plata := 0
var monedas_oro := 0

# Sistema de reputación (0-100)
var reputacion_heroe := 0
var reputacion_comerciante := 0
var reputacion_ladron := 0

# ════════════════════════════════════════
#           ESTADÍSTICAS
# ════════════════════════════════════════
var ps := 100
var ps_maximo := 100
var daño := 10
var defensa := 5
var magia := 0
var defensa_magica := 3
var velocidad_ataque := 1.0
var velocidad := 80
var suerte := 5
var carisma := 5
var sigilo := 5

# ════════════════════════════════════════
#           MISIONES
# ════════════════════════════════════════
# Estados: "pendiente", "activa", "completada"

var misiones: Dictionary = {
	# Misiones Generales
	"consigue_comida": {
		"nombre": "Consigue el 100% de hambre",
		"estado": "activa",
		"tipo": "general"
	},
	"rescata_perro": {
		"nombre": "Rescata al perro de Rolf",
		"estado": "pendiente",
		"tipo": "general"
	},
}

func _ready():
	retratos["goblin"] = load("res://RETRATOS/retrato_goblin.png")
	retratos["rolf"] = load("res://RETRATOS/Rolf_retrato.png")
	print("✅ Global inicializado")

# ════════════════════════════════════════
#           MISIONES
# ════════════════════════════════════════

func activar_mision(id: String):
	if misiones.has(id):
		misiones[id]["estado"] = "activa"
		print("📋 Misión activada:", id)

func completar_mision(id: String):
	if misiones.has(id):
		misiones[id]["estado"] = "completada"
		print("✅ Misión completada:", id)

func get_estado_mision(id: String) -> String:
	if misiones.has(id):
		return misiones[id]["estado"]
	return "pendiente"

# ════════════════════════════════════════
#           DINERO
# ════════════════════════════════════════

func añadir_bronce(cantidad: int):
	monedas_bronce += cantidad
	if monedas_bronce >= 100:
		monedas_plata += int(monedas_bronce / 100)
		monedas_bronce = monedas_bronce % 100
	if monedas_plata >= 100:
		monedas_oro += int(monedas_plata / 100)
		monedas_plata = monedas_plata % 100
	print("💰 Dinero: ", monedas_oro, "oro | ", monedas_plata, "plata | ", monedas_bronce, "bronce")

func gastar_bronce(cantidad: int) -> bool:
	var total_bronce = monedas_bronce + (monedas_plata * 100) + (monedas_oro * 10000)
	if total_bronce < cantidad:
		print("❌ No hay suficiente dinero")
		return false
	monedas_bronce -= cantidad
	while monedas_bronce < 0:
		if monedas_plata > 0:
			monedas_plata -= 1
			monedas_bronce += 100
		elif monedas_oro > 0:
			monedas_oro -= 1
			monedas_plata += 100
	print("💸 Gastado:", cantidad, "bronce")
	return true

# ════════════════════════════════════════
#           REPUTACIÓN
# ════════════════════════════════════════

func añadir_reputacion_heroe(cantidad: int):
	reputacion_heroe = clamp(reputacion_heroe + cantidad, 0, 100)
	print("⚔️ Reputación Héroe:", reputacion_heroe)

func añadir_reputacion_comerciante(cantidad: int):
	reputacion_comerciante = clamp(reputacion_comerciante + cantidad, 0, 100)
	print("💼 Reputación Comerciante:", reputacion_comerciante)

func añadir_reputacion_ladron(cantidad: int):
	reputacion_ladron = clamp(reputacion_ladron + cantidad, 0, 100)
	print("🗡️ Reputación Ladrón:", reputacion_ladron)

# ════════════════════════════════════════
#           ESTADÍSTICAS
# ════════════════════════════════════════

func subir_estadistica(stat: String, cantidad):
	match stat:
		"ps_maximo":
			ps_maximo += cantidad
			ps = min(ps + cantidad, ps_maximo)
		"daño": daño += cantidad
		"defensa": defensa += cantidad
		"magia": magia += cantidad
		"defensa_magica": defensa_magica += cantidad
		"velocidad_ataque": velocidad_ataque += cantidad
		"velocidad": velocidad += cantidad
		"suerte": suerte += cantidad
		"carisma": carisma += cantidad
		"sigilo": sigilo += cantidad
	print("📈 Estadística subida:", stat)
