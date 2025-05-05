@tool
class_name HexPfad
extends Resource

@export_group("Pfad")
@export var pfad_hexes: Array[Vector2i] = []
@export var pfad_geschlossen: bool = false

@export_storage var betroffene: Array[Vector2i] = []

func vervollständige_betroffene_hex() -> void:
	betroffene.clear()
	var anzahl := pfad_hexes.size()
	if anzahl < 2: return

	for i in anzahl - 1:
		var start := pfad_hexes[i]
		var ende := pfad_hexes[i + 1]
		betroffene.append_array(_hexes_entlang_linie(start,ende))
		_errechne_locations(start, ende)
	
	if pfad_geschlossen and anzahl > 2:
		betroffene.append_array(_hexes_entlang_linie(pfad_hexes[-1],pfad_hexes[0]))
	else: betroffene.append(pfad_hexes[-1])

func _errechne_locations(start: Vector2i, ende: Vector2i) -> void:
	for hex in _hexes_entlang_linie(start, ende):
		if not betroffene.has(hex): betroffene.append(hex)

func _hexes_entlang_linie(start: Vector2i, ende: Vector2i) -> Array[Vector2i]:
	if start == ende: return [start]
	var hexes: Array[Vector2i] = []
	var hex_radius := 1
	var schrittweite := .3
	var start_euler := HexSys.erhalte_euler_nach_axial_mit_vektor(start,hex_radius)
	var ende_euler := HexSys.erhalte_euler_nach_axial_mit_vektor(ende,hex_radius)
	var richtung := start_euler.direction_to(ende_euler) * schrittweite
	var anzahl := int(start_euler.distance_to(ende_euler) / schrittweite + 1)
	
	for idx in anzahl:
		var pos_euler := start_euler + idx * richtung
		var axial_global := HexSys.erhalte_axial_nach_euler_mit_vektor(pos_euler,hex_radius)
		if not hexes.has(axial_global) and axial_global != ende: hexes.append(axial_global)
	
	return hexes
