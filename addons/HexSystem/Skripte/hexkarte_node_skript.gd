@tool
class_name HexKarte
extends NodeHex

## Erzeugt Hexagonale Maschen in Chunkweise MeshInstance3D
signal chunk_verädert(axial_global: Vector2i)

@export_group("Debug")
@export_tool_button("Erzeuge Welt") var gen_data: Callable:
	get: 
		if erzeuger: 
			_data = erzeuger.erzeuge_welt()
			for _data: Dictionary[Vector3i,MeshInstance3D] in [_chunk_data, _natur_data]:
				for jedes: Vector3i in _data: if _data[jedes]: _data[jedes].free()
		return self.notify_property_list_changed
@export_tool_button("Neu vermaschen") var gen_masche: 
	get: 
		if _data: _erzeuge_karte()
		return self.notify_property_list_changed
@export var debug_kubial := false
@export var debug_radial := false
@export var debug := false
@export var debug_pfad_hexes := false
@export var debug_pfad_location := false

@export_group("Weltdaten")
@export var erzeuge_play := false
@export var erzeuge_editor := false
@export var erzeuger: HexWeltErzeuger
@export var hex_bibliothek: HexBibliothek
@export var gebäude_bibliothek: GebäudeBibliothek
@export_storage var _chunk_data: Dictionary[Vector3i, MeshInstance3D]
@export_storage var _natur_data: Dictionary[Vector3i, MeshInstance3D]
#@export_storage var _natur_data: Dictionary[Vector3i, MeshInstance3D]
@export_storage var _data: HexWelt

func erhalte_hexwelt() -> HexWelt: return _data


func _ready() -> void:
	if not hex_bibliothek:
		push_error("HexBibliothek nicht zugewiesen!")
		return
	if not erzeuger.höhenkarte:
		var fall1 := not Engine.is_editor_hint() and erzeuge_play
		var fall2 := Engine.is_editor_hint() and erzeuge_editor
		if fall1 or fall2:
			push_error("Höhenkarte nicht zugewiesen!")
			return
	if not Engine.is_editor_hint():
		if erzeuge_play: _data = erzeuger.erzeuge_welt(); _erzeuge_karte()
	if Engine.is_editor_hint():
		if erzeuge_editor: _data = erzeuger.erzeuge_welt()
#	if not Engine.is_editor_hint(): if _data: _data = data; return

func _erzeuge_karte() -> void: if _data: HexSys.for_radial(_data.radius_welt, 
	func(r: int, s: int, i: int) -> void: add_child(_erzeuge_chunk(r, s, i)) )

func _erzeuge_chunk(radius: int, seite: int, interpoliert: int) -> MeshInstance3D:
	var chunk_pos_radial := Vector3i(radius, seite, interpoliert)
	var chunk_name := "Chunk " + str(chunk_pos_radial)
	var natur_name := "Natur " + str(chunk_pos_radial)
	
	var existing_chunk = _chunk_data.get_or_add(chunk_pos_radial,null)
	#if Engine.is_editor_hint() and existing_chunk:
		#return
	if existing_chunk: existing_chunk.free()
	
	var chunk_pos_axial := HexSys.erhalte_axial_nach_chunk_radial_mit_vektor(chunk_pos_radial, _data.radius_chunk)
	var chunk_pos_euler := NodeHex.erhalte_euler_nach_axial_mit_vektor(chunk_pos_axial, hex_bibliothek.hexagon_breite)
	
	print("Chunk Radial: ", chunk_pos_radial, " Axial: ", chunk_pos_axial, " Euler: ", chunk_pos_euler)
	
	var gelände_instanz := MeshInstance3D.new()
	add_child(gelände_instanz)
	gelände_instanz.name = chunk_name
	gelände_instanz.position = chunk_pos_euler
	gelände_instanz.mesh = _konstruiere_chunk(chunk_pos_radial)
	gelände_instanz.material_override = hex_bibliothek.material
	gelände_instanz.owner = self.owner if Engine.is_editor_hint() else self
	_chunk_data[chunk_pos_radial] = gelände_instanz
	
	var natur_instanz := MeshInstance3D.new()
	natur_instanz.name = natur_name
	natur_instanz.position = chunk_pos_euler
	natur_instanz.mesh = _konstruiere_natur(chunk_pos_radial)
	natur_instanz.material_override = hex_bibliothek.material
	#natur_instanz.owner = self.owner if Engine.is_editor_hint() else self
	_natur_data[chunk_pos_radial] = natur_instanz
	
	return natur_instanz

