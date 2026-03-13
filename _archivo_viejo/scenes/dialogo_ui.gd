extends CanvasLayer

# ════════════════════════════════════════
#           DIÁLOGO UI
# ════════════════════════════════════════

@onready var panel := $PanelDialogo
@onready var nombre_label := $PanelDialogo/NombreLabel
@onready var dialogo_label := $PanelDialogo/DialogoLabel
@onready var indicador_label := $PanelDialogo/IndicadorLabel
@onready var panel_eleccion := $paneleleccion
@onready var selector_eleccion := $paneleleccion/paneleleccionselector
@onready var minijuego_robo := $MinijuegoRobo
@onready var moneda := $MinijuegoRobo/moneda
@onready var zonacierto := $MinijuegoRobo/zonacierto

var retrato: TextureRect = null
var dialogo_activo := false
var paginas: Array[String] = []
var pagina_actual := 0

@export var caracteres_por_pagina := 150

var retratos_espejo := ["ROLF"]

# ════════════════════════════════════════
#           MENÚ DE ELECCIÓN
# ════════════════════════════════════════
var eleccion_activa := false
var opcion_actual := 0
var npc_objetivo: Node = null

var posiciones_selector := [
	Vector2(1.0, -63.0),   # Hablar
	Vector2(1.0, -10.32),  # Robar
	Vector2(1.0, 34.44),   # Negociar
]

# ════════════════════════════════════════
#           MINIJUEGO ROBO
# ════════════════════════════════════════
var minijuego_activo := false
var moneda_idx := 0
var moneda_t := 0.0
var moneda_velocidad := 12.0
var moneda_direccion := 1
var moneda_parada := false
var puede_pulsar := true

var ruta_arco := [
	Vector2(294, 207),
	Vector2(311, 244),
	Vector2(341, 283),
	Vector2(391, 312),
	Vector2(444, 336),
	Vector2(516, 345),
	Vector2(594, 334),
	Vector2(656, 315),
	Vector2(718, 268),
	Vector2(743, 224),
	Vector2(748, 204),
]

var zona_inicio := 4
var zona_fin := 6

