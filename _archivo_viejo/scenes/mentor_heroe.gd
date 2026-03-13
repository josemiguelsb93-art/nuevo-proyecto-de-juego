extends CharacterBody2D
 
# ════════════════════════════════════════
#           MENTOR HÉROE
# ════════════════════════════════════════
 
@export var npc_nombre := "MENTOR"
@export_multiline var dialogo := "Joven, no recuerdo haberte visto antes por esta zona. ¿Eres nuevo, verdad? Aunque me recuerdas a alguien...\n\nSi necesitas algo no dudes en preguntar. Solo te diré que tengas cuidado con las compañías que haces, hay mucha carroña por estos lugares, no te fíes de nadie.\n\nSigue tu instinto y no te desvíes del camino correcto."
 
@onready var anim := $AnimationPlayer
 
func _ready():
	add_to_group("interactable")
 
	if anim and anim.has_animation("idle"):
		anim.play("idle")
 
	if not Global.retratos.has("mentor_heroe"):
		Global.retratos["mentor_heroe"] = load("res://RETRATOS/Mentorheroe_retrato.png")
 
	print("✅ Mentor Héroe listo")
 
func interact():
	print("🎯 Interactuando con:", npc_nombre)
	var dialogo_ui = get_tree().get_first_node_in_group("dialogo_ui")
	if dialogo_ui:
		dialogo_ui.mostrar_eleccion(self)
	else:
		print("⚠️ No se encontró dialogo_ui")
 
func interact_hablar():
	print("💬 Hablando con:", npc_nombre)
	var dialogo_ui = get_tree().get_first_node_in_group("dialogo_ui")
	if dialogo_ui:
		dialogo_ui.mostrar_dialogo(npc_nombre, dialogo, Global.retratos["mentor_heroe"])
 
func interact_robar():
	print("🗡️ Intentando robar al mentor héroe")
	var dialogo_ui = get_tree().get_first_node_in_group("dialogo_ui")
	if dialogo_ui:
		dialogo_ui.iniciar_minijuego_robo(self)
 
func interact_negociar():
	print("💰 Negociando con mentor héroe")
	# Pendiente de implementar
 
func robo_exitoso():
	Global.añadir_bronce(15)
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador and jugador.has_method("actualizar_dinero"):
		jugador.actualizar_dinero()
	Global.añadir_reputacion_ladron(5)
	print("✅ Robo exitoso al mentor | +15 bronce | +5 reputación ladrón")
 
func robo_fallido():
	print("😡 Robo fallido - Mentor héroe enfadado")
	Global.añadir_reputacion_heroe(-10)
	print("⚔️ -10 reputación héroe")
