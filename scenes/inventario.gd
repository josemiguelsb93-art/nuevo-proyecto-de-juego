extends CanvasLayer

# ════════════════════════════════════════
#           INVENTARIO UI
# ════════════════════════════════════════

@onready var selector := $panel/SeccionInventario/SelectorInventario
@onready var seccion_inventario := $panel/SeccionInventario
@onready var seccion_estadisticas := $panel/SeccionEstadisticas
@onready var seccion_habilidades := $panel/SeccionHabilidades
@onready var seccion_misiones := $panel/SeccionMisiones
@onready var seccion_mapa := $panel/SeccionMapa
@onready var seccion_criadero := $panel/SeccionCriadero

# Reputación
@onready var barra_heroe := $panel/SeccionEstadisticas/barra_heroe
@onready var barra_comerciante := $panel/SeccionEstadisticas/barra_comerciante
@onready var barra_ladron := $panel/SeccionEstadisticas/barra_ladron
@onready var porcentaje_heroe := $panel/SeccionEstadisticas/porcentaje_heroe
@onready var porcentaje_comerciante := $panel/SeccionEstadisticas/porcentaje_comerciante
@onready var porcentaje_ladron := $panel/SeccionEstadisticas/porcentaje_ladron

# Estadísticas - valores
@onready var label_ps := $panel/SeccionEstadisticas/LabelValorPS
@onready var label_daño := $panel/SeccionEstadisticas/LabelValorDaño
@onready var label_defensa := $panel/SeccionEstadisticas/LabelValorDefensa
@onready var label_magia := $panel/SeccionEstadisticas/LabelValorMagia
@onready var label_def_magica := $panel/SeccionEstadisticas/LabelValorDefMagica
@onready var label_vel_ataque := $panel/SeccionEstadisticas/LabelValorVelAtaque
@onready var label_velocidad := $panel/SeccionEstadisticas/LabelValorVelocidad
@onready var label_suerte := $panel/SeccionEstadisticas/LabelValorSuerte
@onready var label_carisma := $panel/SeccionEstadisticas/LabelValorCarisma
@onready var label_sigilo := $panel/SeccionEstadisticas/LabelValorSigilo

# Misiones
@onready var icono_mision1 := $"panel/SeccionMisiones/MisionGenerales/Mision 1/icono1"
@onready var icono_mision2 := $"panel/SeccionMisiones/MisionGenerales/Mision 2/icono2"
@onready var label_mision1 := $"panel/SeccionMisiones/MisionGenerales/Mision 1/labelmision1"
@onready var label_mision2 := $"panel/SeccionMisiones/MisionGenerales/Mision 2/labelmision2"

var tex_check := preload("res://interfaz/cuadritocheck.png")
var tex_vacio := preload("res://interfaz/cuadritovacio.png")

# Pestañas
@onready var pestana_inventario := $panel/PestañaInventario
@onready var pestana_estadisticas := $panel/PestañaEstadisticas
@onready var pestana_mision := $panel/PestañaMision

var inventario_abierto := false
var seccion_actual := 0
var total_secciones := 6

enum Zona {INVENTARIO, RAPIDO, EQUIPACION}
var zona_actual := Zona.INVENTARIO

var idx_inventario := 0
var idx_rapido := 0
var idx_equipacion := 0

var posiciones_inventario := [
	Vector2(176.238, 150.099),
	Vector2(204.356, 150.891),
	Vector2(232.079, 151.287),
	Vector2(260.198, 150.891),
	Vector2(287.921, 150.099),
	Vector2(316.436, 150.495),
	Vector2(190.099, 174.257),
	Vector2(218.218, 172.673),
	Vector2(245.148, 174.257),
	Vector2(273.663, 173.465),
	Vector2(301.386, 173.465),
	Vector2(329.109, 174.257),
	Vector2(176.238, 196.832),
	Vector2(204.356, 196.436),
	Vector2(231.287, 196.832),
	Vector2(259.802, 196.832),
	Vector2(287.525, 196.040),
	Vector2(314.851, 196.832),
	Vector2(190.495, 219.802),
	Vector2(217.822, 219.406),
	Vector2(219.406, 219.802),
	Vector2(272.871, 219.010),
	Vector2(300.594, 219.406),
	Vector2(328.713, 219.802),
]

var posiciones_rapido := [
	Vector2(176.238, 116.832),
	Vector2(204.356, 117.228),
	Vector2(232.079, 117.228),
	Vector2(260.198, 116.832),
	Vector2(287.921, 117.228),
	Vector2(316.040, 117.228),
]

