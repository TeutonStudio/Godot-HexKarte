@tool
class_name Hex3D
extends Node3D

@export var hex_karte: HexKarte3D
var hex_bibliothek: HexBibliothek:
	get: return hex_karte.hex_bibliothek if hex_karte else null

@export var hex: Hex:
	set(wert): self.position = wert.erhalte_euler(hex_bibliothek.Hexagon_größe); hex = wert

#region 

func _get_property_list() -> Array[Dictionary]:
	var ausgabe: Array[Dictionary] = []
	
	ausgabe.append_array(_erhalte_Koordinaten_eigenschaften())
	
	return ausgabe

func _get(eigenschaft: StringName) -> Variant:
	var struktur := eigenschaft.split("/")
	
	if struktur.size() == 2: if hex:
		return hex.get(struktur[1])
	
	return

func _set(eigenschaft: StringName, wert: Variant) -> bool:
	var struktur := eigenschaft.split("/")
	
	if struktur.size() == 2:
		var erstes := struktur[1].split("_")[0]
		var zweites := struktur[1].split("_")[1]
		if zweites == "global":
			if setze_hex_nach_global(erstes,wert):
				return true
	
	return false

#endregion
#region

enum VAR1 { axial, radial, kubial }
enum VAR2 { global, chunk, lokal }

func _erhalte_Koordinaten_eigenschaften() -> Array[Dictionary]:
	var ausgabe: Array[Dictionary] = []
	
	for erstes in VAR1: for zweites: String in VAR2:
		var gruppe := (zweites+"e").capitalize()+" Koordinaten"
		ausgabe.append({
			"name": gruppe+"/"+erstes+"_"+zweites,
			"type": TYPE_VECTOR2I if erstes == "axial" else TYPE_VECTOR3I,
		})
	
	return ausgabe

func setze_hex_nach_global( erstes: String, global: Variant ) -> bool:
	if erstes == "axial": if global is Vector2i:
		hex = hex_karte.data.erhalte_hex_nach_axial_global(global as Vector2i)
		return true
	if erstes == "radial": push_warning("Nicht implementiert")
	if erstes == "kubial": push_warning("Nicht implementiert")
	
	return false

#endregion

#@export_group("Globale Koordinaten")
#@export var kubial_global := Vector3i.ZERO:
	#set(wert): kubial_global = _aktualisiere_position_kubial_global(wert)
	#get: return _kubial_global
#@export var axial_global := Vector2i.ZERO:
	#set(wert): axial_global = _aktualisiere_position_axial_global(wert)
	#get: return _axial_global
#@export var radial_global := Vector3i.ZERO:
	#set(wert): radial_global = _aktualisiere_position_radial_global(wert)
	#get: return _radial_global
#
#@export_group("Chunk Koordinaten")
#@export var kubial_chunk := Vector3i.ZERO:
	#set(wert): kubial_chunk = _aktualisiere_position_kubial_chunk(wert)
	#get: return _kubial_chunk
#@export var axial_chunk := Vector2i.ZERO:
	#set(wert): axial_chunk = _aktualisiere_position_axial_chunk(wert)
	#get: return _axial_chunk
#@export var radial_chunk := Vector3i.ZERO:
	#set(wert): radial_chunk = _aktualisiere_position_radial_chunk(wert)
	#get: return _radial_chunk
#
#@export_group("Lokale Koordinaten")
#@export var kubial_lokal := Vector3i.ZERO:
	#set(wert): kubial_lokal = _aktualisiere_position_kubial_lokal(wert)
	#get: return _kubial_lokal
#@export var axial_lokal := Vector2i.ZERO:
	#set(wert): axial_lokal = _aktualisiere_position_axial_lokal(wert)
	#get: return _axial_lokal
#@export var radial_lokal := Vector3i.ZERO:
	#set(wert): radial_lokal = _aktualisiere_position_radial_lokal(wert)
	#get: return _radial_lokal
#
#var _kubial_global: Vector3i
#var _axial_global: Vector2i
#var _radial_global: Vector3i
#var _kubial_chunk: Vector3i
#var _axial_chunk: Vector2i
#var _radial_chunk: Vector3i
#var _kubial_lokal: Vector3i
#var _axial_lokal: Vector2i
#var _radial_lokal: Vector3i

