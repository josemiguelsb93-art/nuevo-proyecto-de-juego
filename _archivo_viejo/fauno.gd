extends CharacterBody2D

# ════════════════════════════════════════
#           FAUNO
# ════════════════════════════════════════

@onready var anim := $AnimationPlayer

func _ready():
	add_to_group("interactable")
	anim.play("idle")
	print("✅ FAUNO listo")

func interact():
	print("💬 FAUNO habla")
