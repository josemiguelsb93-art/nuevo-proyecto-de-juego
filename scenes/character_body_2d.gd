extends CharacterBody2D

# ════════════════════════════════════════
#           CONFIGURACIÓN
# ════════════════════════════════════════

@export var walk_speed := 80
@export var run_speed := 120
@export var roll_speed := 150
@export var roll_duration := 0.4

@export var attack_damage := 10
@export var attack_range := 35
@export var attack_cooldown := 0.5
@export var attack_duration := 0.3

@onready var anim := $AnimationPlayer
@onready var area_deteccion := $Area2D
@onready var barra_ui := $CanvasLayer/TextureProgressBar
@onready var barra_hambre := $CanvasLayer/barrahambre
@onready var selector := $CanvasLayer/selector
@onready var slots := $CanvasLayer/panelherramientas
@onready var label_oro := $CanvasLayer/Dinero/label_oro
@onready var label_plata := $CanvasLayer/Dinero/label_plata
@onready var label_bronce := $CanvasLayer/Dinero/label_bronce

var last_direction := Vector2.DOWN
var npc_cercano: Node = null

var is_rolling := false
var roll_direction := Vector2.ZERO
var roll_timer := 0.0

var is_attacking := false
var can_attack := true
var attack_timer := Timer.new()

@export var vida_maxima := 100
var vida := 100
var puede_recibir_daño := true

# ════════════════════════════════════════
#           HAMBRE
# ════════════════════════════════════════
var hambre := 100.0
var hambre_maxima := 100.0
var hambre_timer := 0.0
var hambre_intervalo := 60.0
var hambre_bajada := 5.0
var daño_hambre := 10
var daño_hambre_intervalo := 30.0
var daño_hambre_timer := 0.0

var slot_seleccionado := 0

# ════════════════════════════════════════
#           INICIALIZACIÓN
# ════════════════════════════════════════

func _ready():
	add_to_group("jugador")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	var spawn = get_tree().get_first_node_in_group(Global.spawn_destino)
	if spawn:
		global_position = spawn.global_position
		print("✅ Player en spawn:", Global.spawn_destino)
	else:
		print("⚠️ No encontró spawn:", Global.spawn_destino)

	if area_deteccion:
		area_deteccion.body_entered.connect(_on_area_2d_body_entered)
		area_deteccion.body_exited.connect(_on_area_2d_body_exited)
		print("✅ Area2D conectada")
	else:
		print("⚠️ No se encontró Area2D")

	anim.animation_finished.connect(_on_animation_finished)

	add_child(attack_timer)
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	vida = Global.ps
	vida_maxima = Global.ps_maximo
	barra_ui.max_value = vida_maxima
	barra_ui.value = vida

	barra_hambre.max_value = hambre_maxima
	barra_hambre.value = hambre

	await get_tree().process_frame
	mover_selector()
	actualizar_dinero()

	print("✅ Personaje inicializado")
	print("📋 Animaciones disponibles:", anim.get_animation_list())

# ════════════════════════════════════════
#           INPUT
# ════════════════════════════════════════

func _unhandled_input(event):
	for i in range(1, 7):
		if event.is_action_pressed("slot_" + str(i)):
			slot_seleccionado = i - 1
			mover_selector()
			print("🎒 Slot seleccionado:", i)

	if event.is_action_pressed("ui_accept"):
		Global.añadir_bronce(10)
		actualizar_dinero()
		print("💰 +10 bronce")

	if event.is_action_pressed("interact"):
		if npc_cercano and not is_rolling and not is_attacking:
			print("🎯 Interactuando con:", npc_cercano.name)
			if npc_cercano.has_method("interact"):
				npc_cercano.interact()
				get_viewport().set_input_as_handled()

	if event.is_action_pressed("roll"):
		if not is_rolling and not is_attacking:
			iniciar_rodar()

	if event.is_action_pressed("attack"):
		if can_attack and not is_attacking and not is_rolling:
			atacar()

