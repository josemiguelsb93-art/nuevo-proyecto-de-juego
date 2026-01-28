extends Area2D

func _ready():
	print("PuertaSalida lista y esperando...")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("SALIDA - Algo toco la puerta: ", body.name)
	if body.name == "CharacterBody2D":  # ← CAMBIADO AQUÍ
		print("SALIDA - Es el personaje! Cambiando escena...")
		call_deferred("cambiar_escena", "res://scenes/mundo.tscn")
	else:
		print("SALIDA - NO es el personaje, es: ", body.name)

func cambiar_escena(ruta: String):
	print("SALIDA - Ejecutando cambio de escena a: ", ruta)
	get_tree().change_scene_to_file(ruta)
