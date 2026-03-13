extends CharacterBody2D
class_name Jugador

@export var walk_speed : int = 80
@export var run_speed : int = 120
@export var roll_speed : int = 150
@export var roll_duration : float = 0.4

var direction : Vector2

var is_rolling : bool = false
#Esto se deberia separar vvv
var is_attacking : bool = false
var can_attack : bool = true

func _physics_process(delta):
	direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	velocity = direction * walk_speed
	
	
	move_and_slide()



func _unhandled_input(event):
	#Save for later
	#if event.is_action_pressed("interact"):
		#if npc_cercano and not is_rolling and not is_attacking:
			#print("🎯 Interactuando con:", npc_cercano.name)
			#if npc_cercano.has_method("interact"):
				#npc_cercano.interact()
				#get_viewport().set_input_as_handled()

	if event.is_action_pressed("roll"):
		if not is_rolling and not is_attacking:
			iniciar_rodar()

	if event.is_action_pressed("attack"):
		if can_attack and not is_attacking and not is_rolling:
			atacar()


func iniciar_rodar() -> void:
	print("roll")
	pass


func atacar() -> void:
	print("Atacar")
	pass
