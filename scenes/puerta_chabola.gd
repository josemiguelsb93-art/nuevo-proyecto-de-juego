extends Area2D

func _ready():
	print("PuertaChabola lista y esperando...")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("ENTRADA - Algo toco la puerta: ", body.name)
	if body.name == "CharacterBody2D":  # ← CAMBIADO AQUÍ
		print("ENTRADA - Es el personaje! Cambiando escena...")
		call_deferred("cambiar_escena", "res://scenes/interior_chabola.tscn")
	else:
		print("ENTRADA - NO es el personaje, es: ", body.name)

func cambiar_escena(ruta: String):
	print("ENTRADA - Ejecutando cambio de escena a: ", ruta)
	get_tree().change_scene_to_file(ruta)