# ════════════════════════════════════════
#           SELECTOR DE SLOTS
# ════════════════════════════════════════

func mover_selector():
	var posiciones_x = [140.36, 240.0, 340.0, 440.0, 540.0, 640.0]
	if slot_seleccionado < posiciones_x.size():
		selector.position.x = posiciones_x[slot_seleccionado]

# ════════════════════════════════════════
#           SISTEMA DE DINERO
# ════════════════════════════════════════

func actualizar_dinero():
	label_oro.text = str(Global.monedas_oro)
	label_plata.text = str(Global.monedas_plata)
	label_bronce.text = str(Global.monedas_bronce)

# ════════════════════════════════════════
#           MOVIMIENTO
# ════════════════════════════════════════

func _physics_process(delta):
	# Hambre
	hambre_timer += delta
	if hambre_timer >= hambre_intervalo:
		hambre_timer = 0.0
		bajar_hambre()

	# Daño por hambre
	if hambre <= 0:
		daño_hambre_timer += delta
		if daño_hambre_timer >= daño_hambre_intervalo:
			daño_hambre_timer = 0.0
			recibir_daño(daño_hambre)
			print("😰 Muriendo de hambre, -", daño_hambre, " vida")

	var dialogo_ui = get_tree().get_first_node_in_group("dialogo_ui")
	if dialogo_ui and dialogo_ui.dialogo_activo:
		velocity = Vector2.ZERO
		move_and_slide()
		reproducir_idle()
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_rolling:
		procesar_rodar(delta)
		return

	var is_running = Input.is_action_pressed("sprint")
	var current_speed = run_speed if is_running else walk_speed

	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	velocity = direction.normalized() * current_speed
	move_and_slide()
	actualizar_animacion_movimiento(direction, is_running)

# ════════════════════════════════════════
#           HAMBRE
# ════════════════════════════════════════

func bajar_hambre():
	hambre -= hambre_bajada
	hambre = max(hambre, 0.0)
	barra_hambre.value = hambre
	print("🍞 Hambre:", hambre)

func comer(cantidad: float):
	hambre = min(hambre + cantidad, hambre_maxima)
	barra_hambre.value = hambre
	print("🍗 Comido, hambre:", hambre)

func actualizar_animacion_movimiento(direction: Vector2, is_running: bool):
	if direction != Vector2.ZERO:
		last_direction = direction
		var anim_name = ""
		if abs(direction.y) > abs(direction.x):
			if direction.y > 0:
				anim_name = "run_down" if is_running else "down"
			else:
				anim_name = "run_up" if is_running else "up"
		else:
			if direction.x > 0:
				anim_name = "run_right" if is_running else "right"
			else:
				anim_name = "run_left" if is_running else "left"
		if anim.current_animation != anim_name or not anim.is_playing():
			anim.play(anim_name)
	else:
		reproducir_idle()

func reproducir_idle():
	var anim_name = "idle"
	if abs(last_direction.y) > abs(last_direction.x):
		anim_name = "idle" if last_direction.y > 0 else "idle_up"
	else:
		anim_name = "idle_right" if last_direction.x > 0 else "idle_left"
	if anim.current_animation != anim_name:
		anim.play(anim_name)

# ════════════════════════════════════════
#           SISTEMA DE ROLL
# ════════════════════════════════════════

func iniciar_rodar():
	print("🎲 Rodando")
	is_rolling = true
	roll_timer = roll_duration
	roll_direction = last_direction.normalized()
	var anim_name = determinar_animacion_roll()
	if anim.has_animation(anim_name):
		anim.play(anim_name)
	else:
		print("⚠️ No existe:", anim_name)

func determinar_animacion_roll() -> String:
	if abs(last_direction.y) > abs(last_direction.x):
		return "roll_down" if last_direction.y > 0 else "roll_up"
	else:
		return "roll_right" if last_direction.x > 0 else "roll_left"

func procesar_rodar(delta):
	roll_timer -= delta
	velocity = roll_direction * roll_speed
	move_and_slide()
	if roll_timer <= 0:
		finalizar_rodar()

