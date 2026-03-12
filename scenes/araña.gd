extends CharacterBody2D

# ════════════════════════════════════════
#           ARAÑA - ENEMIGO BÁSICO
# ════════════════════════════════════════

@export var vida := 30
@export var vida_maxima := 30
@export var velocidad := 60
@export var daño := 10
@export var rango_deteccion := 100.0
@export var rango_ataque := 40

# Drop de monedas
@export var monedas_min := 1
@export var monedas_max := 3
const MONEDA_SCENE = preload("res://scenes/moneda.tscn")

# Referencias
@onready var sprite := $Sprite2D
@onready var deteccion := $DeteccionPlayer

# Estado
var player_target: Node = null
var puede_atacar := true
var esta_atacando := false

# Estados de IA
enum Estado {IDLE, SIGUIENDO, ATACANDO, MURIENDO}
var estado_actual := Estado.IDLE

# Barra de vida
var barra_fondo: ColorRect
var barra_vida: ColorRect

func _ready():
	deteccion.body_entered.connect(_on_deteccion_entered)
	deteccion.body_exited.connect(_on_deteccion_exited)
	add_to_group("enemigos")
	crear_barra_vida()
	print("🕷️ Araña lista - Vida:", vida)

func _physics_process(delta):
	match estado_actual:
		Estado.IDLE:
			procesar_idle()
		Estado.SIGUIENDO:
			procesar_seguimiento(delta)
		Estado.ATACANDO:
			procesar_ataque()
		Estado.MURIENDO:
			procesar_muerte()

# ════════════════════════════════════════
#           DETECCIÓN DEL PLAYER
# ════════════════════════════════════════

func _on_deteccion_entered(body):
	if body.name == "CharacterBody2D":
		print("🕷️ Araña detectó al player!")
		player_target = body
		estado_actual = Estado.SIGUIENDO

func _on_deteccion_exited(body):
	if body == player_target:
		print("🕷️ Player fuera de rango")
		player_target = null
		estado_actual = Estado.IDLE

# ════════════════════════════════════════
#           ESTADOS DE IA
# ════════════════════════════════════════

func procesar_idle():
	velocity = Vector2.ZERO
	move_and_slide()

func procesar_seguimiento(_delta):
	if not player_target:
		estado_actual = Estado.IDLE
		return
	
	var distancia = global_position.distance_to(player_target.global_position)
	
	if distancia <= rango_ataque:
		estado_actual = Estado.ATACANDO
	else:
		var direccion = (player_target.global_position - global_position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
		
		if direccion.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func procesar_ataque():
	if not player_target:
		estado_actual = Estado.IDLE
		return
	
	var distancia = global_position.distance_to(player_target.global_position)
	
	if distancia > rango_ataque:
		estado_actual = Estado.SIGUIENDO
	elif puede_atacar:
		atacar_player()

func procesar_muerte():
	velocity = Vector2.ZERO
	move_and_slide()

# ════════════════════════════════════════
#           COMBATE
# ════════════════════════════════════════

func atacar_player():
	print("🕷️ Araña ataca!")
	puede_atacar = false
	esta_atacando = true
	
	if player_target and is_instance_valid(player_target) and player_target.has_method("recibir_daño"):
		player_target.recibir_daño(daño)
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	await tween.finished
	
	await get_tree().create_timer(1.0).timeout
	
	if not is_inside_tree():
		return
	
	puede_atacar = true
	esta_atacando = false
	estado_actual = Estado.SIGUIENDO

func recibir_daño(cantidad: int):
	print("🕷️ Araña recibe", cantidad, "de daño")
	vida -= cantidad
	
	actualizar_barra_vida()
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE * 2, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if vida <= 0:
		morir()
	else:
		if estado_actual == Estado.IDLE:
			estado_actual = Estado.SIGUIENDO

func morir():
	print("🕷️ Araña muere!")
	estado_actual = Estado.MURIENDO
	
	# TEMPORAL - reputación héroe
	Global.añadir_reputacion_heroe(5)
	
	soltar_monedas()
	
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "modulate", Color.TRANSPARENT, 1.0)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 1.0)
	tween.tween_callback(queue_free)

func soltar_monedas():
	var cantidad = randi_range(monedas_min, monedas_max)
	print("💰 Soltando", cantidad, "moneda(s)")
	for i in range(cantidad):
		var moneda = MONEDA_SCENE.instantiate()
		var offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		moneda.global_position = global_position + offset
		get_parent().add_child(moneda)

# ════════════════════════════════════════
#           BARRA DE VIDA
# ════════════════════════════════════════

func crear_barra_vida():
	barra_fondo = ColorRect.new()
	barra_fondo.size = Vector2(30, 4)
	barra_fondo.position = Vector2(-15, -35)
	barra_fondo.color = Color(0.2, 0.2, 0.2)
	barra_fondo.z_index = 10
	add_child(barra_fondo)
	
	barra_vida = ColorRect.new()
	barra_vida.size = Vector2(30, 4)
	barra_vida.position = Vector2(-15, -35)
	barra_vida.color = Color(0.9, 0.1, 0.1)
	barra_vida.z_index = 11
	add_child(barra_vida)

func actualizar_barra_vida():
	if barra_vida:
		barra_vida.size.x = 30.0 * (vida / float(vida_maxima))
