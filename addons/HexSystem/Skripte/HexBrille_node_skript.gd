class_name HexBrille3D
extends Node3D

@export var hex_karte: HexKarte
@export var sichtweite: int = 5

var aktueller_chunk := Vector2i(0, 0)
var _gezeichnete_chunk: Dictionary[Vector2i, MeshInstance3D]
var _gezeichnete_natur: Dictionary[Vector2i, MeshInstance3D]
var _chunk_aufgaben: Array[Vector2i] = []  # Warteschlange für Chunk-Aufgaben
var _is_processing: bool = false  # Verhindert Mehrfachverarbeitung

func radius() -> int:
	return hex_karte.erhalte_hexwelt().radius_chunk if hex_karte else 0

func breite() -> int:
	return hex_karte.hex_bibliothek.hexagon_breite if hex_karte else 0

func _ready() -> void:
	HexSys.for_radial(sichtweite, func(r: int, s: int, i: int) -> void:
		var radial_chunk := Vector3i(r, s, i)
		var axial_chunk := HexSys.erhalte_axial_nach_radial_mit_vektor(radial_chunk)
		_queue_chunk_creation(axial_chunk)
	)

func _process(delta: float) -> void:
	var axial_global := NodeHex.erhalte_axial_nach_euler_mit_vektor(self.global_position, breite())
	aktueller_chunk = HexSys.erhalte_axial_chunk_nach_axial_global_mit_vektor(axial_global, radius())
	
	# Bereinige alte Chunks außerhalb der Sichtweite
	_bereinige_alte_chunks()
	
	# Füge neue Chunks hinzu
	HexSys.for_radial(sichtweite, func(r: int, s: int, i: int) -> void:
		var radial_chunk_lokal := Vector3i(r, s, i)
		var axial_chunk_lokal := HexSys.erhalte_axial_nach_radial_mit_vektor(radial_chunk_lokal)
		var axial_chunk := aktueller_chunk + axial_chunk_lokal
		if not _gezeichnete_chunk.has(axial_chunk):
			_queue_chunk_creation(axial_chunk)
		# else: print([axial_global, aktueller_chunk]) # Debugging deaktiviert für Performance
	)
	
	# Verarbeite Warteschlange im Hauptthread
	if not _is_processing and _chunk_aufgaben.size() > 0:
		_verarbeite_chunk_aufgabe()

func _queue_chunk_creation(axial_chunk: Vector2i) -> void:
	if not _chunk_aufgaben.has(axial_chunk):
		_chunk_aufgaben.append(axial_chunk)

func _verarbeite_chunk_aufgabe() -> void:
	if _chunk_aufgaben.is_empty():
		return
	
	_is_processing = true
	var axial_chunk: Vector2i = _chunk_aufgaben.pop_front()
	
	# Starte Hintergrundaufgabe für Mesh-Berechnung
	WorkerThreadPool.add_task(func():
		var radial_chunk := HexSys.erhalte_radial_nach_axial_mit_vektor(axial_chunk)
		var gelände_mesh: Mesh = hex_karte._konstruiere_chunk(radial_chunk)
		var natur_mesh: Mesh = hex_karte._konstruiere_natur(radial_chunk)
		
		# Zurück zum Hauptthread für Szenenbaum-Operationen
		call_deferred("_füge_chunk_instances_hinzufügen", axial_chunk, radial_chunk, gelände_mesh, natur_mesh)
	, true)

func _füge_chunk_instances_hinzufügen(axial_chunk: Vector2i, radial_chunk: Vector3i, gelände_mesh: Mesh, natur_mesh: Mesh) -> void:
	var axial_global := HexSys.erhalte_axial_nach_chunk_radial_mit_vektor(radial_chunk, radius())
	var euler := NodeHex.erhalte_euler_nach_axial_mit_vektor(axial_global, breite())
	var chunk_name := "Chunk " + str(radial_chunk)
	var natur_name := "Natur " + str(radial_chunk)
	
	# Gelände-Instanz
	var gelände_instanz := MeshInstance3D.new()
	hex_karte.add_child(gelände_instanz)
	gelände_instanz.name = chunk_name
	gelände_instanz.position = euler
	gelände_instanz.mesh = gelände_mesh
	gelände_instanz.material_override = hex_karte.hex_bibliothek.material
	gelände_instanz.owner = self.owner if Engine.is_editor_hint() else hex_karte
	_gezeichnete_chunk[axial_chunk] = gelände_instanz
	
	# Natur-Instanz
	var natur_instanz := MeshInstance3D.new()
	hex_karte.add_child(natur_instanz)
	natur_instanz.name = natur_name
	natur_instanz.position = euler
	natur_instanz.mesh = natur_mesh
	natur_instanz.material_override = hex_karte.hex_bibliothek.material
	natur_instanz.owner = self.owner if Engine.is_editor_hint() else hex_karte
	_gezeichnete_natur[axial_chunk] = natur_instanz
	
	_is_processing = false

func _bereinige_alte_chunks() -> void:
	var zu_löschen: Array[Vector2i] = []
	for axial_chunk: Vector2i in _gezeichnete_chunk.keys():
		var radial_chunk_lokal := HexSys.erhalte_radial_nach_axial_von_mit_vektor(aktueller_chunk,axial_chunk)
		var distanz := radial_chunk_lokal.x
		#if distanz > sichtweite: zu_löschen.append(axial_chunk)
	
	for axial_chunk in zu_löschen:
		var gelände_instanz: MeshInstance3D = _gezeichnete_chunk.get(axial_chunk)
		var natur_instanz: MeshInstance3D = _gezeichnete_natur.get(axial_chunk)
		if gelände_instanz:
			gelände_instanz.queue_free()
			_gezeichnete_chunk.erase(axial_chunk)
		if natur_instanz:
			natur_instanz.queue_free()
			_gezeichnete_natur.erase(axial_chunk)
