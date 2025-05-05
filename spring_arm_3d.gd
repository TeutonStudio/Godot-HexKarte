extends SpringArm3D

@export var hex_karte: HexKarte3D  # Referenz zur HexKarte3D für Welt- und Bibliotheksdaten
@export_group("Kamera-Einstellungen")
@export var move_speed: float = 0.01  # Geschwindigkeit der Verschiebung pro Pixel Mausbewegung
@export var rotation_speed: float = 0.002  # Rotationsgeschwindigkeit pro Pixel Mausbewegung
@export var max_pitch_winkel: float = 80  # Maximaler Neigungswinkel (Pitch) in Radianten
@export var min_pitch_winkel: float = 20  # Minimaler Neigungswinkel (Pitch) in Radianten

var _last_mouse_pos: Vector2 = Vector2.ZERO
var _is_capturing: bool = false
var _selected_hex: Vector2i = Vector2i.ZERO  # Speichert das aktuell ausgewählte Hex
var _has_selected_hex: bool = false  # Flag, ob ein Hex ausgewählt ist

func _ready() -> void:
	# Stelle sicher, dass der SpringArm3D die Kamera korrekt steuert
	set_process_input(true)
	_last_mouse_pos = get_viewport().get_mouse_position()
	if not hex_karte:
		push_error("HexKarte3D nicht zugewiesen!")
	if not get_node_or_null("Camera3D"):
		push_error("SpringArm3D benötigt eine Camera3D als Kind!")

func _input(event: InputEvent) -> void:
	# Erfasse Mausbewegung, wenn "bewegen" oder "rotieren" aktiv ist
	if event is InputEventMouseMotion and _is_capturing:
		var mouse_delta: Vector2 = event.relative
		if Input.is_action_pressed("bewegen"):
			# Verschiebe entlang X-Z-Ebene basierend auf Mausbewegung
			var move_vector := Vector3(-mouse_delta.x, 0, -mouse_delta.y) * move_speed
			# Transformiere die Bewegung in die Kamera-Richtung (ohne Y-Rotation)
			var camera_basis := global_transform.basis
			var move_vector_world := camera_basis * move_vector
			move_vector_world.y = 0  # Bleibe auf der X-Z-Ebene
			global_position += move_vector_world
		if Input.is_action_pressed("rotieren"):
			# Rotiere basierend auf Mausbewegung
			var yaw := -mouse_delta.x * rotation_speed
			var pitch := -mouse_delta.y * rotation_speed
			# Wende Yaw (Rotation um Y-Achse) an
			rotate_y(-yaw)
			# Wende Pitch (Rotation um lokale X-Achse) an und begrenze ihn
			var current_pitch := rotation.x
			var new_pitch = clamp(current_pitch - pitch, deg_to_rad(-max_pitch_winkel), deg_to_rad(-min_pitch_winkel))
			rotation.x = new_pitch

func _process(_delta: float) -> void:
	# Prüfe, ob "bewegen" oder "rotieren" gedrückt ist, um die Maus zu erfassen
	var is_moving := Input.is_action_pressed("bewegen")
	var is_rotating := Input.is_action_pressed("rotieren")
	
	if Input.is_action_just_pressed("näher"):
		self.spring_length = max(self.spring_length - 1, 0)  # Verhindere negative Länge
	if Input.is_action_just_pressed("ferner"):
		self.spring_length += 1
	
	if Input.is_action_just_pressed("ausgewählt"):
		if not hex_karte or not hex_karte.data or not hex_karte.hex_bibliothek or not get_node_or_null("Camera3D"):
			push_error("Kann Hex nicht auswählen: HexKarte3D, HexBibliothek oder Camera3D fehlt!")
			return
		_suche_klick_hex()
	
	# Zeichne DebugDraw3D für das ausgewählte Hex
	if _has_selected_hex and hex_karte and hex_karte.data and hex_karte.hex_bibliothek:
		var hex = hex_karte.data.erhalte_hex_nach_axial_global(_selected_hex)
		var höhe: int = hex.höhe
		var pos_euler := HexSys.erhalte_euler_nach_axial_mit_vektor(_selected_hex, höhe*1.2, hex_karte.hex_bibliothek.Hexagon_größe)
		#var draw_pos := pos_euler * hex_karte.hex_bibliothek.Hexagon_größe + Vector3.UP * 1.5
		DebugDraw3D.draw_text(pos_euler, "Selected Hex: " + str(_selected_hex), 48, Color.RED, 0)
	
	if (is_moving or is_rotating) and not _is_capturing:
		_is_capturing = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif not (is_moving or is_rotating) and _is_capturing:
		_is_capturing = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_last_mouse_pos = get_viewport().get_mouse_position()

