extends Area2D

# ════════════════════════════════════════
#   PUERTA SALIDA CLOACA - res://scenes/puertasalidacloaca.gd
#   Asignar a: PuertaSalidaCloaca (Area2D) en cloaca.tscn
# ════════════════════════════════════════

# ⚠️ AJUSTA esta ruta si es diferente
@export var escena_destino := "res://scenes/mundo.tscn"

func _ready():
	print("✅ PuertaSalidaCloaca lista y esperando...")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("🚪 Algo tocó PuertaSalida:", body.name)
	if body.name == "CharacterBody2D":  # ← IGUAL que chabola
		print("🚪 Es el personaje! Saliendo de cloaca...")
		salir_de_cloaca()
	else:
		print("🚪 NO es el personaje, es:", body.name)

func salir_de_cloaca():
	Global.spawn_destino = "spawn_salida_cloaca"
	print("🌍 Volviendo al mundo...")
	# USAR call_deferred para evitar error de física
	get_tree().call_deferred("change_scene_to_file", escena_destino)