var posiciones_equipacion := [
	Vector2(207.129, 55.446),
	Vector2(243.564, 55.049),
	Vector2(185.347, 84.356),
	Vector2(226.139, 83.168),
	Vector2(318.812, 53.861),
	Vector2(337.822, 82.772),
]

var nombres_slots_inventario := ["slot1","slot2","slot3","slot4","slot5","slot6","slot7","slot8","slot9","slot10","slot11","slot12","slot13","slot14","slot15","slot16","slot17","slot18","slot19","slot20","slot21","slot22","slot23","slot24"]
var nombres_slots_rapido := ["SlotRapido1","SlotRapido2","SlotRapido3","SlotRapido4","SlotRapido5","SlotRapido6"]
var nombres_slots_equipacion := ["SlotCabeza","SlotPecho","SlotPiernas","SlotPies","SlotManoDerecha","SlotManoIzquierda"]

const COLUMNAS := 6

func _ready():
	add_to_group("inventario_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	var cursor = load("res://interfaz/cursor_raton.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(0, 0))
	pestana_inventario.pressed.connect(func(): mostrar_seccion(0))
	pestana_estadisticas.pressed.connect(func(): mostrar_seccion(1))
	pestana_mision.pressed.connect(func(): mostrar_seccion(3))
	hide()
	print("✅ Inventario listo")

func _input(event):
	if event.is_action_pressed("inventario"):
		if inventario_abierto:
			cerrar_inventario()
			get_viewport().set_input_as_handled()
		else:
			abrir_inventario()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel"):
		if inventario_abierto:
			cerrar_inventario()
			get_viewport().set_input_as_handled()
		return

	if not inventario_abierto:
		return

	if event.is_action_pressed("seccion_izquierda"):
		mostrar_seccion(max(seccion_actual - 1, 0))
	elif event.is_action_pressed("seccion_derecha"):
		mostrar_seccion(min(seccion_actual + 1, total_secciones - 1))

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		detectar_clic_slot(event.position)

	if event.is_action_pressed("move_up"):
		navegar_arriba()
	elif event.is_action_pressed("move_down"):
		navegar_abajo()
	elif event.is_action_pressed("move_left"):
		navegar_izquierda()
	elif event.is_action_pressed("move_right"):
		navegar_derecha()

# ════════════════════════════════════════
#           REPUTACIÓN
# ════════════════════════════════════════

func actualizar_reputacion():
	barra_heroe.value = Global.reputacion_heroe
	barra_comerciante.value = Global.reputacion_comerciante
	barra_ladron.value = Global.reputacion_ladron
	porcentaje_heroe.text = str(Global.reputacion_heroe) + "%"
	porcentaje_comerciante.text = str(Global.reputacion_comerciante) + "%"
	porcentaje_ladron.text = str(Global.reputacion_ladron) + "%"

# ════════════════════════════════════════
#           ESTADÍSTICAS
# ════════════════════════════════════════

func actualizar_estadisticas():
	label_ps.text = str(Global.ps) + "/" + str(Global.ps_maximo)
	label_daño.text = str(Global.daño)
	label_defensa.text = str(Global.defensa)
	label_magia.text = str(Global.magia)
	label_def_magica.text = str(Global.defensa_magica)
	label_vel_ataque.text = str(Global.velocidad_ataque)
	label_velocidad.text = str(Global.velocidad)
	label_suerte.text = str(Global.suerte)
	label_carisma.text = str(Global.carisma)
	label_sigilo.text = str(Global.sigilo)

# ════════════════════════════════════════
#           MISIONES
# ════════════════════════════════════════

func actualizar_misiones():
	var estado1 = Global.get_estado_mision("consigue_comida")
	label_mision1.text = Global.misiones["consigue_comida"]["nombre"]
	icono_mision1.texture = tex_check if estado1 == "completada" else tex_vacio

	var estado2 = Global.get_estado_mision("rescata_perro")
	label_mision2.text = Global.misiones["rescata_perro"]["nombre"]
	icono_mision2.texture = tex_check if estado2 == "completada" else tex_vacio

# ════════════════════════════════════════
#           DETECCIÓN DE CLIC
# ════════════════════════════════════════

func detectar_clic_slot(pos: Vector2):
	for i in range(nombres_slots_inventario.size()):
		var slot = seccion_inventario.find_child(nombres_slots_inventario[i])
		if slot and slot.get_global_rect().has_point(pos):
			idx_inventario = i
			zona_actual = Zona.INVENTARIO
			mover_selector()
			return

	var barra = seccion_inventario.find_child("BarraRapida")
	if barra:
		for i in range(nombres_slots_rapido.size()):
			var slot = barra.find_child(nombres_slots_rapido[i])
			if slot and slot.get_global_rect().has_point(pos):
				idx_rapido = i
				zona_actual = Zona.RAPIDO
				mover_selector()
				return

	for i in range(nombres_slots_equipacion.size()):
		var slot = seccion_inventario.find_child(nombres_slots_equipacion[i])
		if slot and slot.get_global_rect().has_point(pos):
			idx_equipacion = i
			zona_actual = Zona.EQUIPACION
			mover_selector()
			return

# ════════════════════════════════════════
#           NAVEGACIÓN WASD
# ════════════════════════════════════════

func navegar_arriba():
	match zona_actual:
		Zona.INVENTARIO:
			var fila = idx_inventario / COLUMNAS
			if fila == 0:
				var col = idx_inventario % COLUMNAS
				idx_rapido = min(col, 5)
				zona_actual = Zona.RAPIDO
			else:
				idx_inventario -= COLUMNAS
		Zona.RAPIDO:
			idx_equipacion = 0
			zona_actual = Zona.EQUIPACION
		Zona.EQUIPACION:
			match idx_equipacion:
				2: idx_equipacion = 0
				3: idx_equipacion = 1
				5: idx_equipacion = 4
	mover_selector()

func navegar_abajo():
	match zona_actual:
		Zona.INVENTARIO:
			var fila = idx_inventario / COLUMNAS
			if fila < 3:
				idx_inventario += COLUMNAS
		Zona.RAPIDO:
			idx_inventario = 0
			zona_actual = Zona.INVENTARIO
		Zona.EQUIPACION:
			match idx_equipacion:
				0: idx_equipacion = 2
				1: idx_equipacion = 3
				2:
					idx_rapido = 0
					zona_actual = Zona.RAPIDO
				3:
					idx_rapido = 0
					zona_actual = Zona.RAPIDO
				4: idx_equipacion = 5
				5:
					idx_rapido = 0
					zona_actual = Zona.RAPIDO
	mover_selector()

func navegar_izquierda():
	match zona_actual:
		Zona.INVENTARIO:
			var col = idx_inventario % COLUMNAS
			if col > 0:
				idx_inventario -= 1
		Zona.RAPIDO:
			if idx_rapido > 0:
				idx_rapido -= 1
		Zona.EQUIPACION:
			match idx_equipacion:
				1: idx_equipacion = 0
				3: idx_equipacion = 2
				5: idx_equipacion = 3
	mover_selector()

func navegar_derecha():
	match zona_actual:
		Zona.INVENTARIO:
			var col = idx_inventario % COLUMNAS
			if col < COLUMNAS - 1:
				idx_inventario += 1
		Zona.RAPIDO:
			if idx_rapido < 5:
				idx_rapido += 1
		Zona.EQUIPACION:
			match idx_equipacion:
				0: idx_equipacion = 1
				1: idx_equipacion = 4
				2: idx_equipacion = 3
				3: idx_equipacion = 5
	mover_selector()

# ════════════════════════════════════════
#           SELECTOR
# ════════════════════════════════════════

func mover_selector():
	match zona_actual:
		Zona.INVENTARIO:
			selector.position = posiciones_inventario[idx_inventario]
		Zona.RAPIDO:
			selector.position = posiciones_rapido[idx_rapido]
		Zona.EQUIPACION:
			selector.position = posiciones_equipacion[idx_equipacion]

# ════════════════════════════════════════
#           ABRIR / CERRAR
# ════════════════════════════════════════

func abrir_inventario():
	get_tree().paused = true
	inventario_abierto = true
	zona_actual = Zona.INVENTARIO
	idx_inventario = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	mostrar_seccion(0)
	mover_selector()
	print("📦 Inventario abierto")

func cerrar_inventario():
	get_tree().paused = false
	inventario_abierto = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	hide()
	print("📦 Inventario cerrado")

func mostrar_seccion(indice: int):
	seccion_actual = indice
	seccion_inventario.visible = (indice == 0)
	seccion_estadisticas.visible = (indice == 1)
	seccion_habilidades.visible = (indice == 2)
	seccion_misiones.visible = (indice == 3)
	seccion_mapa.visible = (indice == 4)
	seccion_criadero.visible = (indice == 5)
	if indice == 1:
		actualizar_reputacion()
		actualizar_estadisticas()
	if indice == 3:
		actualizar_misiones()
	print("📑 Sección:", indice)
