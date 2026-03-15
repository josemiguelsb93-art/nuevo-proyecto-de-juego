extends CharacterBody2D
class_name Jugador

@export var walk_speed : int = 8000
@export var run_speed : int = 12000
@export var roll_speed : int = 15000
@export var roll_duration : float = 0.4

var roll_timer : float = 0.0

var direction : Vector2
var last_direction : Vector2
var roll_direction : Vector2 = Vector2.ZERO

var is_running : bool = false
var is_rolling : bool = false

#Esto se deberia separar vvv
var is_attacking : bool = false
var can_attack : bool = true

@onready var animation_player = $AnimationPlayer


func _ready():
	
	pass


func _physics_process(delta):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * walk_speed * delta
	
	if is_rolling:
		procesar_rodar(delta)
		return
	
	actualizar_animacion_movimiento(direction, is_running)
	move_and_slide()


func _input(event):
	#Save for later
	#if event.is_action_pressed("interact"):
		#if npc_cercano and not is_rolling and not is_attacking:
			#print("🎯 Interactuando con:", npc_cercano.name)
			#if npc_cercano.has_method("interact"):
				#npc_cercano.interact()
				#get_viewport().set_input_as_handled()

	if event.is_action_pressed("roll"):
		print("roll pressed")
		if not is_rolling and not is_attacking:
			animation_player.stop()
			iniciar_rodar()
			print("roll activated")

	if event.is_action_pressed("attack"):
		if can_attack and not is_attacking and not is_rolling:
			atacar()


func actualizar_animacion_movimiento(direction: Vector2, is_running: bool):
	if direction != Vector2.ZERO:
		last_direction = direction
		var anim_name = ""
		if abs(direction.y) > abs(direction.x):
			if direction.y > 0:
				anim_name = "run_down" if is_running else "walk_down"
			else:
				anim_name = "run_up" if is_running else "walk_up"
		else:
			if direction.x > 0:
				anim_name = "run_right" if is_running else "walk_right"
			else:
				anim_name = "run_left" if is_running else "walk_left"
		if animation_player.current_animation != anim_name or not animation_player.is_playing():
			animation_player.play(anim_name)
	else:
		reproducir_idle()


func reproducir_idle() -> void:
	var anim_name = "idle_down"
	if abs(last_direction.y) > abs(last_direction.x):
		anim_name = "idle_down" if last_direction.y > 0 else "idle_up"
	else:
		anim_name = "idle_right" if last_direction.x > 0 else "idle_left"
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)


func iniciar_rodar() -> void:
	print("🎲 Rodando")
	is_rolling = true
	roll_timer = roll_duration
	roll_direction = last_direction.normalized()
	var anim_name = determinar_animacion_roll()
	if animation_player.has_animation(anim_name) and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
	else:
		print("⚠️ No existe:", anim_name)

#Helper function to return last direction as string
func determinar_animacion_roll() -> String:
	if abs(last_direction.y) > abs(last_direction.x):
		return "roll_down" if last_direction.y > 0 else "roll_up"
	else:
		return "roll_right" if last_direction.x > 0 else "roll_left"

#Helper function to 
func procesar_rodar(delta):
	roll_timer -= delta
	velocity = roll_direction * roll_speed * delta
	move_and_slide()
	if roll_timer <= 0:
		finalizar_rodar()


func finalizar_rodar():
	print("✅ Roll finalizado")
	is_rolling = false
	roll_timer = 0.0
	velocity = Vector2.ZERO


func atacar() -> void:
	print("Atacar")
	pass