func _konstruiere_chunk(radial_chunk: Vector3i) -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	HexSys.for_radial(_data.radius_chunk, func(r: int, s: int, i: int) -> void:
		var radial_lokal := Vector3i(r,s,i)
		var axial_global := HexSys.erhalte_axial_global_nach_radialpaar(radial_lokal,radial_chunk,_data.radius_chunk)
		
		if not _data.existiert_hex_nach_axial_global(axial_global): return
	
		var hex := _data.erhalte_hex_nach_axial_global(axial_global)
		#var hex_variante := hex.variante
		var hex_pos_höhe := hex.höhe
		var axial_lokal := HexSys.erhalte_axial_nach_radial_mit_vektor(radial_lokal)
		var euler_lokal := NodeHex.erhalte_euler_nach_axial_mit_vektor(axial_lokal,hex_bibliothek.hexagon_breite,hex_pos_höhe)
		
		var richtungen: Dictionary[HexSys.HEX_RICHTUNG, Hex.VARIANTEN]
		for seite: int in HexSys.HEX_RICHTUNG.values():
			var nachbar_axial_global = axial_global + HexSys.erhalte_axial_richtung(seite)
			if not _data.existiert_hex_nach_axial_global(nachbar_axial_global): return
			
			var nachbar_hex := _data.erhalte_hex_nach_axial_global(nachbar_axial_global)
			var nachbar_pos_höhe = nachbar_hex.höhe
			var kanten_koordinate := hex.erhalte_axial_kante(seite)
			#var seiten_variante := hex.er
			
			richtungen[seite] = _data._KANTEN_data.get(kanten_koordinate,Hex.VARIANTEN.Boden)
			
			var rot_euler_y = NodeHex.erhalte_winkel_nach_richtung(seite)
			var rot_euler := Basis(Vector3.UP, rot_euler_y)
			#var seite_masche: Mesh
			
			if hex_pos_höhe == 0: pass
			else: for idx in int((hex_pos_höhe - nachbar_pos_höhe) / 10 + 1):
				var seite_pos_euler_lokal := euler_lokal - Vector3.UP * idx 
				var seite_trans = Transform3D(rot_euler, seite_pos_euler_lokal)
				
				var art := HexagonMasche.ART.Seite if idx == 0 else HexagonMasche.ART.Untergrund
				var maschen_data := hex_bibliothek.finde_masche(art,richtungen, axial_global)
				#seite_masche = 
				
				if maschen_data: surface_tool.append_from(maschen_data.masche, 0, seite_trans)
				#if maschen_data == null: push_warning(["Keine Masche für ", axial_global])
		
		#var ebene_masche: Mesh 
		#var rotations_idx: int
		
		var relevante := []
		for jedes: HexSys.HEX_RICHTUNG in richtungen.keys(): 
			if richtungen[jedes] != Hex.VARIANTEN.Boden: relevante.append(jedes)
		
		#if hex_pos_höhe == 0:
			#relevante = []; for jedes in richtungen.keys(): 
				#if richtungen[jedes] == -1: relevante.append(jedes)
			#
			#if relevante.size() == 0:
				#ebene_masche = hex_bibliothek.ebene_wasser
			#if relevante.size() == 1: 
				#ebene_masche = hex_bibliothek.küste_3
				#rotations_idx = HexSys.erhalte_erstes(richtungen)+2
			#if relevante.size() == 2:
				#ebene_masche = hex_bibliothek.küste_2
				#rotations_idx = HexSys.erhalte_erstes(richtungen)+2
			#if relevante.size() == 3:
				#ebene_masche = hex_bibliothek.küste_1
				#rotations_idx = HexSys.erhalte_erstes(richtungen)+3
			#if relevante.size() == 4:
				#ebene_masche = hex_bibliothek.küste_0
				#rotations_idx = HexSys.erhalte_erstes(richtungen)+3
			#if richtungen.size() == 5:
				#ebene_masche = hex_bibliothek.küste_3
				#ebene_rotat_y *= richtungen[1]
		#elif relevante.size() == 0:
				#ebene_masche = hex_bibliothek.ebene_gras
		#else: match hex_variante:
			#Hex.VARIANTEN.Boden:
				#ebene_masche = hex_bibliothek.ebene_gras
			#Hex.VARIANTEN.Fluß: for jedes in HexBibliothek.BUCHSTABEN_LISTE:
				#var masche_richtungen = HexBibliothek.erhalte_richtungen_nach_buchstabe(jedes,Hex.VARIANTEN.Fluß)
				#if masche_richtungen: if masche_richtungen.has(richtungen):
					#ebene_masche = hex_bibliothek.get("fluß_"+str(jedes))
					#rotations_idx = masche_richtungen.find(richtungen)+1
			#Hex.VARIANTEN.Weg: for jedes in HexBibliothek.BUCHSTABEN_LISTE:
				#var masche_richtungen = HexBibliothek.erhalte_richtungen_nach_buchstabe(jedes,Hex.VARIANTEN.Weg)
				#if masche_richtungen: if masche_richtungen.has(richtungen):
					#ebene_masche = hex_bibliothek.get("weg_"+str(jedes))
					#rotations_idx = masche_richtungen.find(richtungen)+1
			#Hex.VARIANTEN.Kreuzung: pass
		var maschen_data := hex_bibliothek.finde_masche(HexagonMasche.ART.Ebene,richtungen,axial_global)
		#ebene_masche = 
		
		#var ebene_rotat_y := NodeHex.erhalte_winkel_nach_richtung(rotations_idx)
		if maschen_data: 
			var ebene_rotat := Basis(Vector3.UP,maschen_data.erhalte_rotationswinkel(richtungen))
			var ebene_trans := Transform3D(ebene_rotat, euler_lokal)
			surface_tool.append_from(maschen_data.masche, 0, ebene_trans)
	); return surface_tool.commit()