#const euler_nach_ebene := Basis(Vector3.RIGHT,Vector3.ZERO,Vector3.BACK)
func _suche_klick_hex() -> void:
	var welt := hex_karte.data
	var hexagon_größe := hex_karte.hex_bibliothek.Hexagon_größe
	# Hole die Kamera und die Mausposition
	var camera: Camera3D = get_node("Camera3D")
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
	# Berechne den Ray von der Kamera durch die Mausposition
	var from := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	
	# Prüfe, ob der Ray fast parallel zur x-z-Ebene ist
	if abs(dir.y) < 0.001:
		push_warning("Ray ist fast parallel zur x-z-Ebene, kann keine Hexfelder treffen!")
		_has_selected_hex = false
		return
	
	# Schrittweise entlang des Rays suchen
	var step_size: float = hexagon_größe / 7.0  # Schrittgröße kleiner als Hexagon_größe
	var max_steps: int = 1000  # Maximale Anzahl von Schritten, um Endlosschleifen zu vermeiden
	var step: int = 0
	var hexes: Array[Vector2i]
	var ray := from
	
	# Iteriere entlang des Rays, solange er über y=0 ist und die maximale Schrittzahl nicht erreicht ist
	while ray.y >= 0 and step < max_steps:
		# Berechne Kubialkoordinaten basierend auf der X-Z-Position
		var hex_pos_axial := HexSys.erhalte_axial_nach_euler_mit_vektor(ray, hexagon_größe)
		if not hexes.has(hex_pos_axial):
			hexes.append(hex_pos_axial)
		ray += dir * step_size
		step += 1
	
	# Prüfe, ob Hexfelder gefunden wurden
	if hexes.is_empty():
		_has_selected_hex = false
		push_warning("Keine Hexfelder entlang des Rays gefunden!")
		return
	
	# Prüfe jedes Hexfeld
	var found_hex: bool = false
	for hex_pos_axial in hexes:
		# Hole die Höhe des Hexfelds
		if not welt.data.has(hex_pos_axial):
			continue  # Hexfeld existiert nicht in der Welt
		var hex := welt.erhalte_hex_nach_axial_global(hex_pos_axial)
		var hex_höhe := hex.höhe
		
		# Berechne die Position des Rays in der Ebene y = hex_höhe / 10
		var t := (hex_höhe / 10.0 - from.y) / dir.y
		if t < 0:
			continue  # Das Hexfeld liegt hinter dem Ursprung des Rays, ignorieren
		var ray_pos := from + t * dir
		
		# Berechne die Position des Hexfelds in Weltkoordinaten
		var hex_pos_euler := HexSys.erhalte_euler_nach_axial_mit_vektor(hex_pos_axial, hex_höhe)
		# Berechne den Abstand in der x-z-Ebene
		var hex_pos_scaled := hexagon_größe * hex_pos_euler
		var hex_klick_abstand := Vector2(ray_pos.x - hex_pos_scaled.x, ray_pos.z - hex_pos_scaled.z).length()
		
		if hex_klick_abstand < hexagon_größe * 0.866:  # 0.866 = sqrt(3)/2, Radius eines Hexagons
			_selected_hex = hex_pos_axial
			_has_selected_hex = true
			found_hex = true
			print([hex_pos_axial, hex_klick_abstand])
			break  # Erstes gefundenes Hexfeld akzeptieren
	
	if not found_hex:
		_has_selected_hex = false
		push_warning("Kein Hexfeld getroffen (Abstand zu groß)!")
