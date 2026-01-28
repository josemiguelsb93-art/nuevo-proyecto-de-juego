extends CharacterBody2D
@export var speed := 90
@onready var anim := $AnimationPlayer
var last_direction := Vector2.DOWN
func _ready():
	var spawn = get_tree().get_first_node_in_group("spawn")
	if spawn:
		global_position = spawn.global_position
func _physics_process(_delta):
	var direction := Vector2.ZERO
	
	# Obtener dirección del input
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	# Actualizar velocidad y mover
	velocity = direction.normalized() * speed
	move_and_slide()
	
	# Manejar animaciones
	if direction != Vector2.ZERO:  
		last_direction = direction  
		
		if direction.y > 0:  # Moviendo hacia abajo
			
			if not anim.is_playing() or anim.current_animation != "down":
				anim.play("down")
		elif direction.y < 0:  # Moviendo hacia arriba
			
			if not anim.is_playing() or anim.current_animation != "up":
				anim.play("up")
		elif direction.x > 0:  # Moviendo a la derecha
			
			if not anim.is_playing() or anim.current_animation != "right":
				anim.play("right")
		elif direction.x < 0:  # Moviendo a la izquierda
			
			if not anim.is_playing() or anim.current_animation != "left":
				anim.play("left")
	else:  # Si está quieto - mantener idle de la última dirección
		if last_direction.y > 0:
			anim.play("idle")
		elif last_direction.y < 0:
			anim.play("idle_up")
		elif last_direction.x > 0:
			anim.play("idle_right")
		elif last_direction.x < 0:
			anim.play("idle_left")