func _konstruiere_natur(radial_chunk: Vector3i) -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	HexSys.for_radial(_data.radius_chunk, func(r: int, s: int, i: int) -> void:
		var radial_lokal := Vector3i(r,s,i)
		var axial_global := HexSys.erhalte_axial_global_nach_radialpaar(radial_lokal,radial_chunk,_data.radius_chunk)
		
		if not _data.existiert_hex_nach_axial_global(axial_global): return
		
		var hex := _data.erhalte_hex_nach_axial_global(axial_global)
		#var hex_variante := hex.variante
		var hex_pos_höhe := hex.höhe
		var axial_lokal := HexSys.erhalte_axial_nach_radial_mit_vektor(radial_lokal)
		var euler_lokal := NodeHex.erhalte_euler_nach_axial_mit_vektor(axial_lokal,hex_bibliothek.hexagon_breite,hex_pos_höhe)
		
		#if hex.natur.has(Hex.NATUR.Wald):
			#var masche := Mesh.new()
			#match hex.natur_abgewirtschaftet:
				#0: masche = hex_bibliothek.natur_lichtung
				#1: masche = hex_bibliothek.natur_wald_1
				#2: masche = hex_bibliothek.natur_wald_2
				#3: masche = hex_bibliothek.natur_wald_3
			#var trans := Transform3D(Basis.IDENTITY,euler_lokal)
			#surface_tool.append_from(masche,0,trans)
	)
	
	return surface_tool.commit()
