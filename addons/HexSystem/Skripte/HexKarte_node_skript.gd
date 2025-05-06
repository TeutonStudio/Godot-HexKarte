@tool
class_name HexKarte3D
extends Node3D

## Erzeugt Hexagonale Maschen in Chunkweise MeshInstance3D

@export_group("Debug")
@export_tool_button("Erzeuge Welt") var gen_data: 
	get: 
		if erzeuger: 
			for each in _chunk_data: if _chunk_data[each]: _chunk_data[each].free()
			for each in _natur_data: if _chunk_data[each]: _chunk_data[each].free()
			_data = erzeuger.erzeuge_welt()
		return self.notify_property_list_changed
@export_tool_button("Neu vermaschen") var gen_masche: 
	get: 
		if _data: data = _data
		return self.notify_property_list_changed
@export var debug_kubial := false
@export var debug_radial := false
@export var debug := false
@export var debug_pfad_hexes := false
@export var debug_pfad_location := false

@export_group("Weltdaten")
@export var erzeuge := false
@export var erzeuger: HexWeltErzeuger
@export var hex_bibliothek: HexBibliothek
@export_storage var _chunk_data: Dictionary[Vector3i, MeshInstance3D]
@export_storage var _natur_data: Dictionary[Vector3i, MeshInstance3D]
@export_storage var _data: HexWelt
@export var data: HexWelt:
	set(wert): _data = wert; data = wert; _erzeuge_karte()
	get: return _data

# Material für Chunks
#const material := preload("res://addons/HexSystem/Materialien/hex_test_material.tres")

func _ready() -> void:
	if not hex_bibliothek:
		push_error("HexBibliothek nicht zugewiesen!")
		return
	if not erzeuger.höhenkarte and erzeuge:
		push_error("Höhenkarte nicht zugewiesen!")
		return
	if not Engine.is_editor_hint():
		if erzeuge: data = erzeuger.erzeuge_welt()
#	if not Engine.is_editor_hint(): if _data: _data = data; return

func _erzeuge_karte() -> void: if _data: HexSys.for_radial(_data.radius_welt, 
	func(r: int, s: int, i: int) -> void: _erzeuge_chunk(r, s, i) )

func _erzeuge_chunk(radius: int, seite: int, interpoliert: int) -> void:
	var chunk_pos_radial := Vector3i(radius, seite, interpoliert)
	var chunk_name := "Chunk " + str(chunk_pos_radial)
	var nautr_name := "Natur " + str(chunk_pos_radial)
	
	var existing_chunk = _chunk_data.get_or_add(chunk_pos_radial,null)
	#if Engine.is_editor_hint() and existing_chunk:
		#return
	if existing_chunk: existing_chunk.free()
	
	var chunk_pos_axial := HexSys.erhalte_axial_nach_chunk_radial_mit_vektor(chunk_pos_radial, _data.radius_chunk)
	var chunk_pos_euler := HexSys.erhalte_euler_nach_axial_mit_vektor(chunk_pos_axial, hex_bibliothek.Hexagon_größe)
	
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
	add_child(natur_instanz)
	natur_instanz.name = nautr_name
	natur_instanz.position = chunk_pos_euler
	natur_instanz.mesh = _konstruiere_natur(chunk_pos_radial)
	natur_instanz.material_override = hex_bibliothek.material
	natur_instanz.owner = self.owner if Engine.is_editor_hint() else self
	_natur_data[chunk_pos_radial] = natur_instanz


