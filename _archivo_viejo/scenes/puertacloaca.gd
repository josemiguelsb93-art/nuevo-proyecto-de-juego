
extends Area2D

# ════════════════════════════════════════
#   PUERTA CLOACA - res://scenes/puertacloaca.gd
#   Asignar a: PuertaCloaca (Area2D) en mundo.tscn
# ════════════════════════════════════════

# ✅ RUTA CORREGIDA con 
@export var escena_destino := "res://scenes/cloacas.tscn"

func _ready():
	print("✅ PuertaCloaca lista y esperando...")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("🚪 Algo tocó PuertaCloaca:", body.name)
	if body.name == "CharacterBody2D":  # ← IGUAL que chabola
		print("🚪 Es el personaje! Entrando a cloaca...")
		entrar_a_cloaca()
	else:
		print("🚪 NO es el personaje, es:", body.name)

func entrar_a_cloaca():
	Global.spawn_destino = "spawn"
	print("🌍 Cambiando a cloaca...")
	# USAR call_deferred para evitar error de física
	get_tree().call_deferred("change_scene_to_file", escena_destino)
