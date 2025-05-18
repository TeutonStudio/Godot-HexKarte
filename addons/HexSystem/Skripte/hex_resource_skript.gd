@tool
class_name Hex
extends Resource

@export var chunk_radius: int

@export_group("Globale Positionen")
@export var axial_global: Vector2i
@export var kubial_global: Vector3i
@export var radial_global: Vector3i

@export_group("Chunk Positionen")
@export var axial_chunk: Vector2i
@export var kubial_chunk: Vector3i
@export var radial_chunk: Vector3i

@export_group("Lokale Positionen")
@export var axial_lokal: Vector2i
@export var kubial_lokal: Vector3i
@export var radial_lokal: Vector3i

@export_group("Hex Eigenschaften")
@export var höhe: int
#@export var variante: VARIANTEN
@export var biom: BIOME
@export var natur: Array[NATUR]
@export var natur_abgewirtschaftet: int

func _init(
	_axial_global := axial_global, _chunk_radius := chunk_radius,
) -> void: if _axial_global != axial_global:
	
	axial_global = _axial_global
	kubial_global = HexSys.erhalte_kubial_nach_axial_mit_vektor(_axial_global)
	radial_global = HexSys.erhalte_radial_nach_axial_mit_vektor(_axial_global)
	
	axial_chunk = HexSys.erhalte_axial_chunk_nach_axial_global_mit_vektor(_axial_global,_chunk_radius)
	kubial_chunk = HexSys.erhalte_kubial_nach_axial_mit_vektor(axial_chunk)
	radial_chunk = HexSys.erhalte_radial_nach_axial_mit_vektor(axial_chunk)
	
	axial_lokal = HexSys.erhalte_axial_lokal_nach_axial_global_mit_vektor(_axial_global,_chunk_radius)
	kubial_lokal = HexSys.erhalte_kubial_nach_axial_mit_vektor(axial_lokal)
	radial_lokal = HexSys.erhalte_radial_nach_axial_mit_vektor(axial_lokal)
	
	#variante = Hex.VARIANTEN.Boden
	biom = BIOME.Steppe
	natur = []
	natur_abgewirtschaftet = 0

func erhalte_gewichtung() -> float:
	# TODO unterschiedlich nach Argument, für unterschiedliche effiziente Fortbewegung
	return .0

func erhalte_axial_kante(seite: HexSys.HEX_RICHTUNG) -> PackedInt32Array:
	var richtung := HexSys.erhalte_axial_richtung(seite)
	return PackedInt32Array([
		axial_global.x,
		axial_global.y, 
		axial_global.x + richtung.x,
		axial_global.y + richtung.y,
	])


enum VARIANTEN {
	Meer,
	Boden,
	Küste,
	Fluß,
	Weg,
}

enum BIOME {
	Steppe,
	Wüste,
	Sumpf,
}

enum NATUR {
	Wald,
	Gebirge,
	Feld,
}