func _konstruiere_chunk(radial_chunk: Vector3i) -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var protokoll: Dictionary[String,Array]
	protokoll["richtungsauswertung"] = []
	protokoll["hexabfrage"] = []
	protokoll["nachbarabfrage"] = []
	
	HexSys.for_radial(_data.radius_chunk, func(r: int, s: int, i: int) -> void:
		var radial_lokal := Vector3i(r,s,i)
		var axial_global := HexSys.erhalte_axial_global_nach_radialpaar(radial_lokal,radial_chunk,_data.radius_chunk)
		
		#var ausgabe1_string := "hex existiert nicht "+str(hex_pos_kubial_global)
		#if not _data.data.has(hex_pos_kubial_global): protokoll["hexabfrage"].append(ausgabe1_string); return
		if not _data.existiert_hex_nach_axial_global(axial_global): 
			protokoll["hexabfrage"].append(axial_global)
			return
	
		var hex := _data.erhalte_hex_nach_axial_global(axial_global)
		var hex_variante := hex.variante
		var hex_pos_höhe := hex.höhe
		var euler_lokal := HexSys.erhalte_euler_nach_radial_mit_vektor(radial_lokal,hex_bibliothek.Hexagon_größe,hex_pos_höhe)
		
		var richtungen: Dictionary[HexSys.HEX_RICHTUNG, Hex.VARIANTEN]
		for richtung in HexSys.HEX_RICHTUNG.values():
			var nachbar_axial_global = axial_global + HexSys.erhalte_axial_richtung(richtung)
			if not _data.existiert_hex_nach_axial_global(nachbar_axial_global): 
				protokoll["nachbarabfrage"].append(nachbar_axial_global)
				return
			
			var nachbar_hex := _data.erhalte_hex_nach_axial_global(nachbar_axial_global)
			var nachbar_variante = nachbar_hex.variante
			var nachbar_pos_höhe = nachbar_hex.höhe
			
			richtungen[richtung] = nachbar_variante
			if nachbar_variante == Hex.VARIANTEN.Kreuzung:
				if hex_variante != Hex.VARIANTEN.Boden:
					richtungen[richtung] = hex_variante
				else: richtungen[richtung] = Hex.VARIANTEN.Boden
			
			var rot_euler_y = HexSys.erhalte_winkel_nach_richtung(richtung)
			var rot_euler := Basis(Vector3.UP, rot_euler_y)
			var seite_masche: Mesh
			
			if hex_pos_höhe == 0: 
				if nachbar_pos_höhe != 0: richtungen[richtung] = -1
			else: for idx in int((hex_pos_höhe - nachbar_pos_höhe) / 10 + 1):
				var seite_pos_euler_lokal := euler_lokal - Vector3.UP * idx 
				var seite_trans = Transform3D(rot_euler, seite_pos_euler_lokal)
				
				if hex_variante == Hex.VARIANTEN.Boden:
					seite_masche = hex_bibliothek.seite_gras if idx == 0 else hex_bibliothek.seite_gras_untergrund
				if hex_variante == Hex.VARIANTEN.Fluß:
					if nachbar_variante == hex_variante:
						seite_masche = hex_bibliothek.seite_fluß if idx == 0 else hex_bibliothek.seite_fluß_untergrund
					else: seite_masche = hex_bibliothek.seite_gras if idx == 0 else hex_bibliothek.seite_gras_untergrund
				if hex_variante == Hex.VARIANTEN.Weg:
					if nachbar_variante == hex_variante:
						seite_masche = hex_bibliothek.seite_weg if idx == 0 else hex_bibliothek.seite_weg_untergrund
					else: seite_masche = hex_bibliothek.seite_gras if idx == 0 else hex_bibliothek.seite_gras_untergrund
				if hex_variante == Hex.VARIANTEN.Kreuzung:
					seite_masche; push_warning("Kein Mesh")
				
				if seite_masche: surface_tool.append_from(seite_masche, 0, seite_trans)
		
		var ebene_masche: Mesh 
		var rotations_idx: int
		
		var relevante := []
		for jedes in richtungen.keys(): if richtungen[jedes] != Hex.VARIANTEN.Boden: 
			relevante.append(jedes)
		
		if hex_pos_höhe == 0:
			relevante = []; for jedes in richtungen.keys(): 
				if richtungen[jedes] == -1: relevante.append(jedes)
			
			if relevante.size() == 0:
				ebene_masche = hex_bibliothek.ebene_wasser
			if relevante.size() == 1: 
				ebene_masche = hex_bibliothek.küste_3
				rotations_idx = HexSys.erhalte_erstes(richtungen)+2
			if relevante.size() == 2:
				ebene_masche = hex_bibliothek.küste_2
				rotations_idx = HexSys.erhalte_erstes(richtungen)+2
			if relevante.size() == 3:
				ebene_masche = hex_bibliothek.küste_1
				rotations_idx = HexSys.erhalte_erstes(richtungen)+3
			if relevante.size() == 4:
				ebene_masche = hex_bibliothek.küste_0
				rotations_idx = HexSys.erhalte_erstes(richtungen)+3
			#if richtungen.size() == 5:
				#ebene_masche = hex_bibliothek.küste_3
				#ebene_rotat_y *= richtungen[1]
		elif relevante.size() == 0:
				ebene_masche = hex_bibliothek.ebene_gras
		else: match hex_variante:
			Hex.VARIANTEN.Boden:
				ebene_masche = hex_bibliothek.ebene_gras
			Hex.VARIANTEN.Fluß: for jedes in HexBibliothek.BUCHSTABEN_LISTE:
				var masche_richtungen = HexBibliothek.erhalte_richtungen_nach_buchstabe(jedes,Hex.VARIANTEN.Fluß)
				if masche_richtungen: if masche_richtungen.has(richtungen):
					ebene_masche = hex_bibliothek.get("fluß_"+str(jedes))
					rotations_idx = masche_richtungen.find(richtungen)+1
			Hex.VARIANTEN.Weg: for jedes in HexBibliothek.BUCHSTABEN_LISTE:
				var masche_richtungen = HexBibliothek.erhalte_richtungen_nach_buchstabe(jedes,Hex.VARIANTEN.Weg)
				if masche_richtungen: if masche_richtungen.has(richtungen):
					ebene_masche = hex_bibliothek.get("weg_"+str(jedes))
					rotations_idx = masche_richtungen.find(richtungen)+1
			Hex.VARIANTEN.Kreuzung: pass
		
		var ebene_rotat_y := HexSys.erhalte_winkel_nach_richtung(rotations_idx)
		var ebene_rotat := Basis(Vector3.UP,ebene_rotat_y)
		var ebene_trans := Transform3D(ebene_rotat, euler_lokal)
		if ebene_masche: surface_tool.append_from(ebene_masche, 0, ebene_trans)
	); return surface_tool.commit()

