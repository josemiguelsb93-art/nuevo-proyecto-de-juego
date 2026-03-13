extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		Global.spawn_destino = "spawn_chabola"
		call_deferred("cambiar_escena", "res://scenes/mundo.tscn")

func cambiar_escena(ruta: String):
	get_tree().change_scene_to_file(ruta)
