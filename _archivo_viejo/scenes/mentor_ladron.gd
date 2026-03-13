extends CharacterBody2D

# ════════════════════════════════════════
#           MENTOR LADRONA
# ════════════════════════════════════════

@onready var anim := $AnimationPlayer

func _ready():
	add_to_group("interactable")
	anim.play("idle")
	print("✅ Mentor Ladrona lista")

func interact():
	print("💬 Mentor Ladrona habla")
	# Diálogo pendiente de implementar