func _konstruiere_natur(radial_chunk: Vector3i) -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var protokoll: Dictionary[String,Array]
	protokoll["richtungsauswertung"] = []
	protokoll["hexabfrage"] = []
	protokoll["nachbarabfrage"] = []
	
	HexSys.for_radial(_data.radius_chunk, func(r: int, s: int, i: int) -> void:
		var radial_lokal := Vector3i(r,s,i)
		var axial_global := HexSys.erhalte_axial_global_nach_radialpaar(radial_lokal,radial_chunk,_data.radius_chunk)
		
		#var ausgabe1_string := "hex existiert nicht "+str(hex_pos_kubial_global)
		#if not _data.data.has(hex_pos_kubial_global): protokoll["hexabfrage"].append(ausgabe1_string); return
		if not _data.existiert_hex_nach_axial_global(axial_global): 
			protokoll["hexabfrage"].append(axial_global)
			return
		
		var hex := _data.erhalte_hex_nach_axial_global(axial_global)
		var hex_variante := hex.variante
		var hex_pos_höhe := hex.höhe
		var euler_lokal := HexSys.erhalte_euler_nach_radial_mit_vektor(radial_lokal,hex_bibliothek.Hexagon_größe,hex_pos_höhe)
		
		if hex.natur.has(Hex.NATUR.Wald):
			var masche := hex_bibliothek.natur_wald_b3 if hex.natur_abgewirtschaftet else hex_bibliothek.natur_lichtung_b3
			var trans := Transform3D(Basis.IDENTITY,euler_lokal)
			surface_tool.append_from(masche,0,trans)
	)
	
	return surface_tool.commit()
