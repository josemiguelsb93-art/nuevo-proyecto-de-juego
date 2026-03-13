extends Area2D

# ════════════════════════════════════════
#           MONEDA DE BRONCE
# ════════════════════════════════════════

@export var valor := 5

func _ready():
	body_entered.connect(_on_body_entered)
	print("✅ Moneda lista en posición:", global_position)
	
	# Animación de aparición
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func _on_body_entered(body):
	print("🔵 Moneda detectó:", body.name)
	if body.is_in_group("player"):
		print("💰 Moneda recogida +", valor, " bronce")
		Global.añadir_bronce(valor)
		
		if body.has_method("actualizar_dinero"):
			body.actualizar_dinero()
		
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
		tween.tween_callback(queue_free)
