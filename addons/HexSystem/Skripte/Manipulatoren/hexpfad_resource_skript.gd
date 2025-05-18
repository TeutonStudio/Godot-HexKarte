@tool
class_name HexPfad
extends Resource

@export_group("Pfad")
@export var pfad_hexes: Array[Vector2i] = []
@export var pfad_geschlossen: bool = false

@export_storage var betroffene_hexes: Array[PackedInt32Array] = []
@export_storage var betroffene_kanten: Array[PackedInt32Array] = []

func vervollständige_betroffene_hex() -> void:
	betroffene_hexes.clear()
	betroffene_kanten.clear()
	var anzahl := pfad_hexes.size()
	if anzahl < 2: return
	
	for i in anzahl - 1: _hexes_entlang_linie(pfad_hexes[i], pfad_hexes[i+1])
	
	if pfad_geschlossen and anzahl > 2: _hexes_entlang_linie(pfad_hexes[-1], pfad_hexes[0])

func _erhalte_verhältnis(koordinate: Vector2i) -> int:
	if abs(koordinate.x) >= abs(koordinate.y): return abs(koordinate.x) / abs(koordinate.y)
	else: return int(abs(koordinate.y) / abs(koordinate.x))

func _erhalte_erste_richtung(koordinate: Vector2i) -> Vector2i:
	if abs(koordinate.x) >= abs(koordinate.y): return int(sign(koordinate.y)) * Vector2i(1,0)
	else: return int(sign(koordinate.x)) * Vector2i(1,0)

func _erhalte_zweite_richtung(koordinate: Vector2i) -> Vector2i:
	if abs(koordinate.x) <= abs(koordinate.y): return int(sign(koordinate.y)) * Vector2i(0,1)
	else: return int(sign(koordinate.x)) * Vector2i(0,1)

func _validiere_gefundene_kootfinate(
	liste: Array[PackedInt32Array],
	koordinate: PackedInt32Array,
) -> void: if not liste.has(koordinate): liste.append(koordinate)

func _hexes_entlang_linie(
	start: Vector2i, ende: Vector2i,
	differenz := ende - start,
	verhältnis := _erhalte_verhältnis(differenz),
	anzahl := min(abs(differenz.x), abs(differenz.y)),
) -> void: 
	var punkt := start
	var richtung1 := _erhalte_erste_richtung(differenz)
	var richtung2 := _erhalte_zweite_richtung(differenz)
	for jedes1: int in anzahl: for jedes2: int in verhältnis:
		var neuer_punkt := start + richtung1 * jedes1 + richtung2 * (jedes2 + verhältnis * jedes1)
		_validiere_gefundene_kootfinate(betroffene_hexes,[punkt.x,punkt.y])
		_validiere_gefundene_kootfinate(betroffene_kanten,[punkt.x,punkt.y,neuer_punkt.x,neuer_punkt.y])
		_validiere_gefundene_kootfinate(betroffene_hexes,[neuer_punkt.x,neuer_punkt.y])
		punkt = neuer_punkt
	
	
	return

#func _hexes_entlang_linie(start: Vector2i, ende: Vector2i) -> Array[Vector2i]:
	#if start == ende: return [start]
	#var hexes: Array[Vector2i] = []
	#var hex_radius := 1
	#var schrittweite := .3
	#var start_euler := NodeHex.erhalte_euler_nach_axial_mit_vektor(start, hex_radius)
	#var ende_euler := NodeHex.erhalte_euler_nach_axial_mit_vektor(ende, hex_radius)
	#var richtung := start_euler.direction_to(ende_euler) * schrittweite
	#var anzahl := int(start_euler.distance_to(ende_euler) / schrittweite + 1)
	#
	#for idx in anzahl:
		#var pos_euler := start_euler + idx * richtung
		#var axial_global := NodeHex.erhalte_axial_nach_euler_mit_vektor(pos_euler, hex_radius)
		#if not hexes.has(axial_global) and axial_global != ende: hexes.append(axial_global)
	#
	#hexes.append(ende)
	#return hexes

#func _erhalte_kante_zwischen_hexen(hex1: Vector2i, hex2: Vector2i) -> Vector4i:
	#if _sind_nachbarn(hex1, hex2):
		#return Vector4i(hex1.x, hex1.y, hex2.x, hex2.y)
	#else: return Vector4i(-1, -1, -1, -1)
#
#func _sind_nachbarn(axial1: Vector2i, axial2: Vector2i) -> bool:
	#var seite := HexSys.erhalte_richtung_nach_axial_mit_vektor(axial1-axial2)
	#return seite != -1
