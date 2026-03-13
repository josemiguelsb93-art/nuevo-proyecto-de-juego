extends CharacterBody2D

# ════════════════════════════════════════
#           GOBLIN NPC
# ════════════════════════════════════════

@onready var anim := $AnimationPlayer

const DIALOGO := "Malditos humanos, se creen que por ser un goblin soy un ladrón. Se equivocan, solo robo por las noches, en el tardecer y en el amanecer.\n\nY puede que en mi tiempo libre robe alguna moneda de bronce, pero ¿Qué es una moneda de bronce? No tiene valor. ¿Tendré que vivir de algo, no?\n\nSon muy quejicas estos humanos."

func _ready():
	add_to_group("interactable")
	
	if anim and anim.has_animation("idle"):
		anim.play("idle")
	
	print("👺 Goblin listo")

func interact():
	print("👺 Goblin interactuado")
	var dialogo_ui = get_tree().get_first_node_in_group("dialogo_ui")
	if dialogo_ui:
		dialogo_ui.mostrar_dialogo("Goblin", DIALOGO, Global.retratos["goblin"])
	else:
		print("⚠️ No se encontró dialogo_ui en la escena")