@export_group("Debug")
@export var radius := 0
@export var radius_debug_hexes := false
@export var radius_debug_lokation := false

func setzte_auf_hex(hex: Hex) -> void:
	#_kubial_global = hex.kubial_global
	#_axial_global = hex.axial_global
	#_radial_global = hex.radial_global
	#
	#_kubial_chunk = hex.kubial_chunk
	#_axial_chunk = hex.axial_chunk
	#_radial_chunk = hex.radial_chunk
	#
	#_kubial_lokal = hex.kubial_lokal
	#_axial_lokal = hex.axial_lokal
	#_radial_lokal = hex.radial_lokal
	
	var pos = HexSys.erhalte_euler_nach_axial_mit_vektor(
		hex.axial_global,
		hex_bibliothek.Hexagon_größe,
		hex.höhe,
	); self.position = pos

func ist_definiert(_axial_global: Vector2i) -> bool:
	if not hex_karte or not hex_bibliothek or not hex_karte.data: return false
	var weltspeicher := hex_karte.data
	if not weltspeicher.existiert_hex_nach_axial_global(_axial_global):
		push_warning("Hex3D: Lokation " + str(_axial_global) + " existiert nicht im WeltSpeicher.")
		return false
	return true

#
#func _aktualisiere_position_kubial_global(_kubial := kubial_global) -> Vector3i:
	#var __axial_global := HexSys.erhalte_axial_nach_kubial_mit_vektor(_kubial)
	#_aktualisiere_position_axial_global(__axial_global)
	#return _kubial
#
#func _aktualisiere_position_axial_global(_axial := axial_global) -> Vector2i:
	#if ist_definiert(_axial):
		#var hex := hex_karte.data.erhalte_hex_nach_axial_global(_axial)
		#setzte_auf_hex(hex)
	#return _axial
#
#func _aktualisiere_position_radial_global(_radial := radial_global) -> Vector3i:
	#var __axial_global := HexSys.erhalte_axial_nach_radial_mit_vektor(_radial)
	#_aktualisiere_position_axial_global(__axial_global)
	#return _radial
#
#
#func _aktualisiere_position_kubial_chunk(_kubial := kubial_chunk) -> Vector3i:
	#var __axial_chunk = HexSys.erhalte_axial_nach_chunk_radial_mit_vektor(
		#HexSys.erhalte_radial_nach_kubial_mit_vektor(_kubial),
		#hex_karte.data.radius_chunk
	#)
	#_aktualisiere_position_axial_global(__axial_chunk + _axial_lokal)
	#return _kubial
#
#func _aktualisiere_position_axial_chunk(_axial := axial_chunk) -> Vector2i:
	#_aktualisiere_position_axial_global(_axial + _axial_lokal)
	#return _axial
#
#func _aktualisiere_position_radial_chunk(_radial := radial_chunk) -> Vector3i:
	#var __kubial_chunk = HexSys.erhalte_axial_nach_chunk_radial_mit_vektor(
		#_radial,
		#hex_karte.data.radius_chunk
	#)
	#_aktualisiere_position_kubial_global(__kubial_chunk + _kubial_lokal)
	#return _radial
#
#
#func _aktualisiere_position_kubial_lokal(_kubial := kubial_lokal) -> Vector3i:
	#var __axial_lokal := HexSys.erhalte_axial_nach_kubial_mit_vektor(_kubial)
	#_aktualisiere_position_axial_global(axial_chunk + __axial_lokal)
	#return _kubial
#
#func _aktualisiere_position_axial_lokal(_axial := axial_lokal) -> Vector2i:
	#_aktualisiere_position_axial_global(axial_chunk + _axial)
	#return _axial
#
#func _aktualisiere_position_radial_lokal(_radial := radial_lokal) -> Vector3i:
	#var __axial_lokal := HexSys.erhalte_axial_nach_radial_mit_vektor(_radial)
	#_aktualisiere_position_axial_global(axial_chunk + __axial_lokal)
	#return _radial
