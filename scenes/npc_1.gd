extends CharacterBody2D

# ════════════════════════════════════════
#           NPC 1 - ROLF
# ════════════════════════════════════════

@export var npc_nombre := "ROLF"
@export_multiline var dialogo := "¡Chico! Necesito ayuda. Mi perro Tobi se adentró en las cloacas y no ha vuelto a salir. No sé qué hacer, soy demasiado débil y mayor como para enfrentarme a los peligros de las cloacas.\n\nSi me ayudas te recompensaré. Te daré mi vieja espada para que te sirva de utilidad ahí dentro.\n\nTen cuidado, es demasiado peligroso. Dicen que hay un ser poderoso que ve el futuro... yo creo que son leyendas urbanas, aunque muchos afirman que lo han visto. Lo que sí te puedo asegurar es que ahí dentro hay muchos monstruos y trampas que te van a poner las cosas difíciles.\n\n¿Aceptas mi propuesta?"

@onready var anim := $AnimationPlayer
@onready var exclamacion := $ExclamacionAnimada

var es_enemigo := false
var puede_atacar := true
var ataque_cooldown := 2.0
var velocidad_persecucion := 70

func _ready():
	add_to_group("interactable")

	if anim and anim.has_animation("idle"):
		anim.play("idle")

	actualizar_exclamacion()
	print("✅ NPC listo:", npc_nombre)

func _physics_process(_delta):
	if not es_enemigo:
		return

	var jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		return

	var direccion = (jugador.global_position - global_position).normalized()
	velocity = direccion * velocidad_persecucion
	move_and_slide()

	var distancia = global_position.distance_to(jugador.global_position)
	if distancia < 40 and puede_atacar:
		atacar_jugador(jugador)

func atacar_jugador(jugador: Node):
	puede_atacar = false
	var daño = int(Global.ps_maximo * 0.25)
	print("😡 Rolf ataca al jugador por", daño, "de daño (25% vida máxima)")
	if jugador.has_method("recibir_daño"):
		jugador.recibir_daño(daño)
	await get_tree().create_timer(ataque_cooldown).timeout
	puede_atacar = true

func actualizar_exclamacion():
	var estado = Global.get_estado_mision("rescata_perro")
	if estado == "pendiente" or estado == "activa":
		exclamacion.show()
		exclamacion.play("idle")
	else:
		exclamacion.hide()

func interact():
	if es_enemigo:
		return
	print("🎯 Interactuando con:", npc_nombre)
	var dialogo_ui = get_tree().get_first_node_in_group("dialogo_ui")
	if dialogo_ui:
		dialogo_ui.mostrar_eleccion(self)
	else:
		print("⚠️ No se encontró dialogo_ui en la escena")

func interact_hablar():
	print("💬 Hablando con:", npc_nombre)
	var dialogo_ui = get_tree().get_first_node_in_group("dialogo_ui")
	if dialogo_ui:
		dialogo_ui.mostrar_dialogo(npc_nombre, dialogo, Global.retratos["rolf"])
		if Global.get_estado_mision("rescata_perro") == "pendiente":
			Global.activar_mision("rescata_perro")
			actualizar_exclamacion()

func interact_robar():
	print("🗡️ Intentando robar a:", npc_nombre)
	var dialogo_ui = get_tree().get_first_node_in_group("dialogo_ui")
	if dialogo_ui:
		dialogo_ui.iniciar_minijuego_robo(self)

func interact_negociar():
	print("💰 Negociando con:", npc_nombre)
	# Pendiente de implementar minijuego de negociación

func robo_exitoso():
	Global.añadir_bronce(20)
	# Avisar al jugador para que actualice el HUD
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador and jugador.has_method("actualizar_dinero"):
		jugador.actualizar_dinero()
	Global.añadir_reputacion_ladron(5)
	print("✅ Robo exitoso | +20 bronce | +5 reputación ladrón")

func robo_fallido():
	print("😡 Robo fallido - Rolf se convierte en enemigo")
	es_enemigo = true
	remove_from_group("interactable")
	exclamacion.hide()
	modulate = Color(1.5, 0.3, 0.3)
	print("⚔️ Rolf ahora es enemigo y te persigue")