func finalizar_rodar():
	print("✅ Roll finalizado")
	is_rolling = false
	roll_timer = 0.0
	velocity = Vector2.ZERO

# ════════════════════════════════════════
#           SISTEMA DE ATAQUE
# ════════════════════════════════════════

func atacar():
	print("⚔️ ATAQUE")
	is_attacking = true
	can_attack = false
	var anim_name = determinar_animacion_ataque()
	if anim.has_animation(anim_name):
		anim.play(anim_name)
	else:
		placeholder_ataque()
	detectar_enemigos()
	attack_timer.start(attack_cooldown)
	await get_tree().create_timer(attack_duration).timeout
	is_attacking = false

func determinar_animacion_ataque() -> String:
	if abs(last_direction.y) > abs(last_direction.x):
		return "attack_down" if last_direction.y > 0 else "attack_up"
	else:
		return "attack_right" if last_direction.x > 0 else "attack_left"

func placeholder_ataque():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(2.5, 0.2, 0.2), 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.05)
	tween.tween_property(self, "modulate", Color(2.5, 0.2, 0.2), 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	var target_pos = position + (last_direction.normalized() * 10)
	var tween_pos = create_tween()
	tween_pos.tween_property(self, "position", target_pos, 0.1)
	tween_pos.tween_property(self, "position", position, 0.15)

func detectar_enemigos():
	var enemigos = get_tree().get_nodes_in_group("enemigos")
	if enemigos.is_empty():
		return
	var enemigos_golpeados = 0
	for enemigo in enemigos:
		var distancia = global_position.distance_to(enemigo.global_position)
		if distancia <= attack_range:
			var direccion_a_enemigo = (enemigo.global_position - global_position).normalized()
			var dot_product = last_direction.normalized().dot(direccion_a_enemigo)
			if dot_product > 0.5:
				if enemigo.has_method("recibir_daño"):
					enemigo.recibir_daño(attack_damage)
				elif enemigo.has_method("take_damage"):
					enemigo.take_damage(attack_damage)
				enemigos_golpeados += 1
	print("✅ Golpeaste", enemigos_golpeados, "enemigo(s)")

func _on_attack_timer_timeout():
	can_attack = true

# ════════════════════════════════════════
#           HELPERS
# ════════════════════════════════════════

func reproducir_animacion_direccional(prefijo: String):
	var anim_name = prefijo
	if abs(last_direction.y) > abs(last_direction.x):
		anim_name += "_down" if last_direction.y > 0 else "_up"
	else:
		anim_name += "_right" if last_direction.x > 0 else "_left"
	if anim.has_animation(anim_name):
		anim.play(anim_name)

# ════════════════════════════════════════
#           CALLBACKS
# ════════════════════════════════════════

func _on_animation_finished(anim_name: String):
	if anim_name.begins_with("roll_"):
		finalizar_rodar()
	if anim_name.begins_with("attack_"):
		is_attacking = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("interactable"):
		npc_cercano = body
		print("👋 NPC cerca:", body.name)

func _on_area_2d_body_exited(body):
	if body == npc_cercano:
		npc_cercano = null
		print("👋 NPC lejos")

# ════════════════════════════════════════
#           VIDA Y DAÑO
# ════════════════════════════════════════

func recibir_daño(cantidad: int):
	if not puede_recibir_daño:
		return

	vida -= cantidad
	Global.ps = vida
	print("❤️ Player recibe", cantidad, "de daño. Vida:", vida, "/", vida_maxima)
	barra_ui.value = vida

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(2.5, 0.2, 0.2), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	puede_recibir_daño = false
	await get_tree().create_timer(0.8).timeout
	puede_recibir_daño = true

	if vida <= 0:
		morir()

func morir():
	print("💀 Player muere")
	vida = vida_maxima
	Global.ps = vida
	barra_ui.value = vida
	var spawn = get_tree().get_first_node_in_group(Global.spawn_destino)
	if spawn:
		global_position = spawn.global_position