func _ready():
	add_to_group("dialogo_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS

	if has_node("PanelDialogo/RetratoPNG"):
		retrato = $PanelDialogo/RetratoPNG
		retrato.hide()
		print("✅ RetratoPNG encontrado")
	else:
		print("⚠️ RetratoPNG no encontrado")

	panel_eleccion.hide()
	minijuego_robo.hide()
	esconder()

func _process(delta):
	if not minijuego_activo or moneda_parada:
		return

	moneda_t += moneda_velocidad * delta

	while moneda_t >= 1.0:
		moneda_t -= 1.0
		moneda_idx += moneda_direccion

		if moneda_idx >= ruta_arco.size() - 1:
			moneda_idx = ruta_arco.size() - 2
			moneda_direccion = -1
		elif moneda_idx < 0:
			moneda_idx = 0
			moneda_direccion = 1

	var idx_siguiente = moneda_idx + moneda_direccion
	idx_siguiente = clamp(idx_siguiente, 0, ruta_arco.size() - 1)
	var pos = ruta_arco[moneda_idx].lerp(ruta_arco[idx_siguiente], moneda_t)
	moneda.position = pos

# ════════════════════════════════════════
#           MINIJUEGO ROBO
# ════════════════════════════════════════

func iniciar_minijuego_robo(npc: Node):
	npc_objetivo = npc
	minijuego_activo = true
	moneda_idx = 0
	moneda_t = 0.0
	moneda_direccion = 1
	moneda_parada = false
	puede_pulsar = true
	moneda.position = ruta_arco[0]
	minijuego_robo.show()
	get_tree().paused = true
	print("🗡️ Minijuego de robo iniciado")

func cerrar_minijuego_robo():
	minijuego_activo = false
	npc_objetivo = null
	moneda_parada = false
	puede_pulsar = true
	minijuego_robo.hide()
	get_tree().paused = false
	print("❌ Minijuego cerrado")

func comprobar_acierto():
	if not puede_pulsar:
		return
	puede_pulsar = false
	moneda_parada = true
	print("🛑 Moneda parada en índice:", moneda_idx)

	await get_tree().create_timer(1.0).timeout

	var npc = npc_objetivo
	var en_zona = moneda_idx >= zona_inicio and moneda_idx <= zona_fin
	if en_zona:
		print("✅ ROBO EXITOSO en índice:", moneda_idx)
		cerrar_minijuego_robo()
		if npc and npc.has_method("robo_exitoso"):
			npc.robo_exitoso()
	else:
		print("❌ ROBO FALLIDO en índice:", moneda_idx)
		cerrar_minijuego_robo()
		if npc and npc.has_method("robo_fallido"):
			npc.robo_fallido()

# ════════════════════════════════════════
#           MENÚ DE ELECCIÓN
# ════════════════════════════════════════

func mostrar_eleccion(npc: Node):
	npc_objetivo = npc
	eleccion_activa = true
	opcion_actual = 0
	selector_eleccion.position = posiciones_selector[0]
	panel_eleccion.show()
	get_tree().paused = true
	print("🎯 Menú de elección abierto")

func cerrar_eleccion():
	eleccion_activa = false
	npc_objetivo = null
	panel_eleccion.hide()
	get_tree().paused = false
	print("❌ Menú de elección cerrado")

func confirmar_eleccion():
	var npc = npc_objetivo
	cerrar_eleccion()
	await get_tree().process_frame
	match opcion_actual:
		0:
			print("💬 Elegido: Hablar")
			if npc and npc.has_method("interact_hablar"):
				npc.interact_hablar()
		1:
			print("🗡️ Elegido: Robar")
			if npc and npc.has_method("interact_robar"):
				npc.interact_robar()
		2:
			print("💰 Elegido: Negociar")
			if npc and npc.has_method("interact_negociar"):
				npc.interact_negociar()

# ════════════════════════════════════════
#           DIÁLOGO
# ════════════════════════════════════════

func mostrar_dialogo(nombre: String, texto: String, imagen: Texture2D = null):
	nombre_label.text = nombre

	if retrato:
		if imagen:
			retrato.texture = imagen
			retrato.show()
			retrato.flip_h = nombre.to_upper() in retratos_espejo
		else:
			retrato.texture = null
			retrato.flip_h = false
			retrato.hide()

	paginas = dividir_texto(texto)
	pagina_actual = 0
	dialogo_activo = true
	get_tree().paused = true
	panel.show()
	mostrar_pagina()

	print("📖 Diálogo iniciado | páginas:", paginas.size())

func dividir_texto(texto: String) -> Array[String]:
	var resultado: Array[String] = []
	var division_manual = texto.split("\n\n")

	for parte in division_manual:
		var restante := parte.strip_edges()
		while restante.length() > 0:
			if restante.length() <= caracteres_por_pagina:
				resultado.append(restante)
				break
			var corte := caracteres_por_pagina
			var sub := restante.substr(0, corte)
			var espacio := sub.rfind(" ")
			if espacio > 0:
				corte = espacio
			resultado.append(restante.substr(0, corte).strip_edges())
			restante = restante.substr(corte).strip_edges()

	print("📚 Total páginas creadas:", resultado.size())
	for i in range(resultado.size()):
		print("📄 Página", i + 1, ":", resultado[i])

	return resultado

func mostrar_pagina():
	dialogo_label.text = paginas[pagina_actual]
	if pagina_actual < paginas.size() - 1:
		indicador_label.text = "▼ Presiona E"
	else:
		indicador_label.text = "✖ Presiona E para cerrar"
	print("📄 Mostrando página", pagina_actual + 1, "/", paginas.size())

func avanzar():
	print("⏩ Avanzando diálogo...")
	if pagina_actual < paginas.size() - 1:
		pagina_actual += 1
		mostrar_pagina()
	else:
		esconder()

func esconder():
	panel.hide()
	if retrato:
		retrato.texture = null
		retrato.flip_h = false
		retrato.hide()
	dialogo_activo = false
	paginas.clear()
	pagina_actual = 0
	get_tree().paused = false
	print("❌ Diálogo cerrado")

# ════════════════════════════════════════
#           INPUT
# ════════════════════════════════════════

func _input(event):
	if minijuego_activo:
		if event.is_action_pressed("interact") and puede_pulsar:
			comprobar_acierto()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel") and puede_pulsar:
			cerrar_minijuego_robo()
			get_viewport().set_input_as_handled()
		return

	if eleccion_activa:
		if event.is_action_pressed("move_up"):
			opcion_actual = max(opcion_actual - 1, 0)
			selector_eleccion.position = posiciones_selector[opcion_actual]
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("move_down"):
			opcion_actual = min(opcion_actual + 1, 2)
			selector_eleccion.position = posiciones_selector[opcion_actual]
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("interact"):
			confirmar_eleccion()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			cerrar_eleccion()
			get_viewport().set_input_as_handled()
		return

	if not dialogo_activo:
		return
	if event.is_action_pressed("interact"):
		print("🔘 E presionada en UI")
		avanzar()
		get_viewport().set_input_as_handled()
